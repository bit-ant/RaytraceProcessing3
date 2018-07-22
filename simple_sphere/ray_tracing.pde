class RayTracer
{
  FragmentColor[][] frameBuffer;
  float[][] zbuffer;
  int bufferHeight;
  int bufferWidth;
  PVector cameraPos;
  Sphere[] spheresToDraw;
  
  RayTracer(int bufferHeight, int bufferWidth, float camX, float camY, float camZ, Sphere[] spheres)
  {
    this.bufferHeight = bufferHeight;
    this.bufferWidth = bufferWidth;
    frameBuffer = new FragmentColor[bufferWidth][bufferHeight];
    cameraPos = new PVector(camX, camY, camZ);
    spheresToDraw = spheres;
    
    // Init framebuffer to black
    FragmentColor black = new FragmentColor(0, 0, 0);
    for (int h = 0; h < bufferHeight; ++h)
    {
      for (int w = 0; w < bufferWidth; ++w)
      {
            frameBuffer[w][h] = black;
      }
    }
  }
  
  Ray createPrimaryRay(float h /* heigth */, float w /* width */)
  {
    float pixelCenterX = (w + 0.5);
    float pixelCenterY = (h + 0.5);
    Ray primRay = new Ray();
    primRay.origin = cameraPos;
    float aspectRatio = bufferWidth / bufferHeight;
    primRay.direction = new PVector((pixelCenterX - cameraPos.x) * aspectRatio, pixelCenterY - cameraPos.y, 100 - cameraPos.z);
    //primRay.direction = new PVector(pixelCenterX, pixelCenterY, -1);
    primRay.direction.normalize(); // This will make calculations (and our life) easier
    
    return primRay;
  }
  
  // For analytic solution, we calculate the intersection of the ray //
  // and the sphere using their parametric forms.                    //
  // For ray: p(t) = o + t*d                                         //
  // For sphere: (p-c)^2 - r^2 = 0                                   //
  // The interection point is found by: (o + t*d - c)^2 - r^2 = 0    //
  // So d^2t^2 - 2 * (o - c) * d * t + (o - c)^2 - r^2 = 0           //
  // The solution can thus be found by solving this quadric equation //
  // according to t.                                                 //
  // Let a,b,c be the variables of the discriminant = b^2 - 4*a*c    //
  
  float intersectSphere(Ray ray, Sphere sphere)
  {  
    float t = -1; // This will hold the intersection point. Negative value will mean that no intersection was found if front of the camera.
    
    PVector origin = new PVector(ray.origin.x, ray.origin.y, ray.origin.z);              // Deep copy needed to keep original vectors intact
    PVector direction = new PVector(ray.direction.x, ray.direction.y, ray.direction.z);
    
    PVector rayOrigToSphereCent = origin.sub(sphere.center); // o - c , calculate now because we'll need it more than once below
    float a = direction.dot(direction); // a = d^2;
    float b = -2 * rayOrigToSphereCent.dot(direction); // b = -2 * (o - c) * d
    float c = rayOrigToSphereCent.dot(rayOrigToSphereCent) - pow(sphere.radius, 2); // c = (o - c)^2 -r^2
    
    float discriminant = calculateDiscriminant(a, b, c);
    
    if (discriminant < 0)
    {
      // No solution to quadric equation, so no intersection :(
    }
    else if (0 == discriminant)
    {
      // One solution
      t = -b / (2 * a);
    }
    else
    {
      // Two solutions, keep the one closer to the camera
      float x0 = (-b + sqrt(discriminant)) / (2 * a);
      float x1 = (-b - sqrt(discriminant)) / (2 * a);
      
      t = (x0 > x1) ? x0 : x1;
    }
    return t;
  }

  void render() 
  {
    for (int h = 0; h < bufferHeight; ++h)
    {
      for (int w = 0; w < bufferWidth; ++w)
      {
        Ray primRay = createPrimaryRay(h, w);
        for (int s = 0; s < spheresToDraw.length; ++s)
        {
          float intersect = intersectSphere(primRay, spheresToDraw[s]);
          if (intersect >= 0)
          {
            FragmentColor color1 = new FragmentColor(125,125,125);
            frameBuffer[w][h] = color1;
          }
        }
      }
    }
  }
} // Class RayTracer
