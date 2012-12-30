vertex:
    attribute vec3 position;

    void main(){
        gl_Position = vec4(position, 1.0);
    }

fragment:
    uniform float time;
    uniform vec2 mouse;
    uniform vec2 resolution;
    
    void main(){
          float intensity;
          vec2 offset = mouse * resolution;
          vec4 color2;
          vec2 centre = resolution * 0.5;
          vec2 scale = vec2(0.003, 0.003);
          vec2 tcoord = gl_FragCoord.xy / resolution.xy;
          float ar=(gl_FragCoord.x-centre.x)*scale.x;
          float ai=(gl_FragCoord.y-centre.y)*scale.y;
          float cr=(offset.x-centre.x)*scale.x;
          float ci=(offset.y-centre.y)*scale.y;
          float tr,ti;
          float col=0.0;
          float p=0.0;
          int i=0;
          vec2 t2;
          t2.x=tcoord.x+(offset.x-centre.x)*(0.5/centre.y);
          t2.y=tcoord.y+(offset.y-centre.y)*(0.5/centre.x);
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
          color2 = vec4(0,float(i)*0.0625,0,1);
          //color2 = color2+texture2D(tex,t2);
          gl_FragColor = color2;
    }
