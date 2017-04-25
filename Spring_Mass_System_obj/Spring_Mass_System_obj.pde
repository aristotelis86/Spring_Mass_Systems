
MassObj [] masses;
SpringObj [] springs;
PVector [] positions, velocities;

int numOfmass = 3;
int numOfspring = numOfmass - 1;
float massDist = 100;
float natLength = 0 * massDist;
float mass = 1;
float stiffness = 1;
float radius = 10;
float angle = 0;
float dt =0.05;



void setup() {
  size(800, 600);
  //frameRate(50);
  masses = new MassObj[numOfmass];
  springs = new SpringObj[numOfspring];
  positions = new PVector[numOfmass];
  velocities = new PVector[numOfmass];
  
  for (int i = 0; i < numOfmass; i++) {
    positions[i] = new PVector(i * massDist * sin(angle) + width / 2, i * massDist * cos(angle) + 30);
    velocities[i] = new PVector(0, 0);
    masses[i] = new MassObj(positions[i].x, positions[i].y, mass, radius);
  }
  for (int i = 0; i < numOfspring; i++) {
    springs[i] = new SpringObj(masses[i], masses[i+1], stiffness, 0, natLength);
    springs[i].solve_stiffness();
    println(springs[i].stiffness);
  }
  
  
}

void draw() {
  background(25);
  for (MassObj m : masses) m.display();
  for (SpringObj s : springs) {
    s.display();
    s.applyForces();
  }
  
  SimpleEuler();
  
  //for (MassObj m : masses) m.resolveBoundaryCollision();
  //for (MassObj m : masses) println(m.force);
  //noLoop();
}

void SimpleEuler() {
  for (int i = 1; i < numOfmass; i++) {
    masses[i].applyForce(new PVector(0,1));
    float ax = masses[i].force.x / mass;
    float ay = masses[i].force.y / mass;
    
    masses[i].velocity.x += ax * dt;
    masses[i].velocity.y += ay * dt;
    
    masses[i].position.x += masses[i].velocity.x * dt;
    masses[i].position.y += masses[i].velocity.y * dt;
    
  }
}