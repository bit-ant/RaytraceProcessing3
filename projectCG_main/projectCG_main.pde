int frameHeight = 500;
int frameWidth = 500;

float cameraX = 250.0;
float cameraY = 250.0;
float cameraZ = 0.0;

float screenZ = 100.0; // frustum "near"

float lightSourceX = 250;
float lightSourceY = 180;
float lightSourceZ = 1980;

int numOfSpheres = 500;

String normalPlanet = "normal-planet.jpg";
String normalMoon = "normal-moon.jpg";
String normalGlace = "normal-glace.jpg";
String normalMotif = "normal-motif.jpg";
String normalJupiter = "normal-jupiter.jpg";
String normalLeather = "normal-leather.jpg";

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
    Sphere sphere = new Sphere(random(-600, 600), random(-600, 600), random(80.0, 200.0), 10.0);
    spheres[i] = sphere;
  }
  
  //// Create sphere at center
  //Sphere[] spheres1 = new Sphere[1];
  //Sphere sphere = new Sphere(250, 250, 110, 100.0);
  //spheres1[0] = sphere;
  
  RayTracer myRayTracer = new RayTracer(frameHeight, frameWidth, cameraX, cameraY, cameraZ, screenZ, lightSourceX, lightSourceY, lightSourceZ, spheres, normalGlace);
  myRayTracer.renderScene();
  
   // Show on screen
  for (int y = 0; y < frameHeight; ++y)
  {
    for (int x = 0; x < frameWidth; ++x) 
    {
      float intensity = myRayTracer.frameBuffer[x][y];
      stroke(intensity);
      point(x, y);
    }
  }
  
  long timeNeeded = System.nanoTime() - startTime;
  println("Frame rendered in "+ timeNeeded + " nanoseconds.");
}
