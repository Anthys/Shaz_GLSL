precision mediump float;

uniform vec2 resolution; // viewport resolution

const float epsilon = 0.0001; // minimum distance to consider an intersection
const int maxSteps = 256; // maximum number of steps to take
const float maxDistance = 10.0; // maximum distance to march before giving up

// camera parameters
const vec3 eye = vec3(0.0, 0.0, 2.0);
const vec3 view = vec3(0.0, 0.0, -1.0);
const float fov = 60.0; // field of view, in degrees

// 6th turn manifold mapping function
vec3 mapTo6thTurnManifold(vec3 point) {
  vec3 rotatedPoint = vec3(point.x, -point.z, point.y);
  vec3 mappedPoint = vec3(rotatedPoint.x * sqrt(3.0), rotatedPoint.y, rotatedPoint.z);
  return mappedPoint;
}

// returns the distance to the nearest point on the 6th turn manifold
float distanceTo6thTurnManifold(vec3 point) {
  vec3 mappedPoint = mapTo6thTurnManifold(point);
  float distance = length(mappedPoint) - 1.0;
  return distance;
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

  // transform the ray origin and direction to the 6th turn manifold space
  vec3 origin = mapTo6thTurnManifold(eye);
  vec3 dir = mapTo6thTurnManifold(direction);

  // march the ray through the scene
  float distance = 0.0;
  for (int i = 0; i < maxSteps; i++) {
    vec3 point = origin + dir * distance;
    float d = distanceTo6thTurnManifold(point);
    if (abs(d) < epsilon) {
      // intersection found
      gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
      return;
    }
    distance += d;
    if (distance > maxDistance) {
      // no intersection found
      break;
    }
  }
  gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}
