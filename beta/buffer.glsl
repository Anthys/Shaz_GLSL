#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif


// Wave Interference by feliposz (2017-10-02)

// Entanglement Mods by sphinx

uniform float u_time;
uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform sampler2D renderbuffer;
uniform sampler2D u_renderbuffer;
uniform sampler2D u_texture_0;
uniform sampler2D u_texture_1;
uniform sampler2D u_buffer0;
uniform sampler2D u_buffer1;

#if defined(u_time)

void main() 
{
	vec4 bufferr = texture2D(u_buffer0,gl_FragCoord.xy/u_resolution);
	//vec4 bufferr = vec4(0);
	vec4 color = vec4(1.,0.,0.,1.);
	gl_FragColor = bufferr+vec4(.01,.01,.01,.1);
	gl_FragColor = bufferr+color;
}


#else

void main() 
{
	vec4 bufferr = texture2D(u_buffer0,gl_FragCoord.xy/u_resolution);
	//vec4 bufferr = vec4(0);
	vec4 color = vec4(.3,0.,0.,1.);
	gl_FragColor = bufferr+vec4(.01,.01,.01,.1);
	gl_FragColor = bufferr + color;
	
}

#endif