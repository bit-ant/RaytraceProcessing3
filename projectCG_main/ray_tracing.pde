import java.util.Collections;

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
  Cube[] boundingBoxes;
  PImage normalMap;
  
  RayTracer(int bufferHeight, int bufferWidth, float camX, float camY, float camZ, float screenZ, 
            float lightSourceX, float lightSourceY,float lightSourceZ, Sphere[] spheres, String normalImage)
  {
    this.bufferHeight = bufferHeight;
    this.bufferWidth = bufferWidth;
    frameBuffer = new float[bufferWidth][bufferHeight];
    zBuffer = new float[bufferWidth][bufferHeight];
    cameraPos = new PVector(camX, camY, camZ);
    lightSourcePos = new PVector(lightSourceX, lightSourceY, lightSourceZ);
    this.screenZ = screenZ;
    spheresToDraw = spheres;
    boundingBoxes = new Cube[spheresToDraw.length];
    
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
            //renderSphere(primRay, w, h, s);
          }
        }
        
        // CSG attempt...
        Sphere node1 = new Sphere(100, 150, 130, 50.0);
        //Cube node2 = new Cube(new PVector(239.27863, 108.173218, 120), new PVector(259.27863, 128.173218, 130));
        Cube node2 = new Cube(new PVector(139.27863, 108.173218, 120), new PVector(209.27863, 128.173218, 150));
        
        float[] solSphere = intersectSphere(primRay, node1); //<>//
        if (solSphere[0] >=0 && intersectBox(primRay, node2))
        {
          float[] cubeInter = cubeIntersections;
          ArrayList <Float> sol = union(solSphere, cubeInter);
          Collections.sort(sol);
          float t = sol.get(0);
          t = sol.get(sol.size() - 1);
          if (t >= 0 && t < zBuffer[w][h]) //<>//
          {
            zBuffer[w][h] = t; //<>//
            frameBuffer[w][h] = 80;
          }
        }
      }
    }
  }
  
  void renderSphere(Ray primRay, int w, int h, int s)
  {
    float t = intersectSphere(primRay, spheresToDraw[s])[0];
    if (t >= 0 && t < zBuffer[w][h])
    {
      zBuffer[w][h] = t;
      
      // Calculate normal of intersection point
      PVector tmp = new PVector(0, 0, primRay.origin.z);
      PVector intersectionPoint = tmp.add(primRay.direction.copy().mult(t)); // o + t * d
      PVector normal = (intersectionPoint.copy().sub(primRay.origin)).normalize(); // N = ||p - c||
      
      // Calculate spherical coordinates
      float phi = atan2(intersectionPoint.z, intersectionPoint.x);
      float theta = acos(intersectionPoint.y / spheresToDraw[s].radius);
      
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
      PVector normalModified = new PVector(map.x * tangent.x + map.y * bitangent.x + map.z * normal.x,
                                           map.x * tangent.y + map.y * bitangent.y + map.z * normal.y, 
                                           map.x * tangent.z + map.y * bitangent.z + map.z * normal.z);
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
} // Class RayTracer
