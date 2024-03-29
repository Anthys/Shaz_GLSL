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
    
    float theta = atan(gv.y, gv.x);
    float rho = HexDist(gv);
    float x = rho*cos(theta);
    float y = rho*sin(theta);
    vec2 id = uv-gv;
    return vec4(x, y, id.x,id.y);
}


float sd_rec( vec3 p, vec3 b )
{  
    //p.y += 1.*sin(u_time*.2);
    //p.y += .2*u_time;
    //p.x += u_time*.5;
    //p.x += .3;
    //p.y += .2;
    //if (int(mod(p.z/.5,1.))==0){
    //vec4 cool = HexCoords(p.xy);
    //p = mod(p+vec3(.5), vec3(1))-vec3(.5);
    //p.xy = cool.xy;
    //p.y=-p.y;
    vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere2( vec3 p, vec3 b )
{
    p.y += .2;
  return sin(length(p)) - b.x  ;
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
    //p.x += u_time*.5;
    p = mod(p+vec3(.5), vec3(1))-vec3(.5);
  p = abs(p)  -b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float sdSphere( vec3 p, vec3 b )
{  
    float a = sd_rec(p, b);
    float c = sdSphere2(p, b);
    float e = sdBoxFrame(p, vec3(.5), .001);
    float d = min(a,c);
    d = min(d, e*10.);
    d = min(a,e+100.);
    return d;
}

float opRep( in vec3 p, in vec3 c , float s )
{
    //vec3 q = mod(p+0.5*c,c)-0.5*c;
    vec3 q;
    vec4 cool = HexCoords(p.xy);
    q.xy = cool.xy;
    q.z = mod(p.z+5., .5)-.5;
    return sdSphere(q,vec3(s,s,s));
}

float getDist(vec3 p) {
    return opRep(p,vec3(1,1,1),0.04);
}
float rayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = getDist(p);
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) break;
    }
    
    return dO;
}

void main()
{
    //float u_time = 0.;
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
    float speed = 0.05 ; 
    //mat2 mat = mat2(vec2(cos(u_time*speed), sin(u_time*speed)), 		// first column (not row!)    
    //         		vec2(-sin(u_time*speed), cos(u_time*speed)));
    //uv = mat*uv ;
	uv  = 14.*uv;
    vec3 ro = vec3(0,0,.1);
    ro.x += u_time*.5;
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    float d = rayMarch(ro,rd);
    //vec3 p = ro + rd * d ;
    float dif = 1.0/(1.0+d*d*0.1);
    vec3 col = vec3(dif*2.,dif/d*2.0,0);
    //float fog = 1.0 / 1.0 + d*d*0.1;
    //vec3 col  = vec3(fog) ;
    gl_FragColor = vec4(col,1.0);
}