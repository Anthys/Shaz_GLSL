precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_texture_3;
uniform sampler2D u_texture_4;

// FROM https://www.shadertoy.com/view/Md2GDw

void main(){
  vec4 coord = vec4(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.z, gl_FragCoord[3]);
  vec2 uv = gl_FragCoord.xy/u_resolution.xy;
  vec2 block = floor(gl_FragCoord.xy/vec2(16));
  vec2 uv_noise = block /vec2(64);
  uv_noise += floor(vec2(u_time)*vec2(1234.0,3543.0)) /vec2(64);

  float block_thresh = pow(fract(u_time*1236.0453), 2.0)*0.2;
	float line_thresh = pow(fract(u_time * 2236.0453), 3.0) * 0.7;


  vec2 uv_r = uv, uv_g = uv, uv_b =uv;

  // glitch some blocks and lines
  if (texture2D(u_texture_4, uv_noise).r < block_thresh ||
      texture2D(u_texture_4, vec2(uv_noise.y, 0.0)).g < line_thresh){
        vec2 dist = (fract(uv_noise) -.5)*.3;
        uv_r += dist*.1;
        uv_r += dist*.2;
        uv_r += dist*.125;
      }

  gl_FragColor = vec4(1.,1.,1.,1.);
  gl_FragColor.r = texture2D(u_texture_3, uv_r).r;
  gl_FragColor.g = texture2D(u_texture_3, uv_g).g;
  gl_FragColor.b = texture2D(u_texture_3, uv_b).b;

  // loose luma for some blocks

  if (texture2D(u_texture_4, uv_noise).g < block_thresh)
    gl_FragColor.rgb = gl_FragColor.ggg;
  
  // discolor block lines
  if (texture2D(u_texture_4, vec2(uv_noise.y, 0.0)).b * 3.5 < line_thresh)
    gl_FragColor.rgb = vec3(.0, dot(gl_FragColor.rgb, vec3(1.0)), .0);

  // interleave linees in some blocks

  if (texture2D(u_texture_4, uv_noise).g * 1.5 < block_thresh ||
		texture2D(u_texture_4, vec2(uv_noise.y, 0.0)).g * 2.5 < line_thresh) {
		float line = fract(gl_FragCoord.y / 3.0);
		vec3 mask = vec3(3.0, 0.0, 0.0);
		if (line > 0.333)
			mask = vec3(0.0, 3.0, 0.0);
		if (line > 0.666)
			mask = vec3(0.0, 0.0, 3.0);
		gl_FragColor.xyz *= mask;
	}

}

