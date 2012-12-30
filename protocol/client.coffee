jsoc = require './jsoc'

config = {
    pid: process.pid,
    gid: process.getgid(),
    uid: process.getuid(),
    version: {minor:0, major:1},
}

client = jsoc.connect {path: "/tmp/desktop"}, () ->
    console.log "connected"
    client.send "init", config, (ok) ->
        console.log ok

client.on 'end', () ->
    console.log "disconnected"

client.on 'message', (name, data, ack) ->
    console.log name, data
    ack 'ok'

