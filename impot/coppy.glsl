precision mediump float;


#define MAX_STEPS 30
#define MAX_DIST 100.
#define SURF_DIST .01


uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
void main()
{
    vec2 C = gl_FragCoord.xy;
    vec4 O;
    O=vec4(0);
    float iTime = u_time;
    vec3 p,q,r=u_resolution.xyx,d=normalize(vec3((C-.5*r.xy)/r.y,2));  
    float s=1.5;
    float e=1.5;
    float g=1.5;
    for(float i=0.; i<90.; i+=1.){
        O.xyz+=.1*mix(vec3(1),H(log(s)*.3),.8)*exp(-12.*i*i*e);
        p=g*d-vec3(-.2,.3,2.5);
        p=R(p,normalize(vec3(1,2.*sin(iTime*.1),3)),iTime*.2);
        q=p;
        s=5.;
        p=p/dot(p,p)+1.;
        for(int i=0;i<8;i++){
            p*=e;
            p=1.-abs(p-1.);
        }
        s*=e=1.6/min(dot(p,p),1.5);
        g+=e=length(cross(p,normalize(vec3(1))))/s-5e-4;
    }
    gl_FragColor = O;
}