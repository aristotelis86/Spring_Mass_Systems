//////////////////////////////////////////////////////////////////////
//////////////////////// INPUTS Section //////////////////////////////
// Parameters of the filament
float FilamLength = 250, FilamMass = 25;
int numOfpoint = 43; // number of points used to simulate the filament
float nat_seg = 0.5; // resting to segment length ratio for springs

// Time variables
float dt = 0.1; // time step of simulation
float t = 0; // init time variable
float freeT = 3; // time of release to perform free fall

// Boolean Inputs
boolean alignX = false; // create the filament along x-axis
boolean initAng = false; // initialize with an angle
boolean movingTip = false; // introduce external forcing at leading edge
boolean freeVib = false; // check shapes without gravity
boolean freeFall = false; // let the filament drop
boolean wrSwitch = false; // create output file with positions
boolean sinInit = false; // create a sinus-like image for the filament as initial state
boolean pinEnd = false; // trailing edge is pinned

// Initial Condition - Shape parameters
float angle = PI/8; // initial angle of the entire filament from aligning axis
float sinAmp = 20; // amplitude of initial displacement for the filament's points
float sinN = 1; // mode number of the filament

// Moving leading edge parameters
float Amplitude = 100; // amplitude of oscillatory motion
float omega = 2*PI*.2; // frequency of oscillatory motion

// Gravity 
PVector gravity = new PVector(0, 10); // magnitude of gravity (y-direction, positive down )


//////////////////////// END of INPUTS Section //////////////////////////////
/////////////////////////////////////////////////////////////////////////////

// Parameterization of simulation variables
int numOfspring = numOfpoint - 1;
float segLength = FilamLength / numOfspring; // distance between points
float diam = (FilamLength / 2) / numOfpoint; // radius of circles showing the points (only for design purposes)
float mass = FilamMass / numOfpoint; // mass of each point
float natLength;


// Declaration of variables used
float [] x, y, vx, vy, ax, ay; // position, velocity and acceleration for each point-mass
float [] stiffness; // array for stiffness of each spring

PrintWriter output; // handles output file

MassObj [] masses;
SpringObj [] springs;

// Runge-Kutta temp variables
float x1, y1, x2, y2, x3, y3, x4, y4;
float vx1, vy1, vx2, vy2, vx3, vy3, vx4, vy4;
float ax1, ay1, ax2, ay2, ax3, ay3, ax4, ay4;
PVector F, Temp; // forces

///////////////////////////////////////////////////////////////////
// Setup Section
void setup() {
  size(800, 600);
  // Initialization
  Initializer(nat_seg);
  if (freeVib) spring_initialize(0);
  else spring_initialize();
  
  masses[0].makeFixed();
  if (pinEnd) masses[numOfpoint-1].makeFixed();

  if (wrSwitch) {
    output = createWriter("positions.txt");
    output.println("t, x, y");
  }
  //noLoop();
} // end of setup



void draw() {
  background(25);
  textSize(32);
  text(t, 10, 30);

  // Display
  for (SpringObj s : springs) s.display();
  for (MassObj m : masses) m.display();
  
  ////for (int i = 0; i < numOfspring; i++) println(stiffness[i]);
  //// Update
  //RungeKutta4(t, dt);
  //t += dt;

  //// Check Collisions


  //// Resolve Collisions



  ////noLoop();
}





