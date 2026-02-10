require('./setting/config')

const fs = require('fs')
const path = require('path')
const chalk = require('chalk')
const { performance } = require('perf_hooks')
const { jidDecode } = require('@whiskeysockets/baileys')

// Cache
const processedMessages = new Set()
const groupMetadataCache = new Map()

// Helper decodeJid
const decodeJid = (jid) => {
  if (!jid) return jid
  if (/:\d+@/gi.test(jid)) {
    const decode = jidDecode(jid) || {}
    return decode.user && decode.server ? `${decode.user}@${decode.server}` : jid
  }
  return jid
}

module.exports = async function handleMessage(sock, m, store) {
  try {
    if (!m || !m.message) return

    // Anti double process
    const msgId = m.key?.id + (m.key?.participant || '')
    if (processedMessages.has(msgId)) return
    processedMessages.add(msgId)
    setTimeout(() => processedMessages.delete(msgId), 30000)

    // Basic info
    const from = m.key?.remoteJid
    const isGroup = from?.endsWith('@g.us')
    const sender = m.key?.participant || from
    const pushname = m.pushName || sender?.split('@')[0] || 'User'
    const botNumber = decodeJid(sock.user?.id)

    // Extract body
    let body = ''
    if (m.message?.conversation) body = m.message.conversation
    else if (m.message?.extendedTextMessage?.text) body = m.message.extendedTextMessage.text
    else if (m.message?.imageMessage?.caption) body = m.message.imageMessage.caption
    else if (m.message?.videoMessage?.caption) body = m.message.videoMessage.caption

    // Parse command
    const prefixes = global.prefix || ['.', '!', '#', '/']
    const usedPrefix = prefixes.find(p => body.startsWith(p))
    const isCmd = !!usedPrefix && body.slice(usedPrefix.length).trim().length > 0
    
    let command = ''
    let args = []
    let text = ''

    if (isCmd) {
      const afterPrefix = body.slice(usedPrefix.length).trim()
      const split = afterPrefix.split(/ +/)
      command = split[0].toLowerCase()
      args = split.slice(1)
      text = args.join(' ')
    }

    // Owner check
    const ownerList = (global.owner || []).map(v => v + '@s.whatsapp.net')
    const isOwner = ownerList.includes(sender)
    const isPremium = isOwner

    // Group metadata
    let isAdmins = false
    let isBotAdmins = false
    let groupName = ''
    let participants = []
    let admins = []

    if (isGroup) {
      try {
        let metadata = groupMetadataCache.get(from)
        if (!metadata) {
          metadata = await sock.groupMetadata(from)
          groupMetadataCache.set(from, metadata)
          setTimeout(() => groupMetadataCache.delete(from), 5 * 60 * 1000)
        }
        
        groupName = metadata.subject || ''
        participants = metadata.participants || []
        admins = participants.filter(p => p.admin).map(p => p.id)
        isAdmins = admins.includes(sender)
        isBotAdmins = admins.includes(botNumber)
      } catch (err) {
        console.error('groupMetadata error:', err.message)
      }
    }

    // Simple logging (hanya untuk command)
    if (isCmd) {
      console.log(
        chalk.bgBlack.white('\n┌─────────── [ CMD ] ───────────┐') + '\n' +
        chalk.cyan('│') + ' ' + chalk.whiteBright('From: ') + chalk.yellow(pushname) + '\n' +
        chalk.cyan('│') + ' ' + chalk.whiteBright('Chat: ') + 
        (isGroup ? chalk.green(groupName || 'Group') : chalk.blue('Private')) + '\n' +
        chalk.cyan('│') + ' ' + chalk.whiteBright('Cmd:  ') + 
        chalk.magenta(usedPrefix + command) + '\n' +
        chalk.bgBlack.white('└───────────────────────────────┘')
      )
    }

    // Public/self mode check
    if (!sock.public && !isOwner && !m.key.fromMe) return

    // Reply helper
    const reply = (txt) => sock.sendMessage(from, { text: txt }, { quoted: m })

    const t0 = performance.now()

    // Command handler
    switch (command) {
      
      case 'ping': {
        const latency = (performance.now() - t0).toFixed(2)
        reply(`🏓 Pong! ${latency}ms`)
        break
      }

      case 'menu':
        reply(`Hai ${pushname} 👋\nMode: ${sock.public ? 'PUBLIC' : 'SELF'}\nRole: ${isOwner ? 'OWNER' : 'USER'}`)
        break

      case 'public': {
        if (!isOwner) return reply('Owner only')
        sock.public = true
        reply('🌍 Mode PUBLIC')
        break
      }

      case 'self': {
        if (!isOwner) return reply('Owner only')
        sock.public = false
        reply('🔒 Mode SELF')
        break
      }

      case 'kick': {
        if (!isGroup) return reply('Group only')
        if (!isAdmins) return reply('Admin only')
        if (!isBotAdmins) return reply('Bot not admin')
        
        const target = m.message?.extendedTextMessage?.contextInfo?.mentionedJid?.[0] 
          || m.message?.extendedTextMessage?.contextInfo?.participant
        
        if (!target) return reply('Tag or reply target')
        
        await sock.groupParticipantsUpdate(from, [target], 'remove')
        reply('✅ Kicked')
        break
      }

      case 'hidetag': {
        if (!isGroup) return reply('Group only')
        if (!isAdmins) return reply('Admin only')
        
        const htText = text || 'Hi all'
        await sock.sendMessage(from, { 
          text: htText, 
          mentions: participants.map(p => p.id) 
        })
        break
      }

      default:
        // Eval
        if (body.startsWith('>') && isOwner) {
          try {
            let evaled = eval(body.slice(1))
            if (typeof evaled !== 'string') evaled = require('util').inspect(evaled)
            reply(evaled)
          } catch (e) {
            reply(String(e))
          }
        }
    }

  } catch (err) {
    console.error(chalk.red('Handler Error:'), err.message)
  }
}

// Auto reload
let file = require.resolve(__filename)
fs.watchFile(file, () => {
  fs.unwatchFile(file)
  console.log(chalk.green('case.js updated'))
  delete require.cache[file]
  require(file)
})
