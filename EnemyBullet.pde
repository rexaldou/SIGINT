class EnemyBullet {
  float x, y; int row;
  float speed = 6; 
  boolean active = true, isMalware = true; 

  EnemyBullet(int startCol, int startRow, int cellSize) {
    x = startCol * cellSize + cellSize / 2;
    y = startRow * cellSize + cellSize / 2;
    row = startRow;
  }

  // Sekarang butuh data Bos buat mantul balik!
  void update(Player p, Boss b, int cellSize) {
    if (isMalware) {
      float targetY = p.row * cellSize + cellSize / 2.0;
      y = lerp(y, targetY, 0.03); 
      row = int(y / cellSize); x -= speed; 
    } else {
      // HOMING PARRY KE BOSS!
      float targetY = b.row * cellSize + cellSize / 2.0;
      y = lerp(y, targetY, 0.08); 
      row = int(y / cellSize); x += speed * 3; 
    }
    if (x < 0 || x > width) active = false; 
  }

  void display() {
    if (isMalware) fill(255, 0, 0); else fill(#39FF14);             
    noStroke(); rect(x, y - 10, 40, 20); 
    fill(255); textSize(12); textAlign(CENTER, CENTER);
    if (isMalware) text("INFECTION: TRUE", x + 20, y); else text("INFECTION: FALSE", x + 20, y);
  }

  boolean checkHitPlayer(Player p, int cellSize) {
    float pLeft = p.col * cellSize; float pRight = pLeft + cellSize;
    return (active && isMalware && this.row == p.row && this.x > pLeft && this.x < pRight);
  }
  
  boolean checkHitBoss(Boss b, int cellSize) {
    float bLeft = b.col * cellSize;
    return (active && !isMalware && this.row == b.row && this.x > bLeft);
  }
}
