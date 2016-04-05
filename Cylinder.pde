class Cylinder{
  float posX;
  float posY;
  float cylinderBaseSize = 50;
  float cylinderHeight = 50;
  int cylinderResolution = 40;
  PShape openCylinder = new PShape();
  PShape topSurface = new PShape();
  PShape bottomSurface = new PShape();
  
  Cylinder(float posX, float posY) {
    this.posX = posX;
    this.posY = posY;
    
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
  
     //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    topSurface = createShape();
    topSurface.beginShape(TRIANGLE_FAN);
    topSurface.vertex(0, 0, cylinderHeight);
    for(int i = 0 ; i < x.length ; i++){
      topSurface.vertex(x[i], y[i], cylinderHeight);
    }
    topSurface.endShape();
  
    bottomSurface = createShape();
    bottomSurface.beginShape(TRIANGLE_FAN);
    bottomSurface.vertex(0, 0, 0);
    for(int i = 0 ; i < x.length ; i++){
      bottomSurface.vertex(x[i], y[i], 0);
    }
    bottomSurface.endShape();

    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i] , 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
     openCylinder.endShape();
   }
   
   void display() {
     translate(posX, posY, 0);
     shape(openCylinder);
     shape(bottomSurface);
     shape(topSurface);
   }
}