class Mover{
  PVector location;
  PVector velocity;
  float radius = 50;
  
  Mover(){
    location = new PVector(0, -60, 0);
    velocity = new PVector(0, 0, 0);
  }
  
  void update(){
    location.add(velocity);
  }
  
  void display() {
    noStroke();
    fill(255, 102, 255);
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
    println(collisionDistance);
    
    for(int i = 0 ; i < cylinderPositions.size() ; i++){
      float posX = cylinderPositions.get(i).x;
      float posZ = cylinderPositions.get(i).y;
      PVector check = new PVector(posX, mover.location.y, posZ); 
      if(mover.location.dist(check) <= collisionDistance){
        
        PVector n = new PVector(mover.location.x - posX,  mover.location.z - posZ);
        n.normalize();
        velocity = velocity.sub(n.mult(2).mult(velocity.dot(n)));
        
      }
    }
  }
}