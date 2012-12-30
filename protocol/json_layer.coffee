EventEmitter = require('events').EventEmitter
net = require 'net'

class JsonConnection extends EventEmitter

decodeJson = (data) ->
    try
        return JSON.parse data
    catch error
        return if error.name == 'SyntaxError'
        throw error

encode = (type, id, name, data) ->
    data = JSON.stringify data
    return "#{type}:#{id}:#{name}:#{if data? then data else ''}"

decode = (msg) ->
    out = msg.match /^([^:]*):([0-9]+):([^:]*):(.*)$/
    if out? then return {
            type: out[1]
            id: parseInt out[2]
            name: out[3]
            data: decodeJson out[4]
        }
    else return undefined

reserved = ['connect', 'message', 'end']

wrapSocket = (socket) ->
    conn = new JsonConnection
    conn.socket = socket

    buffer = ''
    waiters = {}
    next = 0

    socket.on 'connect', () -> conn.emit 'connect'

    socket.on 'end', () -> conn.emit 'end'

    socket.on 'data', (data) ->
        buffer += data
        done = false
        while not done
            match = buffer.match /^([^\n]*)\n(.*)$/
            if match?
                readMessage decode match[1]
                buffer = match[2]
            else done = true
        return

    sendAck = (id, data) ->
        socket.write "#{encode '1', id, '', data}\n"

    readMessage = (msg) ->
        switch msg.type
            when '0'
                ack_once = true
                ack = (data) ->
                    if ack_once then sendAck msg.id, data
                    ack_once = false
                conn.emit 'message', msg.name, msg.data, ack
                if reserved.indexOf(msg.name) == -1
                    conn.emit msg.name, msg.data, ack
                ack()
            when '1'
                cb = waiters[msg.id]
                delete waiters[msg.id]
                if cb? then cb msg.data
        return

    conn.end = () -> socket.end()
    conn.send = (name, data, cb) ->
        id = next++
        if cb? then waiters[id] = cb
        socket.write "#{encode '0', id, name, data}\n"

    return conn

module.exports.createServer = (callback) ->
    net.createServer (connection) -> callback wrapSocket connection

module.exports.connect = (args...) ->
    wrapSocket net.connect args...
