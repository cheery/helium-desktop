il = require 'openil'

class Texture
    constructor: (@gl, @mag = @gl.LINEAR, @min = @gl.LINEAR) ->
        @id = @gl.createTexture()

    uploadFile: (path) ->
        image = il.loadSync path
        @width = image.width
        @height = image.height
        @gl.bindTexture @gl.TEXTURE_2D, @id
        @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, @width, @height, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, image.data
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @mag
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @min
        #@gl.bindTexture @gl.TEXTURE_2D, 0
        return @

    sourceFrom: (src_id) ->
        @gl.bindTexture @gl.TEXTURE_2D, @id
        @gl.textureSourceDG @gl.TEXTURE_2D, src_id
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @mag
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @min
        #@gl.bindTexture @gl.TEXTURE_2D, 0
        return @

module.exports = Texture
