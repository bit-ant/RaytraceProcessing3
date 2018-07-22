int frameHeight = 500;
int frameWidth = 500;
float cameraX = 250.0;
float cameraY = 250.0;
float cameraZ = 0.0;
float screenZ = 100.0; // frustum "near"
int numOfSpheres = 500;

void setup() 
{
  size(500, 500, P3D); // 500px X 500px window with P3D renderer
  noLoop();
}

void draw() 
{
  Sphere[] spheres = new Sphere[numOfSpheres];
  for (int i = 0; i < numOfSpheres; ++i)
  {
    Sphere sphere = new Sphere(random(-600, 600), random(-600, 600), 110.0, 5.0);
    spheres[i] = sphere;
  }
  
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
