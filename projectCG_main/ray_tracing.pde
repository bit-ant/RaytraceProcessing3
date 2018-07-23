class RayTracer
{
  float[][] frameBuffer;
  float[][] zBuffer;
  int bufferHeight;
  int bufferWidth;
  PVector cameraPos;
  PVector lightSourcePos;
  float screenZ;
  Sphere[] spheresToDraw;
  BoundingBox[] boundingBoxes;
  PImage normalMap;
  
  RayTracer(int bufferHeight, int bufferWidth, float camX, float camY, float camZ, float screenZ, float lightSourceX, float lightSourceY,float lightSourceZ, Sphere[] spheres, String normalImage)
  {
    this.bufferHeight = bufferHeight;
    this.bufferWidth = bufferWidth;
    frameBuffer = new float[bufferWidth][bufferHeight];
    zBuffer = new float[bufferWidth][bufferHeight];
    cameraPos = new PVector(camX, camY, camZ);
    lightSourcePos = new PVector(lightSourceX, lightSourceY, lightSourceZ);
    this.screenZ = screenZ;
    spheresToDraw = spheres;
    boundingBoxes = new BoundingBox[spheresToDraw.length];
    
    // Calculate bounding boxes for the spheres
    for (int s = 0; s < spheresToDraw.length; ++s)
    {
      boundingBoxes[s] = calculateBoundingBoxForSphere(spheresToDraw[s]);
    }
    
    // Init framebuffer to black
    for (int h = 0; h < bufferHeight; ++h)
    {
      for (int w = 0; w < bufferWidth; ++w)
      {
            frameBuffer[w][h] = 0;
      }
    }
    
    // Init z-buffer to maximum depth
    for (int h = 0; h < bufferHeight; ++h)
    {
      for (int w = 0; w < bufferWidth; ++w)
      {
            zBuffer[w][h] = Float.MAX_VALUE;
      }
    }
    
    // Load normal map
    normalMap = loadImage(normalImage);
    normalMap.loadPixels();
  }
  
  Ray createPrimaryRay(float h /* heigth */, float w /* width */)
  {
    float pixelCenterX = (w + 0.5);
    float pixelCenterY = (h + 0.5);
    Ray primRay = new Ray();
    primRay.origin = cameraPos;
    primRay.direction = new PVector(pixelCenterX - cameraPos.x, pixelCenterY - cameraPos.y, screenZ - cameraPos.z);
    
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
    float t = -1; // This will hold the intersection point. Negative value will mean that no intersection was found in front of the camera.
    
    PVector origin = ray.origin.copy();       // Copy needed to keep original vectors intact
    PVector direction = ray.direction.copy();
    
    PVector rayOrigToSphereCent = origin.sub(sphere.center); // o - c , calculate now because we'll need it more than once below
    float a = direction.dot(direction); // a = d^2;
    float b = 2 * direction.dot(rayOrigToSphereCent); // b = 2 * d * (o - c)
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
      
      t = (x0 < x1) ? x0 : x1;
    }
    return t;
  }
  
  // Find ray-box intersection using the "slabs" method.               //
  // Perform test for each pair of planes associated with x, y, z.     //
  // At any step, failing of a test shall return a false value.        //
  // This function only returns if at least one intersection was found.//  
  boolean intersectBox(Ray ray, BoundingBox box)
  {
    float tNear = -Float.MAX_VALUE;
    float tFar = Float.MAX_VALUE;
    
    /************************ x planes test ************************/
    if (0 == ray.direction.x) // Ray parallel to x planes
    {
      if (ray.origin.x < box.vMin.x || ray.origin.x > box.vMax.x) // Ray not inside box
      {
        // Ray is parallel to x planes and not inside the box, so there is no intersection
        return false;
      }
    }
    else // Ray not parallel to x planes
    {
      float tx1 = (box.vMin.x - ray.origin.x) / ray.direction.x;
      float tx2 = (box.vMax.x - ray.origin.x) / ray.direction.x;
      
      float txMin = (tx1 < tx2) ? tx1 : tx2;
      float txMax = (tx1 > tx2) ? tx1 : tx2;
      
      if (txMin > tNear) // We want the largest tNear
      {
        tNear = txMin;
      }
      if (txMax < tFar) // We want the smallest tFar
      {
        tFar = txMax;
      }
      
      if (tNear > tFar) // Box is missed by ray
      {
        return false;
      }
      if (tFar < 0) // Box is behind ray
      {
        return false;
      }
    }
    
    /************************ y planes test ************************/
    if (0 == ray.direction.y) // Ray parallel to y planes
    {
      if (ray.origin.y < box.vMin.y || ray.origin.y > box.vMax.y) // Ray not inside box
      {
        // Ray is parallel to y planes and not inside the box, so there is no intersection
        return false;
      }
    }
    else // Ray not parallel to y planes
    {
      float ty1 = (box.vMin.y - ray.origin.y) / ray.direction.y;
      float ty2 = (box.vMax.y - ray.origin.y) / ray.direction.y;
      
      float tyMin = (ty1 < ty2) ? ty1 : ty2;
      float tyMax = (ty1 > ty2) ? ty1 : ty2;
      
      if (tyMin > tNear) // We want the largest tNear
      {
        tNear = tyMin;
      }
      if (tyMax < tFar) // We want the smallest tFar
      {
        tFar = tyMax;
      }
      
      if (tNear > tFar) // Box is missed by ray
      {
        return false;
      }
      if (tFar < 0) // Box is behind ray
      {
        return false;
      }
    }
    
    /************************ z planes test ************************/
    if (0 == ray.direction.z) // Ray parallel to z planes
    {
      if (ray.origin.z < box.vMin.z || ray.origin.z > box.vMax.z) // Ray not inside box
      {
        // Ray is parallel to z planes and not inside the box, so there is no intersection
        return false;
      }
    }
    else // Ray not parallel to z planes
    {
      float tz1 = (box.vMin.z - ray.origin.z) / ray.direction.z;
      float tz2 = (box.vMax.z - ray.origin.z) / ray.direction.z;
      
      float tzMin = (tz1 < tz2) ? tz1 : tz2;
      float tzMax = (tz1 > tz2) ? tz1 : tz2;
      
      if (tzMin > tNear) // We want the largest tNear
      {
        tNear = tzMin;
      }
      if (tzMax < tFar) // We want the smallest tFar
      {
        tFar = tzMax;
      }
      
      if (tNear > tFar) // Box is missed by ray
      {
        return false;
      }
      if (tFar < 0) // Box is behind ray
      {
        return false;
      }
    }
    
    return true; // All tests passed, there is an intersection!
  }

  void renderScene() 
  {
    for (int h = 0; h < bufferHeight; ++h)
    {
      for (int w = 0; w < bufferWidth; ++w)
      {
        Ray primRay = createPrimaryRay(h, w);
        for (int s = 0; s < spheresToDraw.length; ++s)
        {
          // If there is an intersection with the bounding box, proceed with calculating ray-sphere intersection
          if (intersectBox(primRay, boundingBoxes[s]))
          {
            float t = intersectSphere(primRay, spheresToDraw[s]);
            if (t >= 0 && t < zBuffer[w][h])
            {
              zBuffer[w][h] = t;
              
              // Calculate normal of intersection point
              PVector intersectionPoint = primRay.origin.copy().add(primRay.direction.copy().mult(t)); // o + t * d
              PVector normal = (intersectionPoint.copy().sub(primRay.origin)).normalize(); // N = ||p - c||
              
              // Calculate spherical coordinates
              PVector norm_inter = intersectionPoint.copy().normalize();
              float phi = atan2(intersectionPoint.z, intersectionPoint.x); //<>//
              float theta = acos(intersectionPoint.x / spheresToDraw[s].radius);
              
              // Calculate tangent and bi-tangent vectors
              PVector tangent = new PVector(-sin(phi), cos(phi), 0);
              tangent.normalize();
              PVector bitangent = normal.copy().cross(tangent);
              bitangent.normalize();
              
              int u = int(normalMap.width * (phi / (2 * PI)));
              int v = int(normalMap.height * (theta / PI));
              
              color c = normalMap.get(v, u);
              PVector map = new PVector((red(c) - 127) / 127.0, (green(c) - 127) / 127.0, blue(c) / 255.0);
              map.normalize();
              PVector normalModified = new PVector(map.x * tangent.x + map.y * bitangent.x + map.z * normal.x, map.x * tangent.y + map.y * bitangent.y + map.z * normal.y, map.x * tangent.z + map.y * bitangent.z + map.z * normal.z);
              normalModified.normalize();
              
              PVector light = lightSourcePos.copy().sub(intersectionPoint);
              light.normalize();
              float intensity = normalModified.dot(light);
              frameBuffer[w][h] = 15;
              if (intensity > 0)
              {
                 frameBuffer[w][h] += 240 * intensity;
              }
            }
          }
        }
      }
    }
  
    // Show on screen
    for (int y = 0; y < frameHeight; ++y)
    {
      for (int x = 0; x < frameWidth; ++x) 
      {
        float intensity = frameBuffer[x][y];
        stroke(intensity);
        point(x, y);
      }
    }
  }
} // Class RayTracer
