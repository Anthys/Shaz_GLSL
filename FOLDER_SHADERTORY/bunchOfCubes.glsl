// "RayMarching starting point" 
// by Martijn Steinrucken aka The Art of Code/BigWings - 2020
// The MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// Email: countfrolic@gmail.com
// Twitter: @The_ArtOfCode
// YouTube: youtube.com/TheArtOfCodeIsCool
// Facebook: https://www.facebook.com/groups/theartofcode/
//
// You can use this shader as a template for ray marching shaders

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001
#define TAU 6.283185
#define PI 3.141592
#define S smoothstep
#define T iTime

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 s, vec3 boxPos) {
    p = p - boxPos;
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

float sdSphere(vec3 p, float s, vec3 sphPos) {
    p = p - sphPos;
    return length(p)-s;
}


float SIZECUBE = 1.0;
float SPACE_BETWEEN_CUBES = 0.0;

float SIZECELL(){
    return SIZECUBE + SPACE_BETWEEN_CUBES;
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 getCubePos(vec3 p){
    // return cube pos under virtual position p
    float cx = floor(p.x/(SIZECELL()))*SIZECELL() + SIZECELL()/2.0;
    float cz = floor(p.z/(SIZECELL()))*SIZECELL();// + SIZECELL()/2.0;
    float rPhase = TAU*rand(vec2(cx, cz));
    float rVelocity = 1.0*rand(vec2(cx, cz))+1.0;
    float cy = cos(iTime*rVelocity + rPhase)*.3;
    if (p.y<0.0){
    return vec3(cx, cy-2.0, cz);
    }
    return vec3(cx, cy+2.0, cz);
}
float DIST_WALL = 5.0;

float GetDist2(vec3 p, vec3 spPos) {
    //vec3(60.0,3,10)
    float d1 = sdSphere(p, 20.0, spPos);
    return d1;
}


float GetDist(vec3 p) {
    float d1 = sdBox(p, vec3(SIZECUBE/2.0), getCubePos(p));
    float d2 = sdBox(p, vec3(SIZECUBE/2.0), getCubePos(vec3(p.x+SIZECELL(), p.y, p.z)));
    float d3 = sdBox(p, vec3(SIZECUBE/2.0), getCubePos(vec3(p.x-SIZECELL(), p.y, p.z)));
    float d4 = sdBox(p, vec3(SIZECUBE/2.0), getCubePos(vec3(p.x, p.y, p.z+SIZECELL())));
    float d5 = sdBox(p, vec3(SIZECUBE/2.0), getCubePos(vec3(p.x, p.y, p.z-SIZECELL())));
    float d6 = 100.0;
    if (p.z>DIST_WALL-.5){
        d6 = DIST_WALL-p.z;
    }else if (p.z<-DIST_WALL+.5){
        d6 = DIST_WALL+p.z;
    }
    float d = min(d1, min(d2, min(d3, min(d4, min(d5, d6)))));
    return d;
}

int GROUP_SIZE = 50;

float RayMarch2(vec3 ro, vec3 rd, float posLight, vec3 posTapped) {
// posTapped is the position where the ray touched the surface (black)
	float dO=0.;
    float LENGTH_GROUP = float(GROUP_SIZE)*SIZECELL();
    float char = posLight + LENGTH_GROUP/2.0;
    float iBlock = floor((posTapped.x-char+LENGTH_GROUP/2.0)/LENGTH_GROUP);
    vec3 spPos = vec3(60.0 + LENGTH_GROUP*iBlock+posLight,3,10);
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist2(p, spPos);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    //return iBlock/5.0;
    
    return dO;
}


float RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    
    return dO;
}

vec3 GetNormal(vec3 p) {
    vec2 e = vec2(.001, 0);
    vec3 n = GetDist(p) - 
        vec3(GetDist(p-e.xyy), GetDist(p-e.yxy),GetDist(p-e.yyx));
    
    return normalize(n);
}

vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
    vec3 
        f = normalize(p),
        r = normalize(cross(vec3(0,sin(iTime/3.0),cos(iTime/3.0)), f)),
        u = cross(f,r),
        c = f*z,
        i = c + uv.x*r + uv.y*u;
    return normalize(i);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
	vec2 m = iMouse.xy/iResolution.xy;

    vec3 ro = vec3(0.0, 0, 0);
    ro.yz *= Rot(-m.y*PI+1.);
    ro.xz *= Rot(-m.x*TAU);
    ro.x = iTime*10.0;
    //ro.x = 1.0;
    
    vec3 rd = GetRayDir(uv, ro, vec3(0,0.,0), 1.);
    vec3 col = vec3(0);
   
    float d = RayMarch(ro, rd);

    if(d<MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        float cx = floor((p.x+sign(p.x)*.001)/SIZECELL());
        float cz = floor((p.z+sign(p.z)*.001)/SIZECELL() + SIZECELL()/2.0);
        /*float sinusColor = .5+.5*sin(p.x/5.0+iTime*1.0);
        float v = 5.0;
        float sinusColor2 = floor(sinusColor*v)/v;
        vec3 localCol = vec3(mod(cx, 2.0)/2.0*0.0, sinusColor/2.0, sinusColor);*/
        
        
        float LENGTH_GROUP = float(GROUP_SIZE)*SIZECELL();
        float posLight1 = -iTime*10.0;
        float posLocalLight1 = mod(posLight1, LENGTH_GROUP);
            
        //float iGroup = floor(p.x/LENGTH_GROUP);
        //float iLight = floor((p.x+posXLight1+LENGTH_GROUP/2.0)/LENGTH_GROUP);
        float char = posLight1;
        float iBlock = floor((p.x-char+LENGTH_GROUP/2.0)/LENGTH_GROUP);
        float localGroupPos = mod(p.x, LENGTH_GROUP);
        //float toAdd = LENGTH_GROUP/2.0-localGroupPos; // Distance to add to get light in local frame (around local cube)
        //float localPosXLight1 = mod(posLocalLight1 + toAdd, LENGTH_GROUP) -toAdd;
        float localPosXLight1 = mod(posLight1 - p.x + LENGTH_GROUP/2.0, LENGTH_GROUP);
        vec3 localLightPos1 = vec3(localPosXLight1 , 0.0, DIST_WALL);
        //vec3 localLightPos1Next = vec3(posXLight1 + LENGTH_GROUP , 0.0, DIST_WALL);
        vec3 localLightDir1 = vec3(LENGTH_GROUP/2.0, p.y, p.z) - localLightPos1;
        //vec3 localLightDir1Next = vec3(localGroupPos, p.y, p.z) - localLightPos1Next;
        
        float dot1 = dot(n, normalize(-localLightDir1));//*.5+.5;
        //float dif2 = dot(n, normalize(-localLightDir1));//*.5+.5;
        //float dif = (dif1+dif2)/2.0;
        //float dif = 1.0/(1.0+d*d*0.1);
        //col = vec3(dif*2.,dif/d*2.0,0);
        float dif = 0.0;
        float dif1 = 0.0;
        /*if (dif1 >0.0){
            dif = float(20.0-length(localLightDir1))/10.0;
        }else{
            dif = float(20.0-length(localLightDir1))/10.0*.2;
        }*/
        float difTowardsLight = float(20.0-length(localLightDir1))/10.0;
        float difOppositeLight = 0.0*float(20.0-length(localLightDir1))/10.0*.2;
        float vv = 1.0;
        dif = (smoothstep(-.5, .5, dot1)*.8+.2)*difTowardsLight;//dif1+.5);
        //dif = step(0.0, dot1)*difTowardsLight;
        //dif += step(0.0,-dot1)*difTowardsLight*.2;
        //dif = dot1;
                
        /*if (p.z>DIST_WALL-.5){
            col = vec3(abs(localGroupPos-localPosXLight1)/100.0);
        }else{
        col = vec3(.5)*dif;
        }*/
        vec3 col1 = vec3(.3, (cos(iTime+iBlock*2.0)*.5+.5)*.7+.3, (cos(iTime+30.0)*.5+.5)*.3+.7)*dif;
        d = RayMarch2(ro, rd, posLight1, p);
        vec3 col2 = vec3(1000.0/(d*d));
        //col2 = vec3(1.0-d);
        float vvv = smoothstep(-.05, .05, dif);
        col = vvv*col1 + (1.0-vvv)*col2;
        //if (dif<=0.0){
            //col = vec3(d/100.0);
        //}
        //col = vec3(d/100.0);
        //col = col1;
    }
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    fragColor = vec4(col,1.0);
}