json_layer = require "./protocol/json_layer"
dg = require "dg"

config = {
}

viewExpose = (surface) ->
    surface.exposed = true
    nextFrame = surface.nextFrame
    surface.nextFrame = undefined
    if nextFrame? then nextFrame()

module.exports =
    connect: (cb) ->
        client = json_layer.connect {path: "/tmp/desktop"}, () ->
            client.send "init", config, cb
        client.views = []
        client.createView = (options) ->
            options ?= {width: 512, height: 512}
            surface = dg.createSurface options.width, options.height, options
            dg_id = dg.surfaceId(surface)
            client.send "createView", {
                id: dg_id.toString('hex')
                width: surface.width
                height: surface.height
            }, () -> viewExpose surface
            client.views.push surface
            surface.requestAnimationFrame = (nextFrame) ->
                unless surface.exposed
                    surface.nextFrame = nextFrame
                else
                    setTimeout nextFrame, 1000.0 / 60
            return surface
        client.on 'end', () ->
            for view in client.views
                view.exposed = false
        return client
