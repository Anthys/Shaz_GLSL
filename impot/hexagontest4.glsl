precision mediump float;


#define MAX_STEPS 20
#define MAX_DIST 100.
#define SURF_DIST .01


uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float sd_rec( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float HexDist(vec2 p) {
	p = abs(p);
    
    float c = dot(p, normalize(vec2(1,1.73)));
    c = max(c, p.x);
    
    return c;
}
vec4 HexCoords(vec2 uv) {
	vec2 r = vec2(1, 1.73);
    vec2 h = r*.5;
    
    vec2 a = mod(uv, r)-h;
    vec2 b = mod(uv-h, r)-h;
    
    vec2 gv = dot(a, a) < dot(b,b) ? a : b;
    
    float theta = atan(gv.y, gv.x);
    float rho = HexDist(gv);
    float x = rho*cos(theta);
    float y = rho*sin(theta);
    x = gv.x;
    y = gv.y;
    vec2 id = uv-gv;
    return vec4(x, y, id.x,id.y);
}


void main()
{
    vec3 col;
    float u_time = 1.;
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
    uv = uv*10.;
    vec4 result = HexCoords(uv.xy);
    col = vec3(result.z/4., result.w/4.,result.x);
    float size_square = .2;
    float c1 = 1.-sign(sd_rec(vec3(result.xy, 0.), vec3(size_square)));
    float c2 = 1.-sign(sd_rec(vec3(uv.xy, 0.), vec3(size_square)));
    col = vec3(mix(c1, c2, sin(u_time)));
    col = mix(col, vec3(result.x*1.7+1.,result.w,1.), .3);
    if (int(result.x*100.)==int(result.y*100.)){
        col = vec3(1.); // draw y=x to see if line is straight
    }
    gl_FragColor = vec4(col,1.0);
}