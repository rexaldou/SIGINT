// ==========================================
// ACT 6: THE MALWARE BEHAVIOR ENGINE
// ==========================================
class Boss {
  int col, row, hp, maxHp, level;
  int moveTimer = 0, shootTimer = 0;
  boolean wantsToShoot = false;
  
  // Variabel Skala Kesulitan
  int moveDelay = 60, shootDelay = 60;
  boolean isVisible = true; 
  
  // VARIABEL SERANGAN LANTAI MERAH/BIRU (FASE 1B)
  int targetCol = -1, targetRow = -1, wipeType = 0; 
  int lastActionTime = 0, warningDuration = 800, attackDuration = 300;
  boolean isWarning = false, isAttacking = false, isParryable = false;

  Boss(int lvl) {
    level = lvl;
    col = int(random(cols)); 
    row = 0; // Bos selalu spawn di baris paling atas
    
    // PROGRESSION STUDI KASUS CYBERSECURITY BERDASARKAN PRD
    switch(level) {
      case 1: maxHp = 20; moveDelay = 80; shootDelay = 90; break; // Script Kiddie (Lambat)
      case 2: maxHp = 50; moveDelay = 60; shootDelay = 70; break; // Brute Force
      case 3: maxHp = 100; moveDelay = 50; shootDelay = 50; break; // Buffer Overflow
      case 4: maxHp = 150; moveDelay = 40; shootDelay = 45; break; // Stuxnet (Sabotase)
      case 5: maxHp = 200; moveDelay = 40; shootDelay = 40; break; // WannaCry (Ransomware)
      case 6: maxHp = 250; moveDelay = 30; shootDelay = 15; break; // Mirai Botnet (DDoS)
      case 7: maxHp = 300; moveDelay = 20; shootDelay = 50; break; // Pegasus Spyware (Invisible)
      case 8: maxHp = 350; moveDelay = 30; shootDelay = 35; break; // Log4Shell (RCE)
      case 9: maxHp = 400; moveDelay = 20; shootDelay = 30; break; // SolarWinds (Supply Chain)
      default: maxHp = 9999; moveDelay = 15; shootDelay = 20; break; // Lvl 10 APT (Dead Man's Switch)
    }
    hp = maxHp;
    lastActionTime = millis();
  }

  void update(Player p) {
    moveTimer++; 
    shootTimer++;
    
    // Logika Pergerakan AI
    if (moveTimer > moveDelay) {
       col = int(random(cols));
       row = int(random(rows/2)); // Bos cuma muter di area atas grid
       moveTimer = 0;
    }

    // Logika Menembak
    if (shootTimer > shootDelay) {
       wantsToShoot = true;
       shootTimer = 0;
       
       // Skenario Lvl 6: Mirai Botnet (DDoS Flood) - Nembak berkali-kali dalam 1 frame
       if (level == 6) {
         // Logika multi-bullet akan ditangkap di Tab Main nantinya
       }
    }
    
    // Logika Serangan Lantai (Tile Attack)
    int currentTime = millis();
    if (!isWarning && !isAttacking && currentTime - lastActionTime > 1500) { 
      isParryable = (random(1) > 0.5); // 50% Biru (Parryable), 50% Kuning/Merah (Unparryable)
      if (level >= 2 && random(1) > 0.5) {
        wipeType = (random(1) > 0.5) ? 1 : 2; // 1 = Satu Baris Penuh, 2 = Satu Kolom Penuh
        if (wipeType == 1) targetRow = p.row; else targetCol = p.col; 
      } else { 
        wipeType = 0; // 0 = Satu Kotak (Single Tile)
        targetCol = p.col; targetRow = p.row; 
      }
      isWarning = true; 
      lastActionTime = currentTime;
    }
    
    if (isWarning && currentTime - lastActionTime > warningDuration) { 
      isWarning = false; 
      isAttacking = true; 
      lastActionTime = currentTime; 
    }
    if (isAttacking && currentTime - lastActionTime > attackDuration) { 
      isAttacking = false; 
      wipeType = 0; 
      lastActionTime = currentTime; 
    }
  }

  void display(int cellSize) {
    // RENDER WARNA LANTAI (Kuning/Merah vs Biru)
    noStroke();
    if (isWarning) {
      if (isParryable) fill(0, 150, 255, 120); else fill(200, 200, 0, 120); 
    } else if (isAttacking) {
      if (isParryable) fill(0, 255, 255, 200); else fill(255, 0, 0, 200);
    }
    
    if (isWarning || isAttacking) {
      if (wipeType == 1) rect(0, targetRow * cellSize, width, cellSize); 
      else if (wipeType == 2) rect(targetCol * cellSize, 0, cellSize, height); 
      else rect(targetCol * cellSize, targetRow * cellSize, cellSize, cellSize);
    }
    // Skenario Lvl 7: Pegasus Spyware (Zero-Click Exploit)
    // Bos ga kelihatan, cuma muncul ngedip 10 frame setiap 2 detik
    if (level == 7 && frameCount % 120 > 10) return; 

    // Skenario Lvl 10: Nation-State APT (Glitch Render)
    if (level >= 10) {
       fill(random(255), 0, random(255));
       rect(col * cellSize + random(-5, 5), row * cellSize + random(-5, 5), cellSize, cellSize);
    } else {
       // Render Bos Normal
       fill(255, 50, 50); 
       rect(col * cellSize, row * cellSize, cellSize, cellSize);
    }
    
    // Gambar HP Bar (Kecuali Level 10 karena ga bisa dibunuh)
    if (level < 10) {
       fill(100); rect(col * cellSize, row * cellSize - 10, cellSize, 5);
       fill(#39FF14); rect(col * cellSize, row * cellSize - 10, map(hp, 0, maxHp, 0, cellSize), 5);
    }
    
    // Label Bos
    fill(255); textSize(12); textAlign(CENTER, CENTER);
    text(level >= 10 ? "APT" : "LVL " + level, col * cellSize + cellSize/2, row * cellSize + cellSize/2);
  }
  
  boolean checkHit(Player p) {
    if (!isAttacking) return false;
    if (wipeType == 1 && p.row == targetRow) return true; 
    if (wipeType == 2 && p.col == targetCol) return true; 
    if (wipeType == 0 && p.col == targetCol && p.row == targetRow) return true;
    return false;
  }
}
