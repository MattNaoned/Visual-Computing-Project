float depth = 2000;
void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}
float x = 0;
float valX;
float valZ;
float count = 1;

void draw() {
  if(keyPressed == true) {
    if(keyCode == UP) {
      depth -= 50;
    }
    else if(keyCode == DOWN) {
      depth += 50;
    }
  }

  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102); 
  background(200);
  translate(width/2, height/2, 0);
  valX = width/2;
  valZ = height/2;
  rotateX(PI/2);
  
  if(valX < 0) {valX = 0;}
  else if(valX > width) {valX = width;}
  if(valZ < 0) {valZ = 0;}
  else if (valZ > height) {valZ = height;}
  
  float rx = map(valX, 0, width, -PI/3, PI/3);
  float rz = map(valZ, 0, height, -PI/3, PI/3);
  /*float niqueSaMere = map(x,-PI/3,PI/3,0,width);
  println(niqueSaMere);*/
  /*
  if(rx < -PI/3) {rx = -PI/3;}
  else if(rx > PI/3) {rx = PI/3;}
  if(rz < -PI/3) {rz = -PI/3;}
  else if(rz > PI/3) {rz = PI/3;}
  */
  println(rx);
  println(rz);

  pushMatrix();
  rotateX(rx);
  rotateY(rz);
  box(700, 700, 40);
  popMatrix();
  
  
}

void mouseDragged() {
  valX += (mouseY - pmouseY)*count;
  valZ += (mouseX - pmouseX)*count;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e < 0) {
    count += 0.1;
  }else if(e > 0) {
    count -= 0.1;
  }
  if(count < 0.2) {
    count = 0.2;
  }else if(count > 1.5) {
    count = 1.5;
  }
  println(count);
}
