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
    float c = min(a, b+100.);
    return c;
}

float getDist(vec3 p) {
    return opRep(p,0.5);
}

vec3 bringback(vec3 p){
    float smallest_dist = length(p);
    float full_size  = 2.;
    const int n_gens = 6;
    vec3 generators[6];
    generators[5] = vec3(p.x, p.y, p.z-full_size);
    generators[4] = vec3(p.x, p.y, p.z+full_size);
    generators[3] = vec3(p.x-full_size, p.y, p.z);
    generators[2] = vec3(p.x+full_size, p.y, p.z);
    generators[1] = vec3(p.x, p.y+full_size, p.z);
    generators[0] = vec3(p.x, p.y-full_size, p.z);

    vec3 outv = p;

    for (int j = 0; j<n_gens;j++){
        vec3 q = generators[j];
        if (length(q) < smallest_dist){
            outv = q;
            smallest_dist = length(q);
        }
    }

    return outv;

}

float rayMarch(vec3 ro, vec3 rd) {
	float dt=0.;
    float full_journey = 0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p;
        

        p = ro + rd*dt;
        float smallest_dist = length(p);
        
        ro = bringback(p);
        ro = bringback(ro);
        // I pass two times to cover the cases where the ray crosses two domains
        // For them,  applying the generators only once isn't enough
        // vraiment pas beau

        dt = getDist(ro);
        full_journey += dt;
        if(full_journey>MAX_DIST || dt<SURF_DIST) {
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
    //float u_time = 2.;
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
    vec3 ro = vec3(0,0,0);
    ro.x += smooth_square(u_time);
    ro.z -= 1.5;
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