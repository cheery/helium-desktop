vertex:
    attribute vec2 position;
    uniform vec2 resolution;
    uniform vec2 offset;
    uniform vec2 size;

    varying vec2 uv;

    void main(){
        uv = (position.xy + 1.0) / 2.0;
        vec2 pt = offset + size * uv;
        gl_Position = vec4((pt / resolution) * 2.0 - 1.0, 0.0, 1.0);
    }

fragment:
    uniform float time;
    uniform vec2 mouse;
    uniform vec2 resolution;
    uniform sampler2D texture;
    varying vec2 uv;

    void main() {
        gl_FragColor = texture2D(texture, uv);
    }
