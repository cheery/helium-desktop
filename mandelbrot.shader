vertex:
    attribute vec3 position;

    void main(){
        gl_Position = vec4(position, 1.0);
    }

fragment:
    uniform float time;
    uniform vec2 mouse;
    uniform vec2 resolution;

    void main(void) {

        vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
//        float magnitude = sin(time/ 15) * 10 + 11;
//        vec2 scale = vec2(magnitude, magnitude);
        vec2 scale = vec2(0.003, 0.003);

      float intensity;
      vec4 color2;
      float cr=(gl_FragCoord.x-resolution.x*0.5)*scale.x;
      float ci=(gl_FragCoord.y-resolution.y*0.5)*scale.y;
      float ar=cr;
      float ai=ci;
      float tr,ti;
      float col=0.0;
      float p=0.0;
      int i=0;
      for(int i2=1;i2<16;i2++)
      {
        tr=ar*ar-ai*ai+cr;
        ti=2.0*ar*ai+ci;
        p=tr*tr+ti*ti;
        ar=tr;
        ai=ti;
        if (p>16.0)
        {
          i=i2;
          break;
        }
      }
      color2 = vec4(float(i)*0.0625,0,0,1);
      gl_FragColor = color2;
    }
