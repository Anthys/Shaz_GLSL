precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_texture_0;


const float s3 = 1.7320508075688772;
const float i3 = 0.5773502691896258;

const mat2 tri2cart = mat2(1.0, 0.0, -0.5, 0.5*s3);
const mat2 cart2tri = mat2(1.0, 0.0, i3, 2.0*i3);

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) -
          smoothstep( pct, pct+0.02, st.y);
}

float plotx(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.x) -
          smoothstep( pct, pct+0.02, st.x);
}

void main() {
    vec4 final_coord = vec4(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.z, gl_FragCoord[3]);
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    vec2 it = cart2tri * st.xy;
    vec4 final_col = vec4(it.x,it.y,1.,1.);
    float pct = 0.;
    vec2 grid = it*50.;
    vec2 grid2 = fract(grid/5.);
    if (grid2.x < .5 && grid2.y < .5){
        pct = 1.;
    }
    //pct = plot(st,0.5);
    //st.x *= u_resolution.x / u_resolution.y;
    final_col = vec4(pct,pct,pct, 1.);
    gl_FragColor = final_col;
    //gl_FragColor = texture2D(u_texture_0, st) * final_col;
    //gl_FragColor = vec4(color, 1.0);
}