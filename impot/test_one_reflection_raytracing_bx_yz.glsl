precision mediump float;


#define MAX_STEPS 30
#define MAX_DIST 100.
#define SURF_DIST .01


uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float opRep( in vec3 p, float s )
{
    float a = sdBox(p, vec3(s*.5));
    vec3 p2 = p;
    p2.y += 1.;
    float b = sdSphere(p2, s*.5);
    float c = min(a, b);
    return c;
}

float getDist(vec3 p) {
    return opRep(p,0.5);
}

float rayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    float full_journey = dO;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p;
        
        float demi_size  = 1.;
        vec3 domain_box = vec3(demi_size);
        float t_cross = min(
            (domain_box.x-ro.x)/rd.x,
            min((domain_box.y-ro.y)/rd.y,
            (domain_box.z-ro.z)/rd.z)
        );
        if (dO >= t_cross){
            float delta_t = abs(dO-t_cross);
            p = ro + rd*t_cross;
            float theta = 3.14;
            p = mod(p+vec3(1.), domain_box*2.)-vec3(1.);
            ro = p;
            full_journey+= dO-delta_t;
            dO = delta_t;
            p += rd*delta_t;
        }
        else{
            p = ro + rd*dO;
        }
        float dS = getDist(p);
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) {
            break;
        };
    }
    full_journey += dO;
    
    return full_journey;
}

float smooth_square(float x){
    float eps = .5;
    return sin(x)/sqrt(sin(x)*sin(x)+eps);
}
void main()
{
    //float u_time = 2.;
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
    vec3 ro = vec3(0,0,0);
    ro.x += smooth_square(u_time);
    ro.z -= 2.;
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    float d = rayMarch(ro,rd);
    //vec3 p = ro + rd * d ;
    float dif = 1.0/(1.0+d*d*0.1);
    //dif = 1./d;
    vec3 col = vec3(dif*2.,dif/d*2.0,0);
    col = vec3(dif*2.,dif*2.,0);
    //float fog = 1.0 / 1.0 + d*d*0.1;
    //vec3 col  = vec3(fog) ;
    gl_FragColor = vec4(col,1.0);
}