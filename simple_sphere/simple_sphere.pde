int frameHeight = 200;
int frameWidth = 200;
float cameraX = 100.0;
float cameraY = 100.0;
float cameraZ = 0.0;

void setup() 
{
  size(200, 200, P3D); // 500px X 500px window with P3D renderer
}

void draw() 
{
  Sphere sphere = new Sphere(100.0, 100.0, -160.0, 80.0);
  Sphere[] spheres = new Sphere[1];
  spheres[0] = sphere;
  
  RayTracer myRayTracer = new RayTracer(frameHeight, frameWidth, cameraX, cameraY, cameraZ, spheres);
  myRayTracer.render();
  
  for (int y = 0; y < frameHeight; ++y) {
    for (int x = 0; x < frameWidth; ++x) {
      float r = myRayTracer.frameBuffer[x][y].rgbValues.x;
      float g = myRayTracer.frameBuffer[x][y].rgbValues.y;
      float b = myRayTracer.frameBuffer[x][y].rgbValues.z;
      stroke(r, g, b);
      point(x, y); //<>//
    }
  }
}
