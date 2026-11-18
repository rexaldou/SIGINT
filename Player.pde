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
    float targetX = col * cellSize; 
    float targetY = row * cellSize;
    
    // 1. HANYA MUNCULKAN GHOST TRAIL SAAT SEDANG BERGERAK (ANTI SILAU)
    if (dist(currentX, currentY, targetX, targetY) > 2) {
      trails.add(new GhostTrail(currentX, currentY));
    }
    
    // Gerakan dibuat lebih mulus (gliding)
    currentX = lerp(currentX, targetX, 0.22); 
    currentY = lerp(currentY, targetY, 0.22);
    
    // 2. RENDER BAYANGAN DASH YANG LEMBUT (TRANSPARANSI RENDAH)
    noStroke();
    for (int i = trails.size() - 1; i >= 0; i--) {
      GhostTrail t = trails.get(i); 
      t.life--; 
      fill(80, 220, 160, t.life * 6); // Mint lembut & tipis
      rect(t.x + 18, t.y + 18, cellSize - 36, cellSize - 36, 8);
      if (t.life <= 0) trails.remove(i);
    }
    
    // 3. CEK STATUS PARRY (80ms)
    if (millis() - parryTimer < 80) isParrying = true; 
    else isParrying = false;
    
    // 4. DESAIN KARAKTER SLEEK (TENGAH GELAP, GARIS TEPI SOFT MINT)
    fill(15, 30, 25, 220); // Isi kotak gelap adem
    if (isParrying) {
      stroke(200, 255, 255); strokeWeight(3); // Cyan terang saat parry
    } else if (iFrameTimer > 0) {
      // I-Frame TANPA kedap-kedip: Warna biru muda lembut yang berdenyut halus
      float pulse = map(sin(frameCount * 0.2), -1, 1, 100, 220);
      stroke(100, 220, 255, pulse); strokeWeight(2);
    } else {
      stroke(80, 230, 140, 200); strokeWeight(2); // Hijau mint ramah mata
    }
    rect(currentX + 14, currentY + 14, cellSize - 28, cellSize - 28, 8);
    
    // Inti AI kecil di tengah kotak (Core Node)
    noStroke();
    fill(isParrying ? color(255) : color(80, 230, 140, 180));
    rect(currentX + cellSize/2 - 8, currentY + cellSize/2 - 8, 16, 16, 4);
    
    // 5. EFEK RING PARRY & COOLDOWN (LEBIH TRANSPARAN)
    if (isParrying) { 
      noFill(); stroke(150, 255, 255, 180); strokeWeight(2); 
      ellipse(currentX + cellSize/2, currentY + cellSize/2, cellSize * 0.85, cellSize * 0.85); 
    }
    if (millis() - lastParryAttempt < 450) { 
      noStroke(); fill(255, 80, 80, 45); 
      ellipse(currentX + cellSize/2, currentY + cellSize/2, cellSize * 0.35, cellSize * 0.35); 
    }
  }
  
  void displayUI() { 
    textSize(18); textAlign(LEFT, TOP); 
    // Masking HP jadi Hex acak saat Bos 9 Rage Mode (<= 50% HP) atau di Bos 10
    boolean corruptHP = (level == 9 && isBossActive && b1 != null && b1.hp <= b1.maxHp / 2) || (level >= 10);
    if (corruptHP) {
      fill(255, 80, 100);
      text("INTEGRITY: 0x" + hex(int(random(4096, 65535)), 4) + " [CORRUPTED]", 15, 15);
    } else {
      fill(120, 240, 160); // Hijau mint adem ramah mata
      text("INTEGRITY: " + hp + " HP", 15, 15); 
    }
  }
  
  void move(int kCode, char k, int maxCols, int maxRows, boolean isDashUnlocked) {
    int startRow = row; int startCol = col;
    
    int dir = (reverseControlsTimer > 0) ? -1 : 1;
    if (kCode == UP || k == 'w') row = max(0, row - 1); 
    else if (kCode == DOWN || k == 's') row = min(maxRows - 1, row + 1); 
    else if (kCode == LEFT || k == 'a') col = max(0, col - 1); 
    else if (kCode == RIGHT || k == 'd') col = min(maxCols - 1, col + 1);
    
    // Kalau berhasil pindah dan skill Dash aktif, kasih I-Frame (Kebal)!
    if ((row != startRow || col != startCol) && isDashUnlocked) {
      iFrameTimer = 20; // Kasih kebal sekitar 0.3 detik pas gerak
    }
  }
}
