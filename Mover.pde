class Mover{
  PVector location;
  PVector velocity;
  
  Mover(){
    location = new PVector(0, -60, 0);
    velocity = new PVector(0, 0, 0);
  }
  
  void update(){
    location.add(velocity);
  }
  
  void display() {
    noStroke();
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(50);
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
  
  void checkCylinderCollision(PVector ballPosition) {
    PVector n;
    /*for(int i = 0 ; i < cylinderPositions.size() ; i++) {
      if((ballPosition.x == cylinderPositions.get(i).x) && (ballPosition.y == cylinderPositions.get(i).y)){
        velocity = velocity.sub((velocity.dot(n).mult(2)).dot(n));
      }
    }*/
  }
}