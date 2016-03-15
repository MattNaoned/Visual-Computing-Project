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
  
  void checkEdges() {
    if(location.x < -350){
      location.x = -350;
      velocity.x *= -1;
    }
    else if(location.x > 350){
      location.x = 350;
      velocity.x *= -1;
    }
    if(location.z < -350){
      location.z = -350;
      velocity.z *= -1;
    }
    else if(location.z > 350){
      location.z = 350;
      velocity.z *= -1;
    }
  }
}