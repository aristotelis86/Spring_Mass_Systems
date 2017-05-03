class SpringObj {
  float stiffness;
  float damping;
  float restLength;
  MassObj m1, m2;
  
  SpringObj( MassObj a, MassObj b, float s, float d, float r ) {
    m1 = a;
    m2 = b;
    
    stiffness = s;
    damping = d;
    restLength = r;
  }
  
  void display(){
    strokeWeight(1);
    stroke(255);
    line(m1.position.x, m1.position.y, m2.position.x, m2.position.y);
  }
  
  void applyForces() {
    PVector Tension = PVector.sub(m1.position, m2.position);
    float stretch = Tension.mag();
    stretch -= restLength;
    
    Tension.normalize();
    Tension.mult(-stiffness * stretch);
    m1.applyForce(Tension);
    Tension.mult(-1);
    m2.applyForce(Tension);
  }
  
  void solve_stiffness() {
    float gravity = 10;
    float dist = PVector.dist(m1.position, m2.position);
    stiffness = m2.mass * gravity / abs(restLength - dist);
  }
  
}