// Parameters of the filament
float FilamLength = 250, FilamMass = 25;
//float stiffness = 20; // stiffness of connecting springs
int numOfseg = 20; // number of points used to simulate the filament

// Initial and boundary conditions
float angle = 0; // initial angle of the entire filament from vertical axis
boolean movingTip = false; // introduce external forcing at leading edge
float Amplitude = 100; // amplitude of oscillatory motion
float omega = 2*PI*.2; // frequency of oscillatory motion
boolean freeFall = false; // let the filament drop
float freeT = 5; // time at which the filament becomes free

boolean wrSwitch = false;

float dt = 0.1; // time step of simulation
float t = 0; // init time variable

float gravity = 10; // magnitude of gravity (y-direction, positive down )

///////// END OF INPUTS //////////////////
//////////////////////////////////////////
// Parameterization of simulation variables
float segLength = FilamLength / (numOfseg-1); // distance between points
float natLength = 0.5*segLength;
float diam = (FilamLength / 2) / numOfseg; // radius of circles showing the points (only for design purposes)
float mass = FilamMass / numOfseg; // mass of each point
float [] x, y, vx, vy, ax, ay; // position, velocity and acceleration for each point-mass
float [] stiffness; // array for stiffness of each spring
int init_i;

// Runge-Kutta temp variables
float x1, y1, x2, y2, x3, y3, x4, y4;
float vx1, vy1, vx2, vy2, vx3, vy3, vx4, vy4;
float ax1, ay1, ax2, ay2, ax3, ay3, ax4, ay4;
PVector F, Temp; // forces

PrintWriter output; // handles output file

color [] cl;

void setup() {
  size(800, 600);
  //frameRate(100);
  x = new float[numOfseg];
  y = new float[numOfseg];
  vx = new float[numOfseg];
  vy = new float[numOfseg];
  ax = new float[numOfseg];
  ay = new float[numOfseg];
  
  cl = new color[numOfseg];
  
  stiffness = new float[numOfseg-1];
  
  // Initialize velocities
  for (int i = 0; i < numOfseg; i++) {
    vx[i] = 0;
    vy[i] = 0;
  }
  // Initialize positions
  for (int i = 0; i < numOfseg; i++) {
      // x[i] = i * segLength * sin(angle) + width/2;
      y[i] = i * segLength * cos(angle) + 30;
      x[i] = 10 * sin(4*PI*(y[i]-30)/FilamLength) + width/2;
      println(x[i], y[i]);
      cl[i] = color(random(255), random(255), random(255));
    }
  
  // Calculate stiffness of springs
  for (int i = 0; i < numOfseg-1; i++) {
    stiffness[i] = (gravity/abs(natLength - segLength)) * (numOfseg-i-1) * mass;
  }
  
  if (wrSwitch) {
    output = createWriter("positions.txt");
    output.println("t, x, y");
  }
}


void draw() {
  background(45);
  
  if (wrSwitch) output.println(t + " " + x[1] + " " + y[1] + " " + x[numOfseg-1] + " " + y[numOfseg-1] + " " + x[numOfseg/2] + " " + y[numOfseg/2]);
  
  // Display
  displayFilament(x, y);
  
  // Update using Runge-Kutta 4
  RungeKutta4();
  
  // Detect Collisions;
  collisionDetection();
  
}

// Spring force calculator
PVector force(float x0, float x1, float y0, float y1, float stiff) {
  float s = sqrt(sq(x1 - x0) + sq(y1 - y0));
  float T = - stiff * (s - natLength);
  float sx = (x1-x0)/s, sy = (y1-y0)/s;
  return new PVector(T*sx,T*sy);
}

// Display filaments as a series of points and connecting lines
void displayFilament(float xpos[], float ypos[]) {
  for ( int i = 0; i < xpos.length; i++) {
    fill(cl[i]);
    noStroke();
    ellipse(xpos[i], ypos[i], diam, diam);
    
    if (i < xpos.length - 1) {
      stroke(200);
      line(xpos[i], ypos[i], xpos[i+1], ypos[i+1]);
    }
  }
}

// Check for collisions each mass
// Unfortunately, totally elastic collisions for now
void collisionDetection() {
  float crit_dist;
  
  for (int i = 0; i < numOfseg; i++){
    for (int j = numOfseg-1; j > i; j--) {
      crit_dist = sqrt(sq(x[i] - x[j]) + sq(y[i] - y[j]));
      if (crit_dist < diam) {
        println("Collision detected for "+ i +  " and " + j);
        
        vx[i] = vx[j];
        vx[j] = vx[i];
        
        vy[i] = vy[j];
        vy[j] = vy[i];
        
      }
    }
  } 
}


// Check collisions between mass-line
// Elastic collisions, speed is divided by 2...
void checkCollisionLines() {
  float crit_dist;
  
  for (int i = 0; i < numOfseg; i++){
    for (int j = numOfseg-1; j > i; j--) {
      crit_dist = (y[j] - y[j-1])*x[i] - (x[j] - x[j-1])*y[i] + x[j]*y[j-1] - y[j]*x[j-1];
      crit_dist = crit_dist/sqrt(sq(y[j]-y[j-1]) + sq(x[j]-x[j-1]));
      
      if (crit_dist < diam) {
        int jn = j-1;
        println("Collision detected for "+ i +  " and  line between " + j + " and " + jn);
      }
    }
  }
}

void RungeKutta4() {
  // if there is external forcing at the leading edge
  if (movingTip) x[0] = (width/2) + (Amplitude * sin(omega * t));
  
  t += dt;
  
  if ((freeFall) && (t > freeT)) init_i = 0;
  else init_i = 1;
  
  for (int i = init_i; i < numOfseg; i++) {
    
    // get k1
    x1 = x[i];
    y1 = y[i];
    vx1 = vx[i];
    vy1 = vy[i];
    
    if (i > 0) F = force(x[i-1],x1,y[i-1],y1,stiffness[i-1]);  // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x1,x[i+1],y1,y[i+1],stiffness[i]); // calculate force from spring below (if any)
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
    
    if (i > 0) F = force(x[i-1],x2,y[i-1],y2,stiffness[i-1]); // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x2,x[i+1],y2,y[i+1],stiffness[i]); // calculate force from spring below (if any)
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
    
    if (i > 0) F = force(x[i-1],x3,y[i-1],y3,stiffness[i-1]); // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x3,x[i+1],y3,y[i+1],stiffness[i]); // calculate force from spring below (if any)
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
    
    if (i > 0) F = force(x[i-1],x4,y[i-1],y4,stiffness[i-1]); // calculate force from spring above
    if ( i < numOfseg-1) {
      Temp = force(x4,x[i+1],y4,y[i+1],stiffness[i]); // calculate force from spring below (if any)
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

// Gracefully terminate writing...
void keyPressed() {
  if (wrSwitch) {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  exit(); // Stops the program
  }
}