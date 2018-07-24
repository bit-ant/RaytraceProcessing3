float calculateDiscriminant(float a, float b, float c)
{
    float discriminant = pow(b, 2) - (4 * a * c);
    return discriminant;
}

float solveQuadricEquationOneSolution(float a, float b)
{
  float x0 = -b / (2 * a);
  return x0;
}

float[] solveQuadricEquationTwoSolutions(float a, float b, float discriminant)
{
  float[] solutions = new float[2];
  
  float x0 = (-b + sqrt(discriminant)) / (2 * a); 
  float x1 = (-b - sqrt(discriminant)) / (2 * a);
  
  solutions[0] = x0;
  solutions[1] = x1;
  return solutions;
}

Cube calculateBoundingBoxForSphere(Sphere sphere)
{
  PVector vMin = new PVector(sphere.center.x - sphere.radius, sphere.center.y - sphere.radius, sphere.center.z - sphere.radius);
  PVector vMax = new PVector(sphere.center.x + sphere.radius, sphere.center.y + sphere.radius, sphere.center.z + sphere.radius);
  Cube box = new Cube(vMin, vMax);
  return box;
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
float[] intersectSphere(Ray ray, Sphere sphere)
{  
  float[] solutions = new float[2];
  for (int i = 0; i < solutions.length; ++i)
  {
    solutions[i] = -Float.MAX_VALUE; // Negative value shall mean no solution found in front of camera
  }
  
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
    solutions[0] = solutions[1] = -b / (2 * a);
  }
  else
  {
    // Two solutions
    float x0 = (-b + sqrt(discriminant)) / (2 * a);
    float x1 = (-b - sqrt(discriminant)) / (2 * a);
    
    solutions[0] = (x0 < x1) ? x0 : x1;
    solutions[1] = (x0 > x1) ? x0 : x1;
  }
  return solutions;
}

// Find ray-box intersection using the "slabs" method.               //
// Perform test for each pair of planes associated with x, y, z.     //
// At any step, failing of a test shall return a false value.        //
// This function only returns if at least one intersection was found.//  
float[] cubeIntersections = new float[2];
boolean intersectBox(Ray ray, Cube box)
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
  cubeIntersections[0] = tNear;
  cubeIntersections[1] = tFar;
  return true; // All tests passed, there is an intersection!
}

// The case of infinite cylinder aligned along the z axis is x^2+y^2 = 1            //
// Substituting with the ray equation for x, y, z gives us another quadric equation //
float[] intersectInfiniteUnitCylinder(Ray ray)
{
  float[] solutions = new float[2];
  for (int i = 0; i < solutions.length; ++i)
  {
    solutions[i] = -Float.MAX_VALUE; // Negative value shall mean no solution found in front of camera
  }
  
  PVector origin = ray.origin.copy();       // Copy needed to keep original vectors intact
  PVector direction = ray.direction.copy();
  
  float a = direction.dot(direction); // a = d^2;
  float b = 2 * direction.dot(origin); // b = 2 * d * o
  float c = origin.dot(origin) - 1; // c = o * o - 1
  
  float discriminant = calculateDiscriminant(a, b, c);
  
  if (discriminant < 0)
  {
    // No solution to quadric equation, so no intersection :(
  }
  else if (0 == discriminant)
  {
    // One solution
    solutions[0] = solutions[1] = -b / (2 * a);
  }
  else
  {
    // Two solutions
    float x0 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
    float x1 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
    
    solutions[0] = (x0 < x1) ? x0 : x1;
    solutions[1] = (x0 > x1) ? x0 : x1;
  }
  
  return solutions;
}

ArrayList<PVector> getIntersections(Ray ray, float[] solutions)
{
  ArrayList<PVector> inters = new ArrayList<PVector>();
  for (int i = 0; i < solutions.length; ++i)
  {
    if (solutions[i] > 0)
    {
      PVector sol = ray.origin.copy().add(ray.direction.mult(solutions[i]));
      inters.add(sol);
    }
  }
  
  return inters;
}
