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
    float baseSpeed = type.equals("PLASMA") ? 15 : 10;
    speedX = (b.col * cellSize > this.x) ? baseSpeed : -baseSpeed;
  }
  
  void update(Boss b, boolean autoAim) {
    if (autoAim && !type.equals("PLASMA")) { 
      float targetY = b.row * 150 + 75; // Asumsi cellSize 150
      float targetX = b.col * 150 + 75;
      y = lerp(y, targetY, 0.1); 
      x = lerp(x, targetX, 0.1);
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
