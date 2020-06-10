precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main2() {
	vec2 uv = gl_FragCoord.xy/u_resolution.xy;
	vec2 center = vec2(.5, .5);
	float scale = 2.;
	const int iter = 5;
    vec2 z, c;

    c.x = 1.3333 * (uv.x - 0.5) * scale - center.x;
    c.y = (uv.y - 0.5) * scale - center.y;

    int count = 0;
    z = c;
    for(int i=0; i<iter; i++) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 4.0) break;
        z.x = x;
        z.y = y;
		count += 1;
    }

	float f = float(count)/5.;

    gl_FragColor = vec4(f, f, f, 1.);
}

void main() {
    vec2 uv = gl_FragCoord.xy/u_resolution.xy;
	vec2 center = vec2(.5, .5);
	float scale = 2.;
	const int iter = 30;
    vec2 z, c;
    z.x = 3.0 * (uv.x - 0.5);
    z.y = 2.0 * (uv.y - 0.5);

	c = vec2(sin(u_time), cos(u_time));

    int count = 0;
    for(int i=0; i<iter; i++) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 4.0) break;
        z.x = x;
        z.y = y;
		count +=1;
    }

	float f = float(count)/float(iter);
	float sm =  float(iter) 
	+ log(log(3.))/log(scale) 
	- log(log(dot(z,z)))/log(scale);
	sm = sm/50.;

    gl_FragColor = vec4(f, f, f, 1.);
    gl_FragColor = vec4(sm, sm, sm, 1.);
}