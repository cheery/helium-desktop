json_layer = require './protocol/json_layer'
fs = require 'fs'

dg = require 'dg'
Shader = require './webgl/shader'
Quad = require './webgl/quad'
Texture = require './webgl/texture'

surface = dg.getFullscreen {
}
gl = surface.getContext 'webgl'

getFile = (path) -> fs.readFileSync("#{__dirname}/#{path}", "ascii")

cat = new Shader gl, getFile "cat.shader"
quad = new Quad gl

class View
    constructor: (@app, @options) ->
        @texture = (new Texture gl).sourceFrom(new Buffer(@options.id, 'hex'))

class ProcessApi
    constructor: (@apps, @api) ->
        @apps.push @
        @views = []
        @api.on 'end', () =>
            @apps.splice @apps.indexOf(@), 1
        @api.on 'init', (@config, ack) =>
            ack null
        @api.on 'createView', (data, ack) =>
            @views.push new View(@, data)
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

path = '/tmp/desktop'

server = json_layer.createServer newClient
if fs.existsSync path then fs.unlinkSync path
server.listen path, () ->
    console.log "server running at #{surface.width}x#{surface.height} resolution"

all_views = () ->
    views = []
    for app in apps
        for view in app.views
            views.push view
    return views

draw = () ->
    gl.clearColor 0.5, 0.5, 0.5, 1.0
    gl.clear gl.COLOR_BUFFER_BIT
    cat.use()
        .i('texture', 0)
        .val2('resolution', surface.width, surface.height)

    x = 0
    y = 0

    gl.activeTexture gl.TEXTURE0
    for view in all_views()
        gl.bindTexture gl.TEXTURE_2D, view.texture.id
        cat
            .val2('size', view.options.width, view.options.height)
            .val2('offset', x, y)
            .draw(quad)
        x += 50
        y += 50

    gl.swapBuffers()

    setTimeout draw, 1000 / 30

draw()
