int frameHeight = 500;
int frameWidth = 500;

float cameraX = 250.0;
float cameraY = 250.0;
float cameraZ = 0.0;

float screenZ = 100.0; // frustum "near"

float lightSourceX = 200;
float lightSourceY = 180;
float lightSourceZ = 110;

int numOfSpheres = 500;

void setup() 
{
  size(500, 500, P3D); // 500px X 500px window with P3D renderer
  noLoop();
}

void draw() 
{
  long startTime = System.nanoTime(); // Measure rendering time
  
  // Create random spheres
  Sphere[] spheres = new Sphere[numOfSpheres];
  for (int i = 0; i < numOfSpheres; ++i)
  {
    Sphere sphere = new Sphere(random(-600, 600), random(-600, 600), random(80.0, 120.0), 5.0);
    spheres[i] = sphere;
  }
  
  RayTracer myRayTracer = new RayTracer(frameHeight, frameWidth, cameraX, cameraY, cameraZ, screenZ, lightSourceX, lightSourceY, lightSourceZ, spheres);
  myRayTracer.render(); //<>//
  
  long timeNeeded = System.nanoTime() - startTime;
  println("Frame rendered in "+ timeNeeded + " nanoseconds.");
}
