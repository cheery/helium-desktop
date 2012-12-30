jsoc = require './jsoc'
fs = require 'fs'

class ProcessApi
    constructor: (@apps, @api) ->
        @apps.push @
        @api.on 'end', () =>
            @apps.splice @apps.indexOf(@), 1
        @api.on 'init', (@config, ack) =>
            ack null
        @api.on 'message', (name, data, ack) =>
            console.log name, data

    kill: () ->
        @api.end()
            
apps = []

newClient = (client) ->
    process = new ProcessApi(apps, client)
    process.api.once 'init', (config, ack) ->
        console.log process.config
        process.kill()

path = '/tmp/desktop'

server = jsoc.createServer newClient
if fs.existsSync path then fs.unlinkSync path
server.listen path, () ->
    console.log 'server running'
