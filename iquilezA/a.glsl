// INIT GLSL

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main()
{
    vec2 p = gl_FragCoord.xy / u_resolution.xy;
    vec2 q = p - vec2(.33, .5);

    vec3 col = vec3(1, .4, .3);
    float r = .2 + .1*cos(atan(q.y, q.x)*10.0 + 20.0*q.x + 1.0);
    col *= smoothstep(r, r+.01, length(q));
    
    r = .015;
    r += .002*cos(120.0*q.y);
    r += exp(-40.0*p.y);
    col *= 1.0-(1.0-smoothstep(r, r+0.002, abs(q.x - .25*sin(2.0*q.y))))*(1.0-smoothstep(0.0, .1, q.y));
    
    gl_FragColor = vec4(col,1.0);
}