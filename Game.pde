float score = 0;
float lastScore = 0;
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
PGraphics mySurface;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barchart;
HScrollbar hscroll;


void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
  hscroll = new HScrollbar(width/30 + height/3 + width/40, 4*height/5 + height/7 + height/45, width - height/3 - 3* width/60 - width/40, height/50);
  mySurface = createGraphics(width, height/5, P2D);
  topView = createGraphics(height/6, height/6, P2D);
  scoreBoard = createGraphics(height/6, height/6, P2D);
  barchart = createGraphics(width - height/3 - 3* width/60 - width/40, height/7, P2D);
  pushMatrix();
  translate(width/2, height/2);
  valX = width/2;
  valZ = height/2;
  popMatrix();
  
}


void draw() {
  background(255);
  
  drawMySurface();
  image(mySurface, 0, 4*height/5);
  
  drawTopView();
  image(topView, width/60, height/60 + 4*height/5); 
  
  drawScoreBoard();
  image(scoreBoard, width/30 + height/6, height/60 + 4*height/5);
  
  drawBarchart();
  image(barchart, width/30 + height/3 + width/40 , height/60 + 4*height/5);

  hscroll.update();
  hscroll.display();
  println(hscroll.getPos());

  pushMatrix();
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
      fill(255, 0, 0);
      mover.display();
      
      fill(153, 255, 153);
      
      for(Cylinder c : listCylinders) {                 // Endroit qui fait tout déconner
        c.display();
      }
     
    popMatrix();
  popMatrix();
}



void mouseDragged() {
  if(mouseY <= 4*height/5){
    valX += (pmouseY - mouseY)*count;
    valZ += (mouseX - pmouseX)*count;
  } 
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

void drawMySurface() {
  mySurface.beginDraw();
  mySurface.stroke(0);
  mySurface.strokeWeight(4);
  mySurface.rect(0, 0, width, height/5);
  mySurface.fill(255, 204, 153);

  mySurface.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.rect(0, 0, height/6, height/6);
  float scale = (height/6) / boxSize;
  topView.fill(0);
  for(Cylinder c : listCylinders) {
    topView.ellipse(c.posX * scale + height/12, c.posZ * scale + height/12, cylinderBaseSize*2 * scale, cylinderBaseSize*2 * scale);
  }
  topView.stroke(0);
  topView.strokeWeight(2);
  topView.fill(250);
  topView.ellipse(mover.location.x * scale +height/12, mover.location.z * scale + height/12, 2*mover.radius * scale, 2*mover.radius * scale);
  topView.stroke(0);
  topView.strokeWeight(4);
  topView.fill(0, 120, 190);
  topView.endDraw();
}

void drawScoreBoard() {
  scoreBoard.beginDraw();
  scoreBoard.stroke(0);
  scoreBoard.strokeWeight(4);
  scoreBoard.rect(0, 0, height/6, height/6);
  scoreBoard.fill(0);
  scoreBoard.textSize(height/60);
  
  scoreBoard.text("Total Score : ", height/60, height/60, height/6 - height/60, height/6 - height/60);
  scoreBoard.text(Float.toString(score), height/60, height/30, height/6 - height/60, height/6 - height/60);
  scoreBoard.text("Velocity : ", height/60, 4*height/60, height/6 - height/60, height/6 - height/60);
  scoreBoard.text(Float.toString(mover.velocity.mag()), height/60, height/12, height/6 - height/60, height/6 - height/60);
  scoreBoard.text("Last Score : ", height/60, 7*height/60, height/6 - height/60, height/6 - height/60);
  scoreBoard.text(Float.toString(lastScore), height/60, 8*height/60, height/6 - height/60, height/6 - height/60);
  
  scoreBoard.fill(250);
  scoreBoard.endDraw();
}

void drawBarchart() {
 barchart.beginDraw();
 barchart.stroke(0);
 barchart.strokeWeight(4);
 barchart.rect(0, 0, width - height/3 - 3* width/60 - width/40, height/7);
 barchart.fill(250);
 
 
 
 barchart.endDraw();
}