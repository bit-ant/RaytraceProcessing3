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

class Cube
{
  PVector center;
  PVector dimensions;
  
  Cube(float centerX, float centerY, float centerZ, float dimX, float dimY, float dimZ)
  {
    center = new PVector(centerX, centerY, centerZ);
    dimensions = new PVector(dimX, dimY, dimZ);
  }
}

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
}
