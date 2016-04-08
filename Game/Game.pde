float depth = 2000;
float valX;
float valZ;
float gravityConstant = 0.981;
PVector gravityForce = new PVector(0, 0, 0);
float count = 1;
Mover mover = new Mover();
float boxSize = 800;
float boxDepth = 40;
float cylinderBaseSize = 50;
ArrayList<Cylinder> listCylinders = new ArrayList();



void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
  pushMatrix();
  translate(width/2, height/2);
  valX = width/2;
  valZ = height/2;
  popMatrix();
}


void draw() {

  if (keyPressed == true) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }    
  }
  
  
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102); 
  background(200);
  translate(width/2, height/2);
  
  if (valX < 0) {
    valX = 0;
  } else if (valX > width) {
    valX = width;
  }
  if (valZ < 0) {
    valZ = 0;
  } else if (valZ > height) {
    valZ = height;
  }

  float rx = map(valX, 0, width, -PI/3, PI/3);
  float rz = map(valZ, 0, height, -PI/3, PI/3);
  
  gravityForce.x = sin(rz) * gravityConstant;
  gravityForce.z = -sin(rx) * gravityConstant;
  float normalForce = 1;
  float mu = 0.1;
  float frictionMagnitude = normalForce * mu;
  PVector friction = mover.velocity.copy();
  friction.mult(-1);
  friction.normalize();
  friction.mult(frictionMagnitude);
  boolean pause = false;
  
    pushMatrix();
    if(!(keyPressed == true && keyCode == SHIFT)){
      rotateX(rx);
      rotateZ(rz);
      pause = false;
    }else {
      rotateX(-PI/2);
      pause = true;
    }
      fill(255);
      box(boxSize, boxDepth, boxSize);
    if(!pause){
      mover.velocity.add(gravityForce);
      mover.velocity.add(friction);
      mover.update();
      mover.checkEdges();
    }
      mover.checkCylinderCollision();
      mover.display();
     fill(153, 255, 153);

  for(int i = 0; i < listCylinders.size() ; i++) {
    listCylinders.get(i).display();
  }
     
    popMatrix();
  
  
  
}

void mouseDragged() {
  valX += (pmouseY - mouseY)*count;
  valZ += (mouseX - pmouseX)*count;
  
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e < 0) {
    count += 0.1;
  } else if (e > 0) {
    count -= 0.1;
  }
  if (count < 0.2) {
    count = 0.2;
  } else if (count > 1.5) {
    count = 1.5;
  }
  println(count);
}

void mouseClicked() {
  if(keyPressed  && keyCode == SHIFT){
    float x = map(mouseX, 160, 340, -boxSize/2 , boxSize/2);
    float y  = map(mouseY, 160, 340, -boxSize/2, boxSize/2);
    if(!((mouseX < 160 || mouseX > 340 || (mouseY < 160) || mouseY > 340))){
      Cylinder c = new Cylinder(x, y);
      if(distinctCylinders(c)){
        listCylinders.add(c);
      }
    }
  }
}

boolean distinctCylinders(Cylinder c){
  for(int i = 0 ;  i < listCylinders.size() ; i++) {
    if(listCylinders.get(i).getCenter().dist(c.getCenter()) < 2*cylinderBaseSize){
      return false;
    }
  }
  return c.getCenter().dist(new PVector(mover.location.x, mover.location.z)) > (mover.radius + cylinderBaseSize/2);
}