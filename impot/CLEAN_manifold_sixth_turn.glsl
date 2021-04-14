// INIT GLSL

precision mediump float;

#define MAX_STEPS 40
#define MAX_DIST 100.
#define SURF_DIST .01
#define PI 3.14

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


float HexDist(vec2 p) {
    // Compute the distance to a hexagon centered on the origin

	p = abs(p);
    float c = dot(p, normalize(vec2(1,1.73)));
    c = max(c, p.x);
    
    return c;
}

vec4 HexCoords(vec2 uv) {
    // Input: Global uv coordinates
    // Output:
    // xy : Local coordinates inside the hexagon, the center is the origin
    // zw: index of the hexagon on the grid

	vec2 r = vec2(1, 1.73);
    vec2 h = r*.5;
    
    vec2 a = mod(uv, r)-h;
    vec2 b = mod(uv-h, r)-h;
    
    vec2 gv = dot(a, a) < dot(b,b) ? a : b;
    vec2 id = uv-gv;

    return vec4(gv.x, gv.y, id.x,id.y);
}

float sdCone( vec3 p, vec2 c, float h ){
    // SDF for a cone
    // https://www.iquilezles.org/

    p = -p + vec3(0,-.1,0.);
    float q = length(p.xz);
    return max(dot(c.xy,vec2(q,p.y)),-h-p.y);
}


float sd_rec3( vec3 p, vec3 b ){
    // SDF for a cuboid
    // https://www.iquilezles.org/

    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdArrow( vec3 p)
{
    // SDF for an arrow

    p.y += .2*u_time; // arrow movement

    // q is the vector of p modulo the hexagonal prisms
    // it is driven back inside the original prism, which is mirrored everywhere
    // If the arrow wasn't moving, this would be useless, it is here to ensure that 
    // the transitions between the spaces are smooth
    vec3 q;
    vec4 hxcoords = HexCoords(p.xy); 
    q.xy = hxcoords.xy*.5;
    q.z = mod(p.z+5., .5)-.5;

    return min(sdCone(q, vec2(.9,.9), .05), sd_rec3(q, vec3(0.04)));
}



float sd_rec( vec3 p, vec3 b , vec3 shift)
{  
    // SDF for a box
    p += shift;
    vec3 q1;
    vec4 cool = HexCoords(p.xy);
    q1.xy = cool.xy*.5;
    q1.z = mod(p.z+5., .5)-.5;
    vec3 q = abs(q1) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdCenterBox( vec3 p, vec3 b, float e )
{   
    // SDF for the central box
    // Although there is no center
    vec3 size_box = vec3(.01);
    float pointA = sd_rec(p, size_box, vec3(0));
    return pointA;
}

float sdScene( vec3 p)
{  
    // Apply all sdfs
    float a = sdArrow(p);
    float e = sdCenterBox(p, vec3(.0195), .001);
    return min(a,e);
}

float getDist( in vec3 p)
{
    //Transforms the raymarching vector before applying the SDFs

    // Getting the vector back inside the original prism
    vec3 q;
    vec4 hxcoord = HexCoords(p.xy);
    q.xy = hxcoord.xy;
    q.z = p.z;
    
    // Rotation of PI/3 for each reflexion in the Z axis
    float n = float(int(mod(p.z*2., 6.))); // index of the reflexion in the z axis
    float angle = PI/3.*n;

    // Vector rotation
    float temp = cos(angle)*q.x - sin(angle)*q.y;
    q.y = sin(angle)*q.x + cos(angle)*q.y;
    q.x = temp;

    return sdScene(q);
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
    //float u_time = 3.; // freezes time 
    float zoom = 1.;

    vec2 uv = (gl_FragCoord.xy-.5*u_resolution.xy)/u_resolution.y;
	uv  = zoom*uv;
    
    vec3 ro = vec3(0,0,.1);
    ro.x += u_time*.5;
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    float d = rayMarch(ro,rd);
    
    float dif = 1.0/(1.0+d*d*0.1);
    vec3 col = vec3(dif*2.,dif/d*2.0,0);
    //float fog = 1.0 / 1.0 + d*d*0.1;
    //col  = mix(col, vec3(fog), .2) ;
    gl_FragColor = vec4(col,1.0);
}