int frameHeight = 200;
int frameWidth = 200;
float cameraX = 100.0;
float cameraY = 100.0;
float cameraZ = 0.0;
float screenZ = 100.0; // frustum "near"

void setup() 
{
  size(200, 200, P3D); // 500px X 500px window with P3D renderer
  //frustum(-10, 0, 0, 10, 10, 200);
}

void draw() 
{
  Sphere sphere = new Sphere(100.0, 150.0, 80.0, 50.0);
  Sphere[] spheres = new Sphere[1];
  spheres[0] = sphere;
  
  RayTracer myRayTracer = new RayTracer(frameHeight, frameWidth, cameraX, cameraY, cameraZ, screenZ, spheres);
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
