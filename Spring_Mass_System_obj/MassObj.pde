class MassObj {
  // Attributes
  PVector position;
  PVector velocity;
  PVector force;
  float mass;
  boolean fixed;  
  float radius;
  color c = color(random(255), random(255), random(255));
  
  // Construct MassObj
  MassObj(float tempX, float tempY, float m, float r) {
    position = new PVector(tempX, tempY);
    velocity = new PVector(0,0);
    force = new PVector(0, 0);
    mass = m;
    radius = r;
    fixed = false;
  }
  
  
  // Methods 
  void applyForce(PVector Force) {
    force.add(Force);
  }
  
  void clearForce() {
    force.mult(0);
  }
  
  void resolveBoundaryCollision() {
    if ((position.x < 3) || (position.x > width -3)) velocity.x *= -1;
    if ((position.y < 3) || (position.y > height -3)) velocity.y *= -1;
  }
  
  void display() {
    noStroke();
    fill(c);
    ellipse(position.x, position.y, radius, radius);
  }
  
  void makeFree() {
    fixed = false;
  }
  
  void makeFixed() {
    fixed = true;
  }
  
  Boolean isFree() {
    return fixed;
  }
  
  float distance2otherMass(MassObj m) {
    float dist = position.dist(m.position);
    return dist;
  }
  
  void resolveMassCollision(MassObj m) {
    
  }
  
}