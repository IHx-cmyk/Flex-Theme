console.clear()
console.log('Starting...')

const figlet = require('figlet')
const chalk = require('chalk')
const readline = require('readline')
const fs = require('fs')
const pino = require("pino")

console.log(
  chalk.cyan.bold(
    figlet.textSync('Shiny', {
      font: 'ANSI Shadow',
      horizontalLayout: 'default'
    })
  )
)
console.log(chalk.yellow('\n      Created by Shiny -Dev\n'))

require('./setting/config')

const {
  default: makeWASocket,
  DisconnectReason,
  useMultiFileAuthState,
  delay,
  fetchLatestBaileysVersion,
  makeCacheableSignalKeyStore,
  Browsers,
  PHONENUMBER_MCC
} = require('@whiskeysockets/baileys')

const handleMessage = require('./case')

/* ================= UTIL ================= */
const usePairingCode = true
let pairingCodeRequested = false

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
})

const question = (q) => new Promise(res => rl.question(q, res))

const timestamp = () =>
  chalk.gray(`[${new Date().toLocaleTimeString()}]`)

/* ================= START ================= */
async function start () {
  try {
    const { version, isLatest } = await fetchLatestBaileysVersion()
    console.log(timestamp(), chalk.blue(`Using Baileys v${version}, isLatest: ${isLatest}`))
    
    const { state, saveCreds } = await useMultiFileAuthState('./session')
    
    const msgRetryCounterCache = new Map()

    // PERBAIKAN: Gunakan state langsung, jangan diubah struktur auth-nya
    const sock = makeWASocket({
      version,
      auth: state, // Gunakan state langsung dari useMultiFileAuthState
      printQRInTerminal: !usePairingCode,
      logger: pino({ level: 'fatal' }),
      browser: Browsers.macOS('Chrome'), // Coba ganti browser
      markOnlineOnConnect: true,
      generateHighQualityLinkPreview: true,
      msgRetryCounterCache,
      defaultQueryTimeoutMs: undefined,
      // PERBAIKAN: Tambahkan ini untuk stabilitas pairing
      shouldSyncHistoryMessage: () => false,
      syncFullHistory: false
    })

    sock.public = true

    /* ===== SAVE SESSION ===== */
    sock.ev.on('creds.update', saveCreds)

    /* ===== CONNECTION & PAIRING CODE ===== */
    sock.ev.on('connection.update', async (update) => {
      const { connection, lastDisconnect, qr } = update

      // PERBAIKAN: Cek registered dari creds yang benar
      const isRegistered = sock.authState?.creds?.registered || false
      
      if ((connection === 'connecting' || !!qr) && usePairingCode && !isRegistered && !pairingCodeRequested) {
        pairingCodeRequested = true
        
        try {
          console.log(timestamp(), chalk.cyan('📱 Masukkan nomor WhatsApp (format: 628xxxxxxxxxx)'))
          let phone = await question('Nomor: ')
          
          // Bersihkan nomor
          phone = phone.replace(/[^0-9]/g, '')
          
          // Validasi panjang minimal
          if (phone.length < 10) {
            console.log(timestamp(), chalk.red('❌ Nomor terlalu pendek'))
            rl.close()
            process.exit(1)
          }

          console.log(timestamp(), chalk.yellow('⏳ Request pairing code...'))
          
          // Tunggu socket siap
          await delay(2000)
          
          // PERBAIKAN: Pastikan socket sudah siap dengan cek state
          if (!sock.ws || sock.ws.readyState !== 1) {
            console.log(timestamp(), chalk.yellow('⏳ Menunggu koneksi socket siap...'))
            await delay(3000)
          }
          
          const code = await sock.requestPairingCode(phone)
          const formattedCode = code?.match(/.{1,4}/g)?.join("-") || code
          
          console.log(timestamp(), chalk.bgGreen.black(` ✅ Pairing Code: ${formattedCode} `))
          console.log(timestamp(), chalk.yellow('📲 Cara menggunakan:'))
          console.log(timestamp(), chalk.white('   1. Buka WhatsApp di HP'))
          console.log(timestamp(), chalk.white('   2. Menu (⋮) → Perangkat Tertaut → Hubungkan Perangkat'))
          console.log(timestamp(), chalk.white('   3. Pilih "Hubungkan dengan nomor telepon"'))
          console.log(timestamp(), chalk.white(`   4. Masukkan kode: ${chalk.bold(formattedCode)}`))
          
        } catch (err) {
          console.log(timestamp(), chalk.red('❌ Gagal mendapatkan pairing code:'), err.message)
          console.log(timestamp(), chalk.gray('Detail error:'), err.stack)
          console.log(timestamp(), chalk.yellow('💡 Tips: Hapus folder ./session dan coba lagi'))
          rl.close()
          process.exit(1)
        }
      }

      if (connection === 'close') {
        const reason = lastDisconnect?.error?.output?.statusCode
        pairingCodeRequested = false

        console.log(
          timestamp(),
          chalk.bgRed.white(' ❌ DISCONNECTED '),
          chalk.yellow(`Reason: ${reason}`)
        )

        switch (reason) {
          case DisconnectReason.badSession:
            console.log('❌ Bad session, hapus folder session')
            process.exit()
            break

          case DisconnectReason.loggedOut:
            console.log('🚪 Logout, hapus session lalu pairing ulang')
            process.exit()
            break

          case DisconnectReason.connectionReplaced:
            console.log('⚠️ Session dipakai di device lain')
            process.exit()
            break

          case DisconnectReason.restartRequired:
          case DisconnectReason.connectionClosed:
          case DisconnectReason.connectionLost:
          case DisconnectReason.timedOut:
            console.log('🔄 Reconnecting...')
            setTimeout(start, 3000)
            break

          default:
            console.log('❓ Unknown error, reconnecting...')
            setTimeout(start, 5000)
        }
      }

      if (connection === 'connecting') {
        console.log(timestamp(), chalk.blue('🔌 Connecting...'))
      }

      if (connection === 'open') {
        console.log(timestamp(), chalk.green('✅ WhatsApp Connected'))
        if (sock.authState?.creds?.registered || !usePairingCode) {
          rl.close()
        }
      }
    })

    /* ===== MESSAGE HANDLER ===== */
    sock.ev.on('messages.upsert', async ({ messages, type }) => {
      try {
        const msg = messages[0]
        if (!msg || !msg.message) return
        if (!sock.public && !msg.key.fromMe && type === 'notify') return

        await handleMessage(sock, msg)
      } catch (e) {
        console.log(timestamp(), chalk.red('❌ Handler Error:'), e)
      }
    })

  } catch (err) {
    console.log(timestamp(), chalk.red('❌ Fatal Error:'), err)
    console.log(timestamp(), chalk.yellow('🔄 Restarting in 5s...'))
    setTimeout(start, 5000)
  }
}

start()

/* ===== AUTO RELOAD ===== */
let file = require.resolve(__filename)
fs.watchFile(file, () => {
  fs.unwatchFile(file)
  console.log(timestamp(), chalk.green('index.js updated'))
  delete require.cache[file]
  require(file)
})
