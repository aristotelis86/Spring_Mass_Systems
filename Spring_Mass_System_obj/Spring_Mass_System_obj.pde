//////////////////////// INPUTS Section //////////////////////////////
// Parameters of the filament
float FilamLength = 250, FilamMass = 25;
int numOfpoint = 20; // number of points used to simulate the filament

// Time variables
float dt = 0.1; // time step of simulation
float t = 0; // init time variable

// Boolean Inputs
boolean movingTip = false; // introduce external forcing at leading edge
boolean freeFall = false; // let the filament drop
boolean wrSwitch = false; // create output file with positions
boolean sinInit = true; // create a sinus-like image for the filament as initial state

// Initial Condition - Shape parameters
float angle = PI/4; // initial angle of the entire filament from vertical axis
float sinAmp = 20; // amplitude of initial displacement for the filament's points
float sinN = 4; // mode number of the filament

// Moving leading edge parameters
float Amplitude = 100; // amplitude of oscillatory motion
float omega = 2*PI*.2; // frequency of oscillatory motion

// Gravity 
float gravity = 10; // magnitude of gravity (y-direction, positive down )


//////////////////////// END of INPUTS Section //////////////////////////////
/////////////////////////////////////////////////////////////////////////////

// Parameterization of simulation variables
int numOfspring = numOfpoint - 1;
float segLength = FilamLength / numOfspring; // distance between points
float natLength = 0.5*segLength;
float diam = (FilamLength / 2) / numOfpoint; // radius of circles showing the points (only for design purposes)
float mass = FilamMass / numOfpoint; // mass of each point


// Declaration of variables used
float [] x, y, vx, vy, ax, ay; // position, velocity and acceleration for each point-mass
float [] stiffness; // array for stiffness of each spring

PrintWriter output; // handles output file

MassObj [] masses;
SpringObj [] springs;

///////////////////////////////////////////////////////////////////
// Setup Section
void setup() {
  size(800, 600);
  // Initialization
  x = new float[numOfpoint];
  y = new float[numOfpoint];
  masses = new MassObj[numOfpoint];
  springs = new SpringObj[numOfspring];
  stiffness = new float[numOfspring];
  
  // Apply initial conditions - Create the initial shape
  if (sinInit) {
    for (int i = 0; i < numOfpoint; i++) {
      y[i] = i * segLength + 30;
      x[i] = sinAmp * sin(sinN*PI*(y[i]-30)/FilamLength) + width/2;
      masses[i] = new MassObj(x[i], y[i], mass, diam);
    }
  }
  else{
    for (int i = 0; i < numOfpoint; i++) {
      y[i] = i * segLength * cos(angle) + 30;
      x[i] = i * segLength * sin(angle) + width/2;
      masses[i] = new MassObj(x[i], y[i], mass, diam);
    }
  }
  
  for (int i = 0; i < numOfspring; i++) {
    stiffness[i] = (gravity/abs(natLength - segLength)) * (numOfspring-i) * mass;
  }
  
  for (int i = 0; i < numOfspring; i++) {
    springs[i] = new SpringObj( masses[i], masses[i+1], stiffness[i], 0, natLength );
  }
  
  if (wrSwitch) {
    output = createWriter("positions.txt");
    output.println("t, x, y");
  }
  
} // end of setup

void draw() {
  background(25);
  
  // Display
  for (SpringObj s : springs) s.display();
  for (MassObj m: masses) m.display();
  
  
  // Update
  
  
  // Check Collisions
  
  
  // Resolve Collisions
  
  
  
  
}