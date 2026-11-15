class Bullet {
  float x, y, speedX, speedY;
  int row; 
  boolean active = true; 
  String type; 
  
  Bullet(int col, int row, int cellSize, String type, Boss b) {
    x = col * cellSize + cellSize / 2.0; 
    y = row * cellSize + cellSize / 2.0;
    this.row = row; 
    this.type = type;
    
    // Nentuin arah tembakan (Kiri atau Kanan ngikutin posisi Bos)
    float baseSpeed = type.equals("PLASMA") ? 15 : rifleSpeed;
    speedX = (b.col * cellSize > this.x) ? baseSpeed : -baseSpeed;
  }
  
  void update(Boss b, boolean autoAim) {
    if (autoAim && !type.equals("PLASMA")) { 
      float targetY = b.row * cellSize + (cellSize / 2.0); // Asumsi cellSize 150
      float targetX = b.col * cellSize + (cellSize / 2.0);
      y = lerp(y, targetY, 0.12); 
      x = lerp(x, targetX, 0.08);
      this.row = int(y / cellSize);
    } else {
      x += speedX; // Nembak lurus ke kiri/kanan
    }
    // Hapus peluru kalau nabrak ujung layar
    if (x < 0 || x > width) active = false;
  }
  
  void display() {
    if (type.equals("PLASMA")) {
      fill(0, 255, 255); rect(x, y - 20, 80, 40);
    } else {
      fill(#39FF14); rect(x, y - 5, 20, 10);
    }
  }
  
  boolean checkHit(Boss b, int cellSize) {
    if (!active) return false;
    float bLeft = b.col * cellSize;
    float bRight = bLeft + cellSize;
    
    // Hitbox disempurnain biar akurat nembak dari kiri maupun kanan
    if (this.row == b.row && this.x > bLeft && this.x < bRight) {
      return true;
    }
    return false;
  }
}
