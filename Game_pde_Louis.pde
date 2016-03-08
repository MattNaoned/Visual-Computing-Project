
float depth = 2000;
float count = 1;

void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}

float mX = 0;
float mZ = 0;

void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);
//  rotateY(-4*PI/6);
  rotateZ(PI);
  rotateX(PI/2);
  if (mX<0) {mX = 0;}
  else if (mX>width) {mX = width;}
  if (mZ<0) {mZ = 0;}
  else if (mZ >height){mZ = height;}
  float rz = map(mZ, 0, height, -PI/6, PI/6);
  float rx = map(mX, 0, width, -PI/6, PI/6);
  
  rotateY(rz);
  rotateX(rx);
  pushMatrix();
  box(700,700, 40);
  popMatrix();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    }
    else if (keyCode == DOWN) {
      depth += 50;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e>0){
    count+=0.1;
  }
  else if (e<0){
    count-=0.1;
  }
  println(count);
  if (count>1.5){
    count = 1.5;
  }
  else if (count<0.5){
    count = 0.5;
  } 
}

void mouseDragged() {
  mZ += (mouseX - pmouseX) * count;
  mX += (mouseY - pmouseY) * count;
}