///////////////////////////////////////////////////////////////////////////////
/////////////////////// Runge Kutta 4th Order /////////////////////////////////
void RungeKutta4(float t, float dt) {
  // if there is external forcing at the leading edge
  if (movingTip) masses[0].position.x = (width/2) + (Amplitude * sin(omega * t));

  if ((freeFall) && (t > freeT)) masses[0].makeFree();

  for (int i = 0; i < numOfpoint; i++) {
    if (!masses[i].fixed) {
      float xold = masses[i].position.x;
      float yold = masses[i].position.y;
      float vxold = masses[i].velocity.x;
      float vyold = masses[i].velocity.y;
      
      F = new PVector(0, 0);
      
      // get k1
      x1 = xold;
      y1 = yold;
      vx1 = vxold;
      vy1 = vyold;

      if (i > 0) F = springs[i-1].getForceB();  // calculate force from spring above
      if ( i < numOfpoint-1) {
        Temp = springs[i].getForceA(); // calculate force from spring below (if any)
        F.add(Temp);
      }
      Temp = gravity.copy();
      Temp.mult(mass);
      F.add(Temp); // add gravity
      // calculate acceleration
      ax1 = F.x/mass; 
      ay1 = F.y/mass;
      
      // get k2
      x2 = xold + 0.5*vx1*dt;
      y2 = yold + 0.5*vy1*dt;
      vx2 = vxold + 0.5*ax1*dt;
      vy2 = vyold + 0.5*ay1*dt;
      masses[i].updatePosition(x2, y2);

      if (i > 0) F = springs[i-1].getForceB(); // calculate force from spring above
      if ( i < numOfpoint-1) {
        Temp = springs[i].getForceA(); // calculate force from spring below (if any)
        F.add(Temp);
      }
      Temp = gravity.copy();
      Temp.mult(mass);
      F.add(Temp); // add gravity 
      // calculate acceleration
      ax2 = F.x/mass;
      ay2 = F.y/mass;
      
      // get k3
      x3 = xold + 0.5*vx2*dt;
      y3 = yold + 0.5*vy2*dt;
      vx3 = vxold + 0.5*ax2*dt;
      vy3 = vyold + 0.5*ay2*dt;
      masses[i].updatePosition(x3, y3);

      if (i > 0) F = springs[i-1].getForceB(); // calculate force from spring above
      if ( i < numOfpoint-1) {
        Temp = springs[i].getForceA(); // calculate force from spring below (if any)
        F.add(Temp);
      }
      Temp = gravity.copy();
      Temp.mult(mass);
      F.add(Temp); // add gravity 
      // calculate acceleration
      ax3 = F.x/mass;
      ay3 = F.y/mass;

      // get k4
      x4 = xold + vx3*dt;
      y4 = yold + vy3*dt;
      vx4 = vxold + ax3*dt;
      vy4 = vyold + ay3*dt;
      masses[i].updatePosition(x4, y4);

      if (i > 0) F = springs[i-1].getForceB(); // calculate force from spring above
      if ( i < numOfpoint-1) {
        Temp = springs[i].getForceA(); // calculate force from spring below (if any)
        F.add(Temp);
      }
      Temp = gravity.copy();
      Temp.mult(mass);
      F.add(Temp); // add gravity 
      // calculate acceleration
      ax4 = F.x/mass;
      ay4 = F.y/mass;

      // Final step - Update positions + velocities
      float xnew = xold + (dt/6)*(vx1 + 2*vx2 + 2*vx3 + vx4);
      float ynew = yold + (dt/6)*(vy1 + 2*vy2 + 2*vy3 + vy4);

      float vxnew = vxold + (dt/6)*(ax1 + 2*ax2 + 2*ax3 + ax4);
      float vynew = vyold + (dt/6)*(ay1 + 2*ay2 + 2*ay3 + ay4);
      
      masses[i].updatePosition(xnew, ynew);
      masses[i].updateVelocity(vxnew, vynew);
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
/////////////////////// Initializer ///////////////////////////////////////////
void Initializer(float ratio) {
  natLength = ratio*segLength;
  
  x = new float[numOfpoint];
  y = new float[numOfpoint];
  masses = new MassObj[numOfpoint];
  springs = new SpringObj[numOfspring];
  stiffness = new float[numOfspring];
  
  // Create initial geometry
  if (!sinInit) {
    if ((alignX) && (!initAng)){
      for (int i = 0; i < numOfpoint; i++) {
        y[i] = height/2;
        x[i] = i * segLength + width/15;
        masses[i] = new MassObj(x[i], y[i], mass, diam);
      }
    }
    else if ((!alignX) && (!initAng)){
      for (int i = 0; i < numOfpoint; i++) {
        y[i] = i * segLength + height/15;
        x[i] = width/2;
        masses[i] = new MassObj(x[i], y[i], mass, diam);
      }
    }
    else if ((alignX) && (initAng)){
      for (int i = 0; i < numOfpoint; i++) {
        x[i] = i * segLength * cos(angle) + width/15;
        y[i] = i * segLength * sin(angle) + height/2;
        masses[i] = new MassObj(x[i], y[i], mass, diam);
      }
    }
    else if ((!alignX) && (initAng)){
      for (int i = 0; i < numOfpoint; i++) {
        x[i] = i * segLength * sin(angle) + width/2;
        y[i] = i * segLength * cos(angle) + height/15;
        masses[i] = new MassObj(x[i], y[i], mass, diam);
      }
    }
   }
   else if (sinInit) {
      if (alignX) {
        for (int i = 0; i < numOfpoint; i++) {
          float offsetY = height/2;
          float offsetX = width/15;
          x[i] = i * segLength + offsetX;
          y[i] = sinAmp * sin(sinN*PI*(x[i]-offsetX)/FilamLength) + offsetY;
          masses[i] = new MassObj(x[i], y[i], mass, diam);
        }
      }
      else {
        for (int i = 0; i < numOfpoint; i++) {
          float offsetY = height/15;
          float offsetX = width/2;
          y[i] = i * segLength + offsetY;
          x[i] = sinAmp * sin(sinN*PI*(y[i]-offsetY)/FilamLength) + offsetX;
          masses[i] = new MassObj(x[i], y[i], mass, diam);
        }
      }
    }
}

///////////////////////////////////////////////////////////////////////////////
/////////////////////// Springs - Stiffness ///////////////////////////////////
void spring_initialize() {  
  // Calculate stiffness of springs
  for (int i = 0; i < numOfspring; i++) {
    stiffness[i] = (gravity.mag()/abs(natLength - segLength)) * (numOfspring-i) * mass;
  }
  // Create springs
  for (int i = 0; i < numOfspring; i++) {
    springs[i] = new SpringObj( masses[i], masses[i+1], stiffness[i], 0, natLength );
  }
}

void spring_initialize(float stiff) {
  for (int i = 0; i < numOfspring; i++) stiffness[i] = stiff; // constant stiffness without gravity
  // Create springs
  for (int i = 0; i < numOfspring; i++) {
    springs[i] = new SpringObj( masses[i], masses[i+1], stiffness[i], 0, natLength );
  }
}

void mousePressed() {
  loop();
}

void mouseReleased() {
  noLoop();
}