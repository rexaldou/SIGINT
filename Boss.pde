class Boss {
  int col = 3, row = 1, nextCol = -1, nextRow = -1, targetCol = -1, targetRow = -1;
  int wipeType = 0; 
  int lastActionTime = 0, moveTime = 0, lastShootTime = 0, teleportTimer = 0; 
  int warningDuration = 800, attackDuration = 300;
  
  boolean isWarning = false, isAttacking = false, wantsToShoot = false, isMoving = false; 
  boolean isParryable = false; // BIRU ATAU MERAH
  int maxHp, hp, bossLevel; boolean isEnraged = false; 
  
  Boss(int currentLevel) { bossLevel = currentLevel; maxHp = 100 + (currentLevel * 50); hp = maxHp; lastActionTime = millis(); moveTime = millis(); lastShootTime = millis(); }
  
  void update(Player p) {
    if (hp <= maxHp / 2 && !isEnraged) isEnraged = true; 
    int currentMoveDelay = isEnraged ? 400 : 1000; 
    int currentShootDelay = isEnraged ? 800 : 1500; 
    int currentTime = millis();
    
    if (!isMoving && currentTime - moveTime > currentMoveDelay) { 
      nextCol = int(random(1, 4)); nextRow = int(random(4)); isMoving = true; teleportTimer = currentTime;
    }
    if (isMoving && currentTime - teleportTimer > (bossLevel >= 4 ? 0 : 350)) { 
      col = nextCol; row = nextRow; isMoving = false; moveTime = currentTime; 
    }
    if (currentTime - lastShootTime > currentShootDelay) { wantsToShoot = true; lastShootTime = currentTime; }
    
    if (!isWarning && !isAttacking && currentTime - lastActionTime > 1500) { 
      isParryable = (random(1) > 0.5); // 50% MERAH, 50% BIRU
      if (bossLevel >= 2 && random(1) > 0.5) {
        wipeType = (random(1) > 0.5) ? 1 : 2; 
        if (wipeType == 1) targetRow = p.row; else targetCol = p.col; 
      } else { wipeType = 0; targetCol = p.col; targetRow = p.row; }
      isWarning = true; lastActionTime = currentTime;
    }
    
    if (isWarning && currentTime - lastActionTime > warningDuration) { isWarning = false; isAttacking = true; lastActionTime = currentTime; }
    if (isAttacking && currentTime - lastActionTime > attackDuration) { isAttacking = false; wipeType = 0; lastActionTime = currentTime; }
  }
  
  void display(int cellSize) {
    if (isMoving && bossLevel < 4) {
      stroke(255, 120, 0, 150); strokeWeight(3); noFill(); rect(nextCol * cellSize + 10, nextRow * cellSize + 10, cellSize - 20, cellSize - 20, 8); noStroke();
    }
    if (isEnraged) fill(255, 120, 0); else fill(255, 0, 100);
    rect(col * cellSize + 10, row * cellSize + 10, cellSize - 20, cellSize - 20, 8);
    fill(255, 0, 100); textSize(20); textAlign(RIGHT, TOP); text("MALWARE ROOTKIT: " + hp, width - 15, 15);
    
    // RENDER WARNA LANTAI (Merah vs Biru)
    if (isWarning) {
      if (isParryable) fill(0, 150, 255, 150); else fill(200, 200, 0, 150); 
    } else if (isAttacking) {
      if (isParryable) fill(0, 255, 255, 200); else fill(255, 0, 0, 200);
    }
    
    if (isWarning || isAttacking) {
      if (wipeType == 1) rect(0, targetRow * cellSize, width, cellSize); 
      else if (wipeType == 2) rect(targetCol * cellSize, 0, cellSize, height); 
      else rect(targetCol * cellSize, targetRow * cellSize, cellSize, cellSize);
    }
  }
  
  boolean checkHit(Player p) {
    if (!isAttacking) return false;
    if (wipeType == 1 && p.row == targetRow) return true; 
    if (wipeType == 2 && p.col == targetCol) return true; 
    if (wipeType == 0 && p.col == targetCol && p.row == targetRow) return true;
    return false;
  }
}
