precision mediump float;


#define MAX_STEPS 40
#define MAX_DIST 100.
#define SURF_DIST .01


uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float sdCone( vec3 p, vec2 c, float h )
{
    p = -p + vec3(0,-.1,0.);
    float q = length(p.xz);
    return max(dot(c.xy,vec2(q,p.y)),-h-p.y);
}


float sd_rec( vec3 p, vec3 b )
{  
    //p.y=-p.y;
    vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdArrow( vec3 p)
{
    p.y += .2*u_time;
    p = mod(p+vec3(.5), vec3(1))-vec3(.5);
    return min(sdCone(p, vec2(.9,.9), .05), sd_rec(p, vec3(0.04)));
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
    float triangle = sdCone(p, vec2(.9,.9), .05);
    float arrow = sdArrow(p);
    d = min(d, e*10.);
    d = min(a,e);
    d = min(d, triangle);
    d = min(arrow, e);
    return d;
}


float opRep( in vec3 p, in vec3 c , float s )
{
    vec3 q = mod(p+0.5*c,c)-0.5*c;
    //if (int(mod(p.z/.5,2.))==1){
    //if (int(mod(p.z,2.))==1){
    //if (p.z<2.4){
        //s=.0001;
    float n = float(int(mod(p.z+.5, 4.)));
    float angle = 3.14/2.*n;
    float temp = cos(angle)*q.x - sin(angle)*q.y;
    q.y = sin(angle)*q.x + cos(angle)*q.y;
    q.x = temp;
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
    mat2 mat = mat2(vec2(cos(u_time*speed), sin(u_time*speed)), 		// first column (not row!)    
             		vec2(-sin(u_time*speed), cos(u_time*speed)));
    uv = mat*uv ;
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