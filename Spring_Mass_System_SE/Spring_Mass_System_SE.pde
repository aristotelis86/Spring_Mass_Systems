float FilamLength = 150, FilamMass = 20, stiffness = 14;

int numOfseg = 16;
float dt = 0.005; 
float angle = PI/10, gravity = 10;


float segLength = FilamLength / (numOfseg-1), diam = (FilamLength / 2) / numOfseg;
float mass = FilamMass / numOfseg;
float [] x, y, vx, vy, ax, ay;




void setup() {
  size(800, 600);
  frameRate(60);
  x = new float[numOfseg];
  y = new float[numOfseg];
  vx = new float[numOfseg];
  vy = new float[numOfseg];
  ax = new float[numOfseg];
  ay = new float[numOfseg];
  // Initialize every mass in a vertical straight line
  for (int i = 0; i < numOfseg; i++) {
    vx[i] = 0;
    vy[i] = 0;
  }

  for (int i = 0; i < numOfseg; i++) {
    x[i] = i * segLength * cos(angle) + width/2;
    y[i] = i * segLength * sin(angle);
  }
  
}

void draw() {
  background(255);
  
  // Update 
  for (int i = 1; i < numOfseg; i++) {
    PVector F = force(x[i-1],x[i],y[i-1],y[i]);             // spring 1
    if(i < numOfseg - 1) {
      PVector Temp = force(x[i],x[i+1],y[i],y[i+1]);
      F.sub(Temp); // spring 2
    }
    
    F.add(new PVector(0,mass*gravity));                     // gravity
    ax[i] = F.x/mass;
    ay[i] = F.y/mass;
  
  
    vx[i] += dt*ax[i];
    vy[i] += dt*ay[i];
    
    
    x[i] +=  dt*vx[i];
    y[i] +=  dt*vy[i];
  }
    
  // Display
  drawFilament(x, y);
  // Check for boundary collisions
  for (int i = 1; i < numOfseg; i++) {
    float [] velTemp = new float[2];
    velTemp = checkBoundaryCollision(x[i], y[i], vx[i], vy[i], diam);
    vx[i] = velTemp[0];
    vy[i] = velTemp[1];
  }
}


PVector force(float x0, float x1, float y0, float y1) {
  float s = sqrt(sq(x1 - x0) + sq(y1 - y0));
  float T = - stiffness * (s - segLength);
  float sx = (x1-x0)/s, sy = (y1-y0)/s;
  return new PVector(T*sx,T*sy);
}

void drawFilament(float xpos[], float ypos[]) {
  for ( int i = 0; i < xpos.length; i++) {
    fill(0, 235, 40);
    noStroke();
    ellipse(xpos[i], ypos[i], diam, diam);
    
    if (i < xpos.length - 1) {
      fill(235, 0, 40);
      stroke(1);
      line(xpos[i], ypos[i], xpos[i+1], ypos[i+1]);
    }
  }

}

float[] checkBoundaryCollision(float xpos, float ypos, float velx, float vely, float radius) {
  float [] result = new float[2];
  if ((xpos > width-radius) || (xpos < radius)){
    xpos = width-radius;
    velx *= -1;
    result[0] = velx;
  } 
  else result[0] = velx;
  
  if ((ypos > height-radius) || (ypos < radius)){
    ypos = height-radius;
    vely *= -1;
    result[1] = vely;
  }
  else result[1] = vely;
  
  return result;
}