EvDevIO = require './evdev'
EventEmitter = require("events").EventEmitter

class Mouse extends EventEmitter
    constructor: (@device) ->
        @path = @device.ID_PATH
        @position = x: 0, y: 0
        @accum = x: 0, y: 0
        @wheel = 0
        @wheel_accum = 0
        @buttons = left: false, middle: false, right: false
        @io = new EvDevIO @device.DEVNAME, (err, event) =>
            if err then throw err
            switch event.type
                when 2 then @_motion(event)
                when 0 then @_motion_flush(event)
                when 1 then @_button(event)
                when 4
                else
                    console.log event

    _motion: (event) ->
        switch event.code
            when 0 then @accum.x += event.value
            when 1 then @accum.y += event.value
            when 8 then @wheel_accum += event.value

    _motion_flush: (event) ->
        @position.x += @accum.x
        @position.y += @accum.y
        @wheel += @wheel_accum
        if @accum.x != 0 or @accum.y != 0
            @emit "motion", @position, @accum
        if @wheel_accum != 0
            @emit "wheel_motion", @wheel, @wheel_accum
        @accum = x: 0, y: 0
        @wheel_accum = 0

    _button: (event) ->
        button = { name: null, value: (event.value == 1) }
        switch event.code
            when 272 then button.name = "left"
            when 274 then button.name = "middle"
            when 273 then button.name = "right"
        @buttons[button.name] = button.value
        if button.value
            @emit "button_press", button.name, @buttons
        else
            @emit "button_release", button.name, @buttons

    close: () ->
        @io.close()

module.exports = Mouse
