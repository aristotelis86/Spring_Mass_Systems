// Parameters of the filament
float FilamLength = 150, FilamMass = 25;
float stiffness = 16; // stiffness of connecting springs
int numOfseg = 16; // number of points used to simulate the filament

float dt = 0.02; // time step of simulation

float gravity = 10; // magnitude of gravity (y-direction, down positive)
float angle = PI/10; // initial angle of the entire filament from vertical axis


// Parameterization of simulation variables
float segLength = FilamLength / (numOfseg-1); // distance between points
float diam = (FilamLength / 2) / numOfseg; // radius of circles showing the points (only for design purposes)
float mass = FilamMass / numOfseg; // mass of each point
float [] x, y, vx, vy, ax, ay; // position, velocity and acceleration for each point-mass


// Runge-Kutta temp variables
float x1, y1, x2, y2, x3, y3, x4, y4;
float vx1, vy1, vx2, vy2, vx3, vy3, vx4, vy4;
float ax1, ay1, ax2, ay2, ax3, ay3, ax4, ay4;
PVector F, Temp; // forces

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
    
    F = force(x[i-1],x1,y[i-1],y1);  // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x1,x[i+1],y1,y[i+1]); // calculate force from spring below (if any)
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity)); // add gravity
    // calculate acceleration
    ax1 = F.x/mass; 
    ay1 = F.y/mass;
    
    // get k2
    x2 = x[i] + 0.5*vx1*dt;
    y2 = y[i] + 0.5*vy1*dt;
    vx2 = vx[i] + 0.5*ax1*dt;
    vy2 = vy[i] + 0.5*ay1*dt;
    
    F = force(x[i-1],x2,y[i-1],y2); // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x2,x[i+1],y2,y[i+1]); // calculate force from spring below (if any)
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity)); // add gravity 
    // calculate acceleration
    ax2 = F.x/mass;
    ay2 = F.y/mass;
    
    // get k3
    x3 = x[i] + 0.5*vx2*dt;
    y3 = y[i] + 0.5*vy2*dt;
    vx3 = vx[i] + 0.5*ax2*dt;
    vy3 = vy[i] + 0.5*ay2*dt;
    
    F = force(x[i-1],x3,y[i-1],y3); // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x3,x[i+1],y3,y[i+1]); // calculate force from spring below (if any)
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity)); // add gravity
    // calculate acceleration
    ax3 = F.x/mass;
    ay3 = F.y/mass;
    
    // get k4
    x4 = x[i] + vx3*dt;
    y4 = y[i] + vy3*dt;
    vx4 = vx[i] + ax3*dt;
    vy4 = vy[i] + ay3*dt;
    
    F = force(x[i-1],x4,y[i-1],y4); // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x4,x[i+1],y4,y[i+1]); // calculate force from spring below (if any)
      F.sub(Temp);
    }
    F.add(new PVector(0,mass*gravity)); // add gravity
    // calculate acceleration
    ax4 = F.x/mass;
    ay4 = F.y/mass;
    
    // Final step - Update positions + velocities
    x[i] = x[i] + (dt/6)*(vx1 + 2*vx2 + 2*vx3 + vx4);
    y[i] = y[i] + (dt/6)*(vy1 + 2*vy2 + 2*vy3 + vy4);
    
    vx[i] = vx[i] + (dt/6)*(ax1 + 2*ax2 + 2*ax3 + ax4);
    vy[i] = vy[i] + (dt/6)*(ay1 + 2*ay2 + 2*ay3 + ay4);
  }
  
  
}

// Spring force calculator
PVector force(float x0, float x1, float y0, float y1) {
  float s = sqrt(sq(x1 - x0) + sq(y1 - y0));
  float T = - stiffness * (s - segLength);
  float sx = (x1-x0)/s, sy = (y1-y0)/s;
  return new PVector(T*sx,T*sy);
}

// Display filaments as a series of points and connecting lines
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