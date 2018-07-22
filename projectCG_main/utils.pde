class Sphere
{
  PVector center;
  float radius;
  
  Sphere(float x, float y, float z, float r)
  {
    center = new PVector(x, y, z);
    radius = r;
  }
}

class FragmentColor
{
  PVector rgbValues;
  
  FragmentColor(float red, float green, float blue)
  {
    rgbValues = new PVector(red, green, blue);
  }
} // Class FragmentColor

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
