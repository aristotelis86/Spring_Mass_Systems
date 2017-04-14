
MassObj [] masses;
PVector [] positions, velocities;

int numOfmass = 5;
float massDist = 15;
float mass = 3;
float radius = 10;
float angle = PI/6;
float dt =0.05;



void setup() {
  size(800, 600);
  frameRate(50);
  masses = new MassObj[numOfmass];
  positions = new PVector[numOfmass];
  velocities = new PVector[numOfmass];
  
  for (int i = 0; i < numOfmass; i++) {
    positions[i] = new PVector(i * massDist * sin(angle) + width / 2, i * massDist * cos(angle) + 30);
    velocities[i] = new PVector(0, 0);
    masses[i] = new MassObj(positions[i].x, positions[i].y, mass, radius);
  }
  
  
}

void draw() {
  background(25);
  for (MassObj m : masses) m.display();
  
  SimpleEuler();
  
  //noLoop();
}

void SimpleEuler() {
  for (int i = 0; i < numOfmass; i++) {
    masses[i].applyForce(new PVector(0,1));
    float ax = masses[i].force.x / mass;
    float ay = masses[i].force.y / mass;
    
    masses[i].velocity.x += ax * dt;
    masses[i].velocity.y += ay * dt;
    
    masses[i].position.x += masses[i].velocity.x * dt;
    masses[i].position.y += masses[i].velocity.y * dt;
    
    masses[i].resolveBoundaryCollision();
  }
  
}