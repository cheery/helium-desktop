fs = require 'fs'

class EvDevIO
    constructor: (path, callback) ->
        @buffer = new Buffer 16
        @view = new DataView @buffer
        fs.open path, "r+", (err, @fd) =>
            if err then return callback(err, null)
            @_read_loop(callback)
        
    _decode_buffer: () ->
        return {
            sec: @view.getInt32(0, true)
            usec: @view.getInt32(4, true)
            type: @view.getUint16(8, true)
            code: @view.getUint16(10, true)
            value: @view.getInt32(12, true)
        }

    _read_loop: (callback) ->
        fs.read @fd, @buffer, 0, 16, null, (err, bytesRead) =>
            if err and err.code == "ENODEV"
                return @close()
            if err then return callback(err, null)
            if bytesRead != 16 then return callback("not enough bytes read", null)
            callback null, @_decode_buffer()
            @_read_loop(callback)

    close: () ->
        if @fd? then fs.close(@fd)
        delete @fd

module.exports = EvDevIO
