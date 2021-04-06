precision mediump float;


#define MAX_STEPS 20
#define MAX_DIST 100.
#define SURF_DIST .01


uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

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
    
    float x = atan(gv.x, gv.y);
    float y = .5-HexDist(gv);
    vec2 id = uv-gv;
    return vec4(x, y, id.x,id.y);
}

float sd_rec( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

void main()
{
    vec3 col;
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
    uv = uv*10.;
    vec4 result = HexCoords(uv.xy);
    col = vec3(result.z/4., result.w/4.,(1.-result.y)*cos(result.x));
    
    gl_FragColor = vec4(col,1.0);
}