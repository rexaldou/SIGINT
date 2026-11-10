class Bullet {
  float x, y, speed;
  int row;
  boolean active = true;
  String type; 
  
  Bullet(int col, int row, int cellSize, String type) {
    x = col * cellSize + cellSize/2;
    y = row * cellSize + cellSize/2;
    this.row = row;
    this.type = type;
    speed = type.equals("PLASMA") ? 15 : 10;
  }
  
  void update(Boss b, boolean autoAim) {
    // Plasma ga butuh auto-aim karena gede banget
    if (autoAim && !type.equals("PLASMA")) { 
      float targetY = b.row * 150 + 75; // Asumsi cellSize 150
      y = lerp(y, targetY, 0.05);
    }
    x += speed;
    if (x > width) active = false;
  }
  
  void display() {
    if (type.equals("PLASMA")) {
      fill(0, 255, 255); rect(x, y - 20, 80, 40); // Laser Gede
    } else {
      fill(#39FF14); rect(x, y - 5, 20, 10); // Peluru biasa
    }
  }
  
  boolean checkHit(Boss b, int cellSize) {
    if (!active) return false;
    float bLeft = b.col * cellSize;
    if (this.row == b.row && this.x > bLeft) return true;
    return false;
  }
}
