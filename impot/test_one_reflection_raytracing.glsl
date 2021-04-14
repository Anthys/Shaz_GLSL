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

float opRep( in vec3 p, float s )
{
    float a = sdSphere(p, s);
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
    	vec3 p = ro + rd*dO;
        
        float plan_z0 = 0.;
        float t_cross = (plan_z0-ro.z)/rd.z;
        if (dO > t_cross){
            float delta_t = abs(dO-t_cross);
            p = ro + rd*t_cross;
            p.z = -2.;
            ro = p;
            full_journey+= dO;
            dO = delta_t;
            p += rd*delta_t;
        }
        float dS = getDist(p);
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) {
            full_journey += dO;
            break;
        };
    }
    
    return full_journey;
}

float smooth_square(float x){
    float eps = .5;
    return sin(x)/sqrt(sin(x)*sin(x)+eps);
}
void main()
{
    //float u_time = 3.;
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
    vec3 ro = vec3(0,0,0);
    ro.x += smooth_square(u_time);
    ro.z -= 4.;
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    float d = rayMarch(ro,rd);
    //vec3 p = ro + rd * d ;
    float dif = 1.0/(1.0+d*d*0.1);
    vec3 col = vec3(dif*2.,dif/d*2.0,0);
    //float fog = 1.0 / 1.0 + d*d*0.1;
    //vec3 col  = vec3(fog) ;
    gl_FragColor = vec4(col,1.0);
}