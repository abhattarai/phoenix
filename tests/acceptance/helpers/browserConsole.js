import { client } from 'nightwatch-api'

function cleanupLogMessage (message) {
  message = message.replace(/\\u003C/gi, '')
  // revive newlines
  message = message.replace(/\\n/g, '\n')
  return message
}

exports.checkConsoleErrors = async function () {
  await client.getLog('browser', (entries) => {
    const filteredEntries = entries.filter((entry) => {
      return entry.level === 'SEVERE'
    }).map((entry) => {
      if (entry.message.indexOf('favicon.ico') >= 0) {
        return
      }
      return new Date(entry.timestamp).toUTCString() + ' - ' + cleanupLogMessage(entry.message)
    })

    if (filteredEntries.length > 0) {
      client.assert.fail('Errors found in browser log:\n' + filteredEntries.join('\n'))
    }
  })
}
