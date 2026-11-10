class GhostTrail { float x, y; int life = 10; GhostTrail(float _x, float _y) { x = _x; y = _y; } }

class Player {
  int col, row; float currentX, currentY; int hp = 5; 
  int parryTimer = 0, lastParryAttempt = 0; boolean isParrying = false;
  int iFrameTimer = 0; // I-FRAME KALO SUKSES PARRY
  
  ArrayList<GhostTrail> trails = new ArrayList<GhostTrail>();
  
  Player(int startCol, int startRow, int cellSize) {
    col = startCol; row = startRow;
    currentX = col * cellSize; currentY = row * cellSize;
  }
  
  void display(int cellSize) {
    float targetX = col * cellSize; float targetY = row * cellSize;
    trails.add(new GhostTrail(currentX, currentY));
    currentX = lerp(currentX, targetX, 0.3); currentY = lerp(currentY, targetY, 0.3);
    
    for (int i = trails.size() - 1; i >= 0; i--) {
      GhostTrail t = trails.get(i); t.life--; fill(#39FF14, t.life * 15); rect(t.x + 10, t.y + 10, cellSize - 20, cellSize - 20, 8);
      if (t.life <= 0) trails.remove(i);
    }
    
    if (millis() - parryTimer < 150) { isParrying = true; fill(255); } 
    else { isParrying = false; fill(#39FF14); }
    
    // KEDAP KEDIP I-FRAME
    if (iFrameTimer > 0) {
      if (frameCount % 4 < 2) fill(255); else fill(#39FF14);
    }
    
    rect(currentX + 10, currentY + 10, cellSize - 20, cellSize - 20, 8);
    
    if (isParrying) { noFill(); stroke(255); strokeWeight(3); ellipse(currentX + cellSize/2, currentY + cellSize/2, cellSize, cellSize); }
    if (millis() - lastParryAttempt < 1000) { fill(255, 0, 0, 100); ellipse(currentX + cellSize/2, currentY + cellSize/2, cellSize/2, cellSize/2); }
  }
  
  void displayUI() { fill(#39FF14); textSize(20); textAlign(LEFT, TOP); text("INTEGRITY: " + hp + " HP", 15, 15); }
  
  void move(int kCode, char k, int maxCols, int maxRows, boolean useDash) {
    int step = useDash ? 2 : 1; 
    if (kCode == UP || k == 'w') { row = max(0, row - step); } 
    else if (kCode == DOWN || k == 's') { row = min(maxRows - 1, row + step); } 
    else if (kCode == LEFT || k == 'a') { col = max(0, col - step); } 
    else if (kCode == RIGHT || k == 'd') { col = min(maxCols - 1, col + step); }
  }
}
