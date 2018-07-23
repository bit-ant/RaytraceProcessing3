class Ray
{
  PVector origin;
  PVector direction;
  
  Ray()
  {
    origin = new PVector();
    direction = new PVector();
  }
} // Class Ray

class BoundingBox
{
  PVector vMin;
  PVector vMax;
  
  BoundingBox(PVector vMin, PVector vMax)
  {
    this.vMin = vMin;
    this.vMax = vMax;
  }
} // Class BoundingBox

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

BoundingBox calculateBoundingBoxForSphere(Sphere sphere)
{
  PVector vMin = new PVector(sphere.center.x - sphere.radius, sphere.center.y - sphere.radius, sphere.center.z - sphere.radius);
  PVector vMax = new PVector(sphere.center.x + sphere.radius, sphere.center.y + sphere.radius, sphere.center.z + sphere.radius);
  BoundingBox box = new BoundingBox(vMin, vMax);
  return box;
}
