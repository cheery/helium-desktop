init =
    view = desktop.createWiew
        width: 640
        height: 480
        behavior: 'interface'
    gl = view.getContext 'webgl'

    gl.clearColor 0.5, 0.5, 0.5, 1.0

    draw = () ->
        gl.clear gl.COLOR_BUFFER_BIT
        gl.swapBuffers()
        view.requestAnimationFrame draw
    view.requestAnimationFrame draw

info = {
    description: "clear screen, GL test program"
}

desktop = require('dream').connect info, init
