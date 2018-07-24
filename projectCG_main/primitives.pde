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

class Cube
{
  PVector vMin;
  PVector vMax;
  
  Cube(PVector vMin, PVector vMax)
  {
    this.vMin = vMin;
    this.vMax = vMax;
  }
} // Class Cube

class Sphere
{
  PVector center;
  float radius;
  
  Sphere(float x, float y, float z, float r)
  {
    center = new PVector(x, y, z);
    radius = r;
  }
} // Class Sphere

class Cylinder
{
  PVector center;
  float height;
  float radius;
  
  Cylinder(float centerX, float centerY, float centerZ, float height, float radius)
  {
    center = new PVector(centerX, centerY, centerZ);
    this.height = height;
    this.radius = radius;
  }
} // Class Cylinder

ArrayList<Float> union(float[] left, float[] right)
{
  ArrayList<Float> union = new ArrayList<Float>();
  for (Float l : left)
  {
    union.add(l);
  }
  
  for (Float r : right)
  {
    if (!union.contains(r))
    {
      union.add(r);
    }
  }
  
  return union;
}

ArrayList<Float> intersection(ArrayList<Float> left, ArrayList<Float> right)
{
  ArrayList<Float> intersection = new ArrayList<Float>();
  
  for (Float l : left)
  {
    if (right.contains(l))
    {
      intersection.add(l);
    }
  }
  
  return intersection;
}

ArrayList<Float> difference(ArrayList<Float> left, ArrayList<Float> right)
{
  ArrayList<Float> difference = new ArrayList<Float>();
  
  for (Float l : left)
  {
    if (!right.contains(l))
    {
      difference.add(l);
    }
  }
  
  return difference;
}
