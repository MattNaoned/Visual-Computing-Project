class Mover{
  PVector location;
  PVector velocity;
  float radius = 50;
  
  Mover(){
    location = new PVector(0, -70, 0);
    velocity = new PVector(0, 0, 0);
  }
  
  void update(){
    location.add(velocity);
  }
  
  void display() {
    noStroke();
    fill(255, 0, 0);
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(radius);
    popMatrix();
  }
  
  void checkEdges() {
    if(location.x < -boxSize/2){
      location.x = -boxSize/2;
      velocity.x *= -1;
    }
    else if(location.x > boxSize/2){
      location.x = boxSize/2;
      velocity.x *= -1;
    }
    if(location.z < -boxSize/2){
      location.z = -boxSize/2;
      velocity.z *= -1;
    }
    else if(location.z > boxSize/2){
      location.z = boxSize/2;
      velocity.z *= -1;
    }
  }
  
  void checkCylinderCollision() {
    float collisionDistance = radius + cylinderBaseSize/2;
    float eps = 0.01;
    for(int i = 0 ; i < listCylinders.size() ; i++){
      
      float posX = listCylinders.get(i).posX;
      float posZ = listCylinders.get(i).posZ;
      
      PVector check = new PVector(posX, location.y, posZ); 
      
      if(mover.location.dist(check) <= collisionDistance){
        
        PVector n = new PVector(location.x - posX, 0, location.z - posZ);
        n.normalize();       
        n.mult(2*velocity.dot(n));
        velocity.sub(n);
        PVector cheat = n.mult(eps);
        location.add(cheat);
        
        
      }
    }
  }
}