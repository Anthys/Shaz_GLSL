precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_texture_0;
uniform sampler2D render_buffer;


const float s3 = 1.7320508075688772;
const float i3 = 0.5773502691896258;

const mat2 tri2cart = mat2(1.0, 0.0, -0.5, 0.5*s3);
const mat2 cart2tri = mat2(1.0, 0.0, i3, 2.0*i3);


vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) -
          smoothstep( pct, pct+0.02, st.y);
}

float plotx(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.x) -
          smoothstep( pct, pct+0.02, st.x);
}

float warp(vec2 p, float factor, float n_range){
  vec2 temp1 = p*factor;
  vec2 temp2 = (p+vec2(5.2,1.3))*factor;
  float n1 = cnoise(temp1)*n_range;
  float n2 = cnoise(temp2)*n_range;
  vec2 q = vec2(n1,n2);

  float d = 4.;
  vec2 temp3 = (p + q*d + vec2(1.7, 9.2))*factor;
  vec2 temp4 = (p + q*d + vec2(8.3, 2.8))*factor;
  float n3 = cnoise(temp3)*n_range;
  float n4 = cnoise(temp4)*n_range;
  vec2 r = vec2(n3,n4);

  float final = cnoise((p+r*d)*factor)*n_range;
  return final;
}

float warp2(vec2 p, float factor, float n_range){
  vec2 temp1 = p*factor;
  vec2 temp2 = (p+vec2(5.2,1.3))*factor;
  float n1 = snoise(temp1)*n_range;
  float n2 = snoise(temp2)*n_range;
  vec2 q = vec2(n1,n2);

  float d = 4.;
  vec2 temp3 = (p + q*d + vec2(1.7, 9.2))*factor;
  vec2 temp4 = (p + q*d + vec2(8.3, 2.8))*factor;
  float n3 = snoise(temp3)*n_range;
  float n4 = snoise(temp4)*n_range;
  vec2 r = vec2(n3,n4);

  float final = snoise((p+r*d)*factor)*n_range;
  return final;
}

vec2 int2pos(int i, vec2 size){
  float x = mod(float(i), size.x);
  float y = floor(float(i)/size.x);
  return vec2(x,y);
}

int pos2int(vec2 p, vec2 size){
  int i = int(p.x + (p.y * size.x))-int(size.x/2.);
  return i;
}

void main2() {
    vec2 textureSize = vec2(481.,680.);
    vec4 final_coord = vec4(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.z, gl_FragCoord[3]);
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    float data = snoise(st);
    float n = warp(final_coord.xy, .003, 615.);
    data = n;
    vec4 final_col = vec4(data, data, data,1.);
    gl_FragColor = final_col;
    final_col = vec4(1.);
    vec2 add = -vec2(fract(n/textureSize.x)*textureSize.x,floor(n/textureSize.x));
    vec2 coord = (vec2(st.x, st.y)+add);
    gl_FragColor= texture2D(u_texture_0, coord) * final_col;


    vec2 cool = final_coord.xy+.5;
    vec2 supercool = int2pos(int(add)*0+pos2int(cool, u_resolution), u_resolution);
    st = supercool.xy/u_resolution.xy;
    gl_FragColor = texture2D(u_texture_0, st);
}

void main3(){
  vec4 coord = vec4(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.z, gl_FragCoord[3]);
  vec2 st = coord.xy/u_resolution.xy;
  if (coord.x > 110.){st.x=1.;}
  gl_FragColor = texture2D(u_texture_0, st);
}

void main(){
  vec4 coord = vec4(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.z, gl_FragCoord[3]);
  vec2 st = coord.xy/u_resolution.xy;
  vec2 cool = coord.xy;
  int i = pos2int(cool, u_resolution);
  float n = warp(coord.xy, .001, 615.);
  i = i - int(n);
  vec2 supercool = int2pos(i, u_resolution);
  //if (supercool.x< u_time*100.){st.xy=vec2(0.);}
  //vec2 supercool = int2pos(i, u_resolution);
  st = supercool.xy/u_resolution.xy;
  float t =(-cool.x+supercool.x)/100.; 
  gl_FragColor = texture2D(u_texture_0, st);
  //gl_FragColor = vec4(n,n,n,1.);
}