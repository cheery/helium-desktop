fs = require 'fs'
dg = require 'dg'
Shader = require './webgl/shader'
Quad = require './webgl/quad'
Texture = require './webgl/texture'

surface = dg.getFullscreen {
#    width: 210,
#    height: 120,
}
gl = surface.getContext 'webgl'

console.log "resolution #{surface.width}x#{surface.height}"

path = "julia.shader"
path = "mandelbrot.shader"
path = "gradient.shader"
path = "starfield.shader"
path = "clouds.shader"
path = "cat.shader"

gradient = new Shader gl, fs.readFileSync("#{__dirname}/#{path}", "ascii")
quad = new Quad gl

mouse_position = {x: 0, y:0}

start = Date.now()

frames = []

cat = (new Texture gl).uploadFile "#{__dirname}/cat.png"

countFrameRate = (frameStart) ->
    targetFPS = 30
    frameEnd = Date.now()
    deltaFrame = frameEnd - frameStart
    frames.push deltaFrame
    if frames.length >= 100
        average = 0
        worst = 0
        for frame in frames
            average += frame
            if frame > worst then worst = frame
        average /= frames.length
        console.log "FPS(target=#{targetFPS}) #{1000 / average} worst #{1000 / worst}"

        frames = []
    return Math.max(0.0, 1000 / targetFPS - deltaFrame)

draw = () ->
    frameStart = Date.now()

    gl.activeTexture gl.TEXTURE0
    gl.bindTexture gl.TEXTURE_2D, cat.id

    gl.clearColor 0.5, 0.5, 0.5, 1.0
    gl.clear gl.COLOR_BUFFER_BIT

    gradient.use()
        .val2('resolution', surface.width, surface.height)
        .val2('offset', 100, 100 + Math.sin(Date.now() / 1000.0) * 250 )
        .val2('size', cat.width, cat.height)
        .f('time', (Date.now() - start) / 1000)
        .val2('mouse', mouse_position.x / surface.width, 1.0 - mouse_position.y / surface.height)
        .val3('color', 0.5, 0.0, 0.0)
        .i('texture', 0)
        .draw(quad)
    gl.swapBuffers()
    #setTimeout draw, 100
    setTimeout draw, countFrameRate(frameStart)

draw()

console.log 'draw succeed'

udev = require 'udev'
fs = require 'fs'
Mouse = require './mouse'

register_mouse = (mouse) ->
    mouse.on "motion", (position, velocity) ->
        mouse_position = position
#        console.log "motion", position, velocity
#    mouse.on "wheel_motion", (position, velocity) ->
#        console.log "wheel_motion", position, velocity
#    mouse.on "button_press", (button, buttons) ->
#        console.log "button_press", button, buttons
#    mouse.on "button_release", (button, buttons) ->
#        console.log "button_release", button, buttons

mice = {}

ismouse = (device) ->
    ok = true
    ok &&= device.syspath.match(/event[0-9]+$/)
    ok &&= device.SUBSYSTEM == "input"
    ok &&= device.ID_INPUT == "1"
    ok &&= device.ID_INPUT_MOUSE == "1"
    return ok

for device in udev.list()
    if ismouse device
        console.log "#{device.ID_SERIAL} exists at path #{device.ID_PATH}"
        mice[device.ID_PATH] = mouse = new Mouse device
        register_mouse mouse

monitor = udev.monitor()

monitor.on 'add', (device) ->
    if ismouse device
        console.log "#{device.ID_SERIAL} added at path #{device.ID_PATH}"
        mice[device.ID_PATH] = mouse = new Mouse device
        register_mouse mouse

monitor.on 'remove', (device) ->
    if ismouse device
        console.log "#{device.ID_SERIAL} removed at path #{device.ID_PATH}"
        mouse = mice[device.ID_PATH]
        if mouse? then mouse.close()
        delete mice[device.ID_PATH]

console.log 'listening devices'
