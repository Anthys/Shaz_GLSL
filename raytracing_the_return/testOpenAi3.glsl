precision mediump float;

uniform vec2 resolution; // viewport resolution

const float epsilon = 0.0001; // minimum distance to consider an intersection
const int maxSteps = 256; // maximum number of steps to take
const float maxDistance = 10.0; // maximum distance to march before giving up

// camera parameters
const vec3 eye = vec3(0.0, 0.0, 2.0);
const vec3 view = vec3(0.0, 0.0, -1.0);
const float fov = 60.0; // field of view, in degrees

// returns the distance to the nearest point on the cube
float distanceToCube(vec3 point) {
  vec3 d = abs(point) - vec3(1.0);
  float inside = length(max(d, 0.0));
  float outside = min(max(d.x, max(d.y, d.z)), 0.0);
  return inside + outside;
}

void main() {
  // generate ray direction from viewport coordinates
  vec2 uv = gl_FragCoord.xy / resolution;
  uv = uv * 2.0 - 1.0;
  uv.x *= resolution.x / resolution.y;
  float aspectRatio = resolution.x / resolution.y;
  float y = tan(radians(fov) / 2.0);
  float x = y * aspectRatio;
  vec3 direction = normalize(vec3(x * uv.x, y * uv.y, 1.0));

  // march the ray through the scene
  float distance = 0.0;
  for (int i
