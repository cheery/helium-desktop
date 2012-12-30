
red   = parseFloat(process.argv[2] ? "1.0")
green = parseFloat(process.argv[3] ? "1.0")
blue  = parseFloat(process.argv[4] ? "1.0")

desktop = require('./dream').connect () ->
    view = desktop.createView width: 128, height: 128
    gl = view.getContext 'webgl'

    gl.clearColor red, green, blue, 1.0

    draw = () ->
        gl.clear gl.COLOR_BUFFER_BIT
        gl.swapBuffers()
        view.requestAnimationFrame draw
    view.requestAnimationFrame draw
