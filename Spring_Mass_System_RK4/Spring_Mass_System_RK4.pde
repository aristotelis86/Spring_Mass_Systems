float FilamLength = 150, FilamMass = 50, stiffness = 14;

int numOfseg = 6;
float [] x, y, vx, vy, ax, ay; 
float angle = PI/10;


float segLength = FilamLength / (numOfseg-1), diam = (FilamLength / 2) / numOfseg;
float gravity = 10, mass = FilamMass / numOfseg;
float dt = 0.01;

// Runge-Kutta temp variables
float x1, y1, x2, y2, x3, y3, x4, y4;
float vx1, vy1, vx2, vy2, vx3, vy3, vx4, vy4;
float ax1, ay1, ax2, ay2, ax3, ay3, ax4, ay4;
PVector F, Temp;

void setup() {
  size(800, 600);
  frameRate(100);
  x = new float[numOfseg];
  y = new float[numOfseg];
  vx = new float[numOfseg];
  vy = new float[numOfseg];
  ax = new float[numOfseg];
  ay = new float[numOfseg];
  
  // Initialize velocities
  for (int i = 0; i < numOfseg; i++) {
    vx[i] = 0;
    vy[i] = 0;
  }
  // Initialize positions
  for (int i = 0; i < numOfseg; i++) {
      x[i] = i * segLength * sin(angle) + width/2;
      y[i] = i * segLength * cos(angle) + 30;
    }
}


void draw() {
  background(45);
  
  // Display
  displayFilament(x, y);
  
  // Update using Runge-Kutta 4
  for (int i = 1; i < numOfseg; i++) {
    // Mass #2
    // get k1
    x1 = x[i];
    y1 = y[i];
    vx1 = vx[i];
    vy1 = vy[i];
    
    F = force(x[i-1],x1,y[i-1],y1); 
    if ( i < numOfseg-1) {
      Temp = force(x1,x[i+1],y1,y[i+1]);
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity));
    ax1 = F.x/mass;
    ay1 = F.y/mass;
    
    // get k2
    x2 = x[i] + 0.5*vx1*dt;
    y2 = y[i] + 0.5*vy1*dt;
    vx2 = vx[i] + 0.5*ax1*dt;
    vy2 = vy[i] + 0.5*ay1*dt;
    
    F = force(x[i-1],x2,y[i-1],y2);
    if ( i < numOfseg-1) {
      Temp = force(x2,x[i+1],y2,y[i+1]);
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity));
    ax2 = F.x/mass;
    ay2 = F.y/mass;
    
    // get k3
    x3 = x[i] + 0.5*vx2*dt;
    y3 = y[i] + 0.5*vy2*dt;
    vx3 = vx[i] + 0.5*ax2*dt;
    vy3 = vy[i] + 0.5*ay2*dt;
    
    F = force(x[i-1],x3,y[i-1],y3); 
    if ( i < numOfseg-1) {
      Temp = force(x3,x[i+1],y3,y[i+1]);
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity));
    ax3 = F.x/mass;
    ay3 = F.y/mass;
    
    // get k4
    x4 = x[i] + vx3*dt;
    y4 = y[i] + vy3*dt;
    vx4 = vx[i] + ax3*dt;
    vy4 = vy[i] + ay3*dt;
    
    F = force(x[i-1],x4,y[i-1],y4); 
    if ( i < numOfseg-1) {
      Temp = force(x4,x[i+1],y4,y[i+1]);
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity));
    ax4 = F.x/mass;
    ay4 = F.y/mass;
    
    // Final step
    x[i] = x[i] + (dt/6)*(vx1 + 2*vx2 + 2*vx3 + vx4);
    y[i] = y[i] + (dt/6)*(vy1 + 2*vy2 + 2*vy3 + vy4);
    
    vx[i] = vx[i] + (dt/6)*(ax1 + 2*ax2 + 2*ax3 + ax4);
    vy[i] = vy[i] + (dt/6)*(ay1 + 2*ay2 + 2*ay3 + ay4);
  }
  
  
}

PVector force(float x0, float x1, float y0, float y1) {
  float s = sqrt(sq(x1 - x0) + sq(y1 - y0));
  float T = - stiffness * (s - segLength);
  float sx = (x1-x0)/s, sy = (y1-y0)/s;
  return new PVector(T*sx,T*sy);
}

void displayFilament(float xpos[], float ypos[]) {
  for ( int i = 0; i < xpos.length; i++) {
    fill(0, 235, 40);
    noStroke();
    ellipse(xpos[i], ypos[i], diam, diam);
    
    if (i < xpos.length - 1) {
      stroke(200);
      line(xpos[i], ypos[i], xpos[i+1], ypos[i+1]);
    }
  }

}