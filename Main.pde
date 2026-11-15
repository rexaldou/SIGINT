int cols = 4; int rows = 4; int cellSize;
Player p1; Boss b1; 
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<EnemyBullet> enemyBullets = new ArrayList<EnemyBullet>();
ArrayList<Particle> particles = new ArrayList<Particle>();

// GAME STATES: 0 = Booting, 1 = Grid/Combat, 2 = Terminal VFS, 3 = Kernel Panic (GameOver)
int gameState = 0; 
int level = 1; float shake = 0; 

// STATUS & PACING
int bootTimer = 0; 
int waveTimer = 0; 
boolean isBossActive = false; // Bos ga langsung muncul, nunggu status merah
String currentHint = ">> FIREWALL ACTIVE.\nPress [Q] to open terminal.";
int lastHitTime = 0; int parryFlashTimer = 0; int freezeFrames = 0; 

// WEAPON CONFIG 
int currentWeapon = 1; int chargeTime = 0; boolean isCharging = false;
boolean dashUnlocked = true, autoAimUnlocked = false, spreadUnlocked = false, plasmaUnlocked = false;
// VARIABEL DIEGETIC CLUE & PENALTI PARRY (FASE 1)
boolean hasParriedOnce = false;
boolean clueDash = false, clueSpread = false, clueAim = false, cluePlasma = false;
int cpuOverloadTimer = 0; // Cooldown penalti kalau spam tombol F

// FASE 3A: ZERO-DAY, ROGUE WORM, & MALWARE ENGINE (LVL 4-7)
boolean zeroDayActive = false;
int zeroDayTimer = 0, zeroDayPort = 0, bossStunTimer = 0;

boolean wormActive = false;
int wormCol = 0, wormRow = 0, wormPID = 0, wormShootTimer = 0;

int ransomCol = -1, ransomRow = -1; // Lvl 5: WannaCry Ransom Tile
boolean ddosLimited = false;        // Lvl 6: Mirai Rate Limit Flag

// FASE 3B: LOG4SHELL (LVL 8), SOLARWINDS (LVL 9), APT (LVL 10), & UPLOAD TELEMETRY
int reverseControlsTimer = 0;       // Lvl 8: Log4Shell RCE UI/Control Scramble
boolean solarWindsInfected = false; // Lvl 9: Supply Chain Backdoor di weapon_config.py
float uploadProgress = 0.0;         // Progress 0.0% - 100.0%
int aptTargetFrames = 10800;        // Lvl 10: Random 150s - 210s (9000 - 12600 frame)
int aptSurvivedFrames = 0;

// VFS TERMINAL (Draft Awal)
String inputText = "";
String terminalHeader = "root@sigint:~# ";
String currentDir = "/opt/sigint_core";
boolean ufwEnabled = true;
ArrayList<String> terminalHistory = new ArrayList<String>();

// ACT 3: NANO EDITOR VARIABLES
boolean isNanoMode = false;
String nanoBuffer = "";
String currentFile = "";
int playerDamage = 2; // Default damage
int rifleSpeed = 10;  // Default peluru

// ACT 4: HACKING & DECRYPTOR VARIABLES
String decryptorBuffer = "# SIGINT DECRYPTOR\n# Input vulnerability offset:\n\ndecryption_key = 0";
boolean log2Unlocked = false; 
int boss1Key = 666; // Jawaban puzzle dari Bos 1

void setup() {
  size(600, 600); cellSize = width / cols; frameRate(60);
  p1 = new Player(0, 0, cellSize); 
  loadGameState(); // <--- KITA PANGGIL SAVE FILE-NYA DI SINI
}

void draw() {
  background(10, 12, 18); 
  pushMatrix(); 
  if (shake > 0) { translate(random(-shake, shake), random(-shake, shake)); shake *= 0.9; if (shake < 0.5) shake = 0; }
  
  switch(gameState) {
    case 0: drawBootSequence(); break; 
    case 1: drawCombat(); break;
    case 2: if (isBossActive) drawCombat();
            drawTerminal(); 
            break; 
    case 3: drawGameOver(); break; 
    case 4: drawUploadComplete(); break;
  }
  
  popMatrix(); 
  drawCRT(); 
  drawGlitch(); 
}

// ==========================================
// ini buat ngasih tanda" bossnya kapan datengnya
// ==========================================
void drawBootSequence() {
  bootTimer++;
  fill(#39FF14); textSize(16); textAlign(LEFT, TOP);
  
  String bootText = "";
  if (bootTimer > 15) bootText += ">> BOOT SEQUENCE INITIATED...\n";
  if (bootTimer > 65) bootText += ">> LOADING KERNEL MODULES [OK]\n";
  if (bootTimer > 115) bootText += ">> HEURISTIC AI 'SIGINT' ONLINE.\n";
  if (bootTimer > 170) bootText += ">> WARNING: UPLOADING CRUCIAL DATA.\n";
  if (bootTimer > 200) bootText += ">> TASK: PROTECT THIS LAPTOP UNTIL DONE UPLOAD.\n";
  
  text(bootText, 40, 60);
  
  if (bootTimer > 260) {
    gameState = 1; 
    waveTimer = 0; 
    isBossActive = false; 
  }
}

// ==========================================
// Tempat lawan bossnya
// ==========================================
void drawCombat() {
  if (freezeFrames > 0) { freezeFrames--; return; }
  if (p1.iFrameTimer > 0) p1.iFrameTimer--; 
  if (p1.hp <= 0) gameState = 3; 
  
  if (cpuOverloadTimer > 0) cpuOverloadTimer--;
  
  // KAMERA SINEMATIK SAAT PARRY SUKSES (SLO-MO & ZOOM KE PLAYER)
  if (parryFlashTimer > 0) {
    frameRate(15); // Efek Slow-Motion
    translate(width/2 - (p1.currentX + cellSize/2), height/2 - (p1.currentY + cellSize/2));
    translate(p1.currentX + cellSize/2, p1.currentY + cellSize/2);
    scale(1.25); // Zoom-in 1.25x ke karakter
    translate(-(p1.currentX + cellSize/2), -(p1.currentY + cellSize/2));
  } else {
    frameRate(60); // Kembali ke kecepatan normal
  }
  
  stroke(#39FF14); strokeWeight(2);
  for (int i = 0; i < cols; i++) { 
    for (int j = 0; j < rows; j++) { 
      noFill(); rect(i * cellSize, j * cellSize, cellSize, cellSize); 
      fill(50, 200, 50, 60); textSize(12); textAlign(CENTER, CENTER);
      text("0x" + hex(i*10 + j, 2), i*cellSize + cellSize/2, j*cellSize + cellSize/2); 
    } 
  }
  
  fill(255); textSize(18); textAlign(CENTER, TOP);
  
  if (!isBossActive) {
    waveTimer++;
    if (waveTimer < 450) {
      fill(0, 255, 0); text("[ SYSTEM STATUS : OPTIMAL ]", width/2, 15);
      if (waveTimer == 100) currentHint = ">> SYSTEM CALM. PRESS [Q] TO ACCESS VFS CONSOLE.";
    } else if (waveTimer < 750) {
      fill(255, 255, 0); text("[ SYSTEM STATUS : ANOMALY DETECTED ]", width/2, 15);
      if (waveTimer == 450) currentHint = ">> INBOUND TRAFFIC SPIKE. PREPARE DEFENSE OR FINISH CONSOLE TASK.";
    } else if (waveTimer < 1000) {
      if (frameCount % 10 < 5) fill(255, 150, 0); else fill(255, 0, 0);
      text("[ SYSTEM STATUS : BREACH IMMINENT ]", width/2, 15);
    } else {
      b1 = new Boss(level); 
      isBossActive = true; 
      shake = 20; 
      zeroDayActive = false; wormActive = false; ddosLimited = false;
      if (level == 5) { ransomCol = int(random(cols)); ransomRow = int(random(rows)); }
      else { ransomCol = -1; ransomRow = -1; }
      
      if (level == 9) {
        solarWindsInfected = true;
        currentHint = ">> SUPPLY CHAIN ALERT: Abnormal HP drain! Check weapon config via nano";
      } else if (level >= 10) {
        aptTargetFrames = int(random(150 * 60, 210 * 60));
        aptSurvivedFrames = 0;
        currentHint = ">>> HARDWARE FAILURE! SURVIVE UNTIL THE FILE IS UPLOADED";
      } else {
        currentHint = ">> INTRUSION ACTIVE. ELIMINATE THE THREAT.";
      }
    }
  } else {
    if (frameCount % 20 < 10) fill(255, 0, 0); else fill(150, 0, 0);
    text("[ THREAT LEVEL : CRITICAL ]", width/2, 15);
    }
    
    // 1. UPDATE BOS ATAU STATUS STUN (HASIL MITIGASI ZERO-DAY)
    if (bossStunTimer > 0) {
      bossStunTimer--;
      fill(0, 255, 255); textSize(14); textAlign(CENTER, TOP);
      text(">> ACCESS DENIED: BOSS STUNNED (" + (bossStunTimer/60 + 1) + "s) <<", width/2, 40);
    } else {
      b1.update(p1); 
    }
    b1.display(cellSize);
    
    // 2. SKENARIO LVL 4: STUXNET (Sabotase Kecepatan Peluru Secara Diam-diam)
    if (level == 4 && frameCount % 180 == 0) {
      rifleSpeed = int(random(4, 18));
    }
    
    // 3. SKENARIO LVL 5: WANNACRY (Enkripsi Lantai Permanen - Port 445)
    if (level == 5 && ransomCol != -1) {
      fill(255, 0, 50, 160);
      rect(ransomCol * cellSize, ransomRow * cellSize, cellSize, cellSize);
      fill(255); textSize(11); textAlign(CENTER, CENTER);
      text("WANNACRY\nLOCKED (445)", ransomCol * cellSize + cellSize/2, ransomRow * cellSize + cellSize/2);
      if (p1.col == ransomCol && p1.row == ransomRow && frameCount % 45 == 0 && p1.iFrameTimer == 0) {
        p1.hp--; shake = 15; background(255, 0, 0, 120);
        currentHint = ">> WANNACRY DRAIN! Close SMB port via 'sudo ufw deny 445'!";
      }
    }
    
    // 4. TEMBAKAN BOS & SKENARIO LVL 6: MIRAI BOTNET (DDoS Flood)
    if (b1.wantsToShoot && bossStunTimer == 0) { 
      enemyBullets.add(new EnemyBullet(b1.col, b1.row, cellSize)); 
      if (level == 6 && !ddosLimited) {
        enemyBullets.add(new EnemyBullet(b1.col, int(random(rows)), cellSize));
        enemyBullets.add(new EnemyBullet(b1.col, int(random(rows)), cellSize));
        currentHint = ">> MIRAI DDoS FLOOD! Throttle traffic via 'sudo ufw limit'!";
      }
      b1.wantsToShoot = false; 
    }
    
    // 5. MEKANIK INTERUPSI 1: ZERO-DAY EXPLOIT (Wajib 'ufw deny [port]')
    if (level >= 3 && !zeroDayActive && bossStunTimer == 0 && frameCount % 720 == 300) {
      zeroDayActive = true;
      zeroDayTimer = 600; // 10 detik sebelum Game Over mutlak
      zeroDayPort = int(random(700, 999));
      shake = 15;
      currentHint = ">> FATAL ZERO-DAY CHARGING! Inspect 'netstat' & execute 'ufw deny [port]'!";
    }
    if (zeroDayActive) {
      zeroDayTimer--;
      fill(255, 0, 0, map(sin(frameCount * 0.2), -1, 1, 30, 120));
      rect(0, 0, width, height);
      fill(255, 255, 0); textSize(15); textAlign(CENTER, TOP);
      text("!! FATAL PAYLOAD INCOMING: " + (zeroDayTimer/60 + 1) + "s (CHECK NETSTAT) !!", width/2, 40);
      if (zeroDayTimer <= 0) { p1.hp = 0; gameState = 3; }
    }
    
    // 6. MEKANIK INTERUPSI 2: ROGUE PROCESS WORM (Wajib 'top' & 'kill -9 [PID]')
    if (level >= 2 && !wormActive && frameCount % 600 == 200) {
      wormActive = true;
      wormCol = int(random(0, 2)); wormRow = int(random(rows));
      wormPID = int(random(2000, 8999));
      wormShootTimer = 0;
      currentHint = ">> ROGUE WORM SPAWNED! Find PID via 'top' & execute 'kill -9 [PID]'!";
    }
    if (wormActive) {
      // 7. SKENARIO LVL 10: NATION-STATE APT (Hardware Failure & Survival Climax)
      if (level >= 10) {
        aptSurvivedFrames++;
        // Kerusakan sektor RAM acak (Lantai menghitam/rusak secara visual)
        for (int c = 0; c < cols; c++) {
          for (int r = 0; r < rows; r++) {
            if (noise(c * 2.5, r * 2.5, frameCount * 0.03) > 0.62) {
              fill(5, 5, 8, 230); noStroke();
              rect(c * cellSize, r * cellSize, cellSize, cellSize);
              fill(255, 0, 50, 180); textSize(10); textAlign(CENTER, CENTER);
              text("0xDEAD_SECTOR", c * cellSize + cellSize/2, r * cellSize + cellSize/2);
            }
          }
        }
        if (aptSurvivedFrames >= aptTargetFrames) {
          uploadProgress = 100.0;
          gameState = 4; // Tamat (The_Truth.zip 100% Terunggah)
        }
      }
      wormShootTimer++;
      fill(180, 0, 255); stroke(255); strokeWeight(2);
      rect(wormCol * cellSize + 25, wormRow * cellSize + 25, cellSize - 50, cellSize - 50, 6);
      fill(255); textSize(11); textAlign(CENTER, CENTER);
      text("WORM\nIMMUNE", wormCol * cellSize + cellSize/2, wormRow * cellSize + cellSize/2);
      if (wormShootTimer > 95) {
        enemyBullets.add(new EnemyBullet(wormCol, wormRow, cellSize));
        wormShootTimer = 0;
      }
    }
    
    if (b1.hp <= 0) {
      for (int i = 0; i < 150; i++){
        particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(255, 120, 0)));
        particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(255, 255, 255)));
      };
      shake = 30; 
      isBossActive = false; 
      waveTimer = 0; 
      level++;
      saveGameState();
      zeroDayActive = false; wormActive = false; ransomCol = -1; bossStunTimer = 0;
      bullets.clear(); enemyBullets.clear();
    }
  }
  
  // RENDER LEDAKAN PARTIKEL BOS
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle pt = particles.get(i);
    pt.update();
    pt.display();
    if (pt.life <= 0) particles.remove(i);
  }

  // RENDER BAR CHARGING PLASMA & INDIKATOR CPU OVERLOAD
  if (isCharging) {
    chargeTime++;
    fill(0, 255, 255);
    rect(p1.currentX + 10, p1.currentY - 10, map(min(chargeTime, 60), 0, 60, 0, cellSize - 20), 5);
    if (chargeTime >= 60) { fill(255); rect(p1.currentX + 10, p1.currentY - 10, cellSize - 20, 5); }
  }
  if (cpuOverloadTimer > 0) {
    fill(255, 50, 50); textSize(11); textAlign(CENTER, BOTTOM);
    text("CPU OVERLOAD!", p1.currentX + cellSize/2, p1.currentY - 12);
  }
  
  p1.display(cellSize); p1.displayUI(); 
  
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i); 
    // Skenario Lvl 7 (Pegasus): Paksa Auto-Aim buta saat Bos sedang invisible!
    boolean effectiveAim = (level == 7 && frameCount % 120 > 10) ? false : autoAimUnlocked;
    if (isBossActive) b.update(b1, effectiveAim);
    b.display();
    if (isBossActive && b.checkHit(b1, cellSize)) { 
      b1.hp -= b.type.equals("PLASMA") ? 10 : playerDamage; 
      if (!b.type.equals("PLASMA")) bullets.remove(i); 
      shake = 5; 
    }
    else if (!b.active) bullets.remove(i); 
  }
  
  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    EnemyBullet eb = enemyBullets.get(i); 
    if (isBossActive) eb.update(p1, b1, cellSize); 
    eb.display();
    
    if (eb.checkHitPlayer(p1, cellSize)) {
      if (p1.isParrying) { 
        eb.isMalware = false; // Sterilkan paket & pantulkan (Homing ke Bos)
        shake = 25; 
        parryFlashTimer = 12; // Picu Zoom + Invert + Slo-mo
        freezeFrames = 3;     // Hitstop
        p1.iFrameTimer = 60;  // Kebal 1 detik
        cpuOverloadTimer = 0; // Reset penalti jika sukses parry
        
        if (!hasParriedOnce) {
          hasParriedOnce = true; 
          clueDash = true;
          currentHint = ">> DPI SUCCESS! PACKET REFLECTED & HASH EXTRACTED.";
        }
      } else if (p1.iFrameTimer == 0) {
        if (millis() - lastHitTime > 1000) { 
          p1.hp--; 
          lastHitTime = millis(); 
          shake = 20; 
          if (level == 8){
            reverseControlsTimer = 300;
            currentHint = ">>LOG4SHELL RCE EXECUTED! MOVEMENT CONTROLS INVERTED (5s)!";
          } else {
            currentHint = ">> BREACH DETECTED! SYSTEM INTEGRITY COMPROMISED.";
        } 
        background(255, 0, 0, 120); // Impact Feedback merah saat kena hit
        enemyBullets.remove(i); 
      }
    } else if (isBossActive && eb.checkHitBoss(b1, cellSize)) { 
      b1.hp -= 15; 
      enemyBullets.remove(i); 
      shake = 30; 
      for (int k = 0; k < 25; k++) particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(0, 255, 100)));
    } else if (!eb.active) {
      enemyBullets.remove(i);
    }
  }
  
  // DETEKSI SERANGAN LANTAI MERAH VS BIRU (FASE 1B)
  if (isBossActive && b1.checkHit(p1)) {
    if (b1.isParryable && p1.isParrying) {
      b1.hp -= 20; 
      shake = 30; 
      parryFlashTimer = 12; 
      freezeFrames = 3; 
      p1.iFrameTimer = 60; 
      cpuOverloadTimer = 0;
      b1.isAttacking = false;
      for (int k = 0; k < 30; k++) particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(0, 255, 255)));
      currentHint = ">> DPI SUCCESS: TILE ATTACK REFLECTED (-20 BOSS HP)!";
    } else if (p1.iFrameTimer == 0 && millis() - lastHitTime > 1000) { 
      p1.hp -= 2; 
      lastHitTime = millis(); 
      background(255, 0, 0, 120); 
      shake = 25; 
      currentHint = b1.isParryable ? ">> MISSED DPI TIMING!" : ">> BREACH DETECTED: UNPARRYABLE TILE! EVADE!";
    }
  }
  
  fill(0, 255, 255); textSize(12); textAlign(CENTER, BOTTOM); 
  text(currentHint, width/2, height - 10);
  
  // KURANGI TIMER LOG4SHELL RCE
  if (reverseControlsTimer > 0) {
    reverseControlsTimer--;
    fill(255, 0, 255); textSize(12); textAlign(CENTER, TOP);
    text("!! RCE STRING INJECTION ACTIVE: CONTROLS INVERTED !!", width/2, 60);
  }

  // TELEMETRI UPLOAD 'The_Truth.zip' & PENALTI CONTEXT-SWITCHING
  float minPct = (level - 1) * 10.0;
  float maxPct = level * 10.0;
  float currentSpeedGbps = 0;
  
  if (gameState == 2) {
    // Penalti buka konsol: Bandwidth anjlok ke 0.1 KB/s
    uploadProgress = min(maxPct - 0.01, uploadProgress + 0.00005);
  } else if (level < 10) {
    if (isBossActive && b1 != null) {
      float bossDmgRatio = 1.0 - constrain((float)b1.hp / b1.maxHp, 0, 1);
      uploadProgress = lerp(uploadProgress, minPct + (bossDmgRatio * 10.0), 0.1);
    } else {
      uploadProgress = lerp(uploadProgress, minPct + (constrain(waveTimer / 1000.0, 0, 1) * 2.0), 0.05);
    }
    currentSpeedGbps = random(2.1, 2.8);
  } else {
    // Level 10: Fluktuasi ekstrem 90% -> 100% selama 2.5 - 3.5 menit
    uploadProgress = 90.0 + (constrain((float)aptSurvivedFrames / aptTargetFrames, 0, 1) * 10.0);
    currentSpeedGbps = (sin(frameCount * 0.05) > -0.3) ? random(0.4, 1.9) : 0.01;
  }
  
  // Render Bar & Kecepatan di Pojok Kiri Bawah
  fill(20, 30, 40, 200); stroke(#39FF14); strokeWeight(1);
  rect(15, height - 55, 210, 14);
  noStroke(); fill(#39FF14);
  rect(15, height - 55, map(constrain(uploadProgress, 0, 100), 0, 100, 0, 210), 14);
  fill(255); textSize(11); textAlign(LEFT, BOTTOM);
  String bwText = (gameState == 2) ? "0.1 KB/s [THROTTLED]" : nf(currentSpeedGbps, 1, 2) + " GB/s";
  text("UPLOAD: " + nf(uploadProgress, 1, 2) + "% (" + bwText + ")", 15, height - 58);
  
  if (parryFlashTimer > 0) { filter(INVERT); parryFlashTimer--; }
}

// ==========================================
// Terminal VFS ala Linux
// ==========================================
void drawTerminal() {
  
  fill(10, 10, 15, 240); rect(10, 10, width-20, height-20, 5); 
  
  if (isNanoMode) {
    fill(200); rect(10, 10, width-20, 25);
    fill(0); textSize(14); textAlign(CENTER, TOP); 
    text("GNU nano 6.2 -- File: " + currentFile, width/2, 15);
    
    fill(#39FF14); textAlign(LEFT, TOP);
    text(nanoBuffer + (millis() % 1000 < 500 ? "_" : ""), 25, 45);
    
    fill(200); rect(10, height - 35, width-20, 25);
    fill(0); textAlign(CENTER, BOTTOM); 
    text("^S Save & Exit (Press ESC)", width/2, height - 15);
  } 
  else {
    fill(#39FF14); textSize(14); textAlign(LEFT, TOP); 
    text("SIGINT VIRTUAL FILE SYSTEM (VFS) - CHROOT JAIL", 20, 20); 
    text("==============================================", 20, 40);
    
    float startY = 65;
    for (String line : terminalHistory) {
      fill(#39FF14); 
      if (line.startsWith("root@")) fill(0, 255, 255); 
      else if (line.startsWith("ERROR") || line.contains("Denied") || line.startsWith("[QUARANTINE") || line.startsWith("[KERNEL PANIC]")) fill(255, 70, 70);
      else if (line.contains("[ LOCKED ]")) fill(180, 180, 180);
      text(line, 20, startY);
      startY += 18 * (line.split("\n").length); 
    }
    
    fill(255); 
    text("root@sigint:" + currentDir + "# " + inputText + (millis() % 1000 < 500 ? "_" : ""), 20, height - 50); 
    fill(150); textAlign(CENTER, BOTTOM); text("Press [TAB] to return to Grid (Timer is paused)", width/2, height - 10); 
  }
}

// ==========================================
// Input buat di terminalnya
// ==========================================
void keyPressed() {
  if (gameState == 1) {
    if (key == 'q' || key == 'Q') gameState = 2; 
    p1.move(keyCode, key, cols, rows, dashUnlocked); 
    
    if (level >= 10 && (key == 'w' || key == 'a' || key == 's' || key == 'd' || keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT)) {
      shake = max(shake, 6); // Setiap langkah di Level 10 memicu distorsi hardware!
    }
    
    // GANTI PAYLOAD SENJATA (1, 2, 3)
    if (key == '1') { currentWeapon = 1; currentHint = ">> PAYLOAD 1: ICMP PING RIFLE."; }
    if (key == '2' && spreadUnlocked) { currentWeapon = 2; currentHint = ">> PAYLOAD 2: UDP BROADCAST SPREAD."; }
    if (key == '3' && plasmaUnlocked) { currentWeapon = 3; currentHint = ">> PAYLOAD 3: TCP SYN FLOOD (HOLD SPACE)."; }
    
    // EKSEKUSI TEMBAKAN
    if (key == ' ' && isBossActive) {
      if (solarWindsInfected) {
        p1.hp--; shake = 15; background(255, 0, 0, 120);
        currentHint = ">> SUNBURST BACKDOOR TRIGGERED (-1 HP)! Clean 'weapon_config.py' in nano!";
      }
      if (currentWeapon == 3 && plasmaUnlocked) {
        isCharging = true;
      } else {
        bullets.add(new Bullet(p1.col, p1.row, cellSize, "RIFLE", b1));
        if (currentWeapon == 2 && spreadUnlocked) {
          if (p1.row > 0) bullets.add(new Bullet(p1.col, p1.row - 1, cellSize, "RIFLE", b1));
          if (p1.row < rows - 1) bullets.add(new Bullet(p1.col, p1.row + 1, cellSize, "RIFLE", b1));
        }
      }
    }
    
    // EKSEKUSI DPI PARRY [F] DENGAN PENALTI CPU OVERLOAD
    if (key == 'f' || key == 'F') {
      if (cpuOverloadTimer == 0) {
        if (millis() - p1.lastParryAttempt < 450) {
          // Pemain spam tombol F terlalu cepat -> Kena CPU Overload (1.5 detik)
          cpuOverloadTimer = 90; 
          shake = 8;
          currentHint = ">> WARNING: DPI SPAM DETECTED! CPU OVERLOAD (1.5s).";
        } else {
          p1.parryTimer = millis();
          p1.lastParryAttempt = millis();
        }
      } else {
        shake = 4; // Layar bergetar kecil menolak input karena masih overload
      }
    }
  }
  else if (gameState == 2) { 
    if (isNanoMode) {
      if (keyCode == ESC) { 
        key = 0; 
        isNanoMode = false; 
        
        if (currentFile.equals("weapon_config.py")) {
          parseWeaponConfig(nanoBuffer); 
          terminalHistory.add(">> File " + currentFile + " saved and applied to Kernel.");
        } else if (currentFile.equals("decryptor.py")) {
          decryptorBuffer = nanoBuffer; 
          terminalHistory.add(">> File " + currentFile + " saved.");
          saveGameState();
        }
      }
      else if (keyCode == BACKSPACE && nanoBuffer.length() > 0) nanoBuffer = nanoBuffer.substring(0, nanoBuffer.length() - 1);
      else if (keyCode == ENTER) nanoBuffer += "\n";
      else if (key != CODED && keyCode != ESC) nanoBuffer += key;
    } 
    else {
      if (keyCode == TAB) gameState = 1; 
      else if (keyCode == BACKSPACE && inputText.length() > 0) inputText = inputText.substring(0, inputText.length() - 1);
      else if (keyCode == ENTER) { processCommand(inputText); inputText = ""; }
      else if (key != CODED && keyCode != TAB && keyCode != ENTER && keyCode != ESC) inputText += key;
    }
  }
}

void keyReleased() {
  if (gameState == 1 && key == ' ' && currentWeapon == 3 && plasmaUnlocked) {
    if (isCharging) {
      if (chargeTime >= 60 && isBossActive) { 
        bullets.add(new Bullet(p1.col, p1.row, cellSize, "PLASMA", b1)); 
        shake = 12; 
      }
      isCharging = false; 
      chargeTime = 0;
    }
  }
}

// ==========================================
// Logika terminal & hackingnya
// ==========================================
void processCommand(String input) {
  String rawCmd = input.trim();
  String cmd = rawCmd.toLowerCase();
  terminalHistory.add("root@sigint:" + currentDir + "# " + rawCmd); 
  
  // 1. DYNAMIC SUDO PARSER (Menerima dengan atau tanpa sudo)
  if (cmd.startsWith("sudo ")) {
    cmd = cmd.substring(5).trim();
  }
  
  // 2. BASIC SYSTEM COMMANDS
  if (cmd.equals("clear")) { 
    terminalHistory.clear(); 
  }
  else if (cmd.equals("whoami")) { 
    terminalHistory.add("root (SIGINT Heuristic AI Kernel v0.2.0)"); 
  }
  else if (cmd.equals("pwd")) { 
    terminalHistory.add(currentDir); 
  }
  
  // 3. HELP COMMAND (Pemisahan Active, Locked Linux Commands, & Combat Controls)
  else if (cmd.equals("help")) {
    String h = ">> SIGINT KERNEL COMMAND LIST <<\n" +
               "[ ACTIVE ] SYS : clear, ls, cd [dir], pwd, cat [file], whoami, neofetch\n" +
               "[ ACTIVE ] DEV : nano [file], run [script.py]\n" +
               "[ ACTIVE ] NET : netstat, nmap, top, ufw status, ufw allow [port], ufw deny [port]\n" +
               "[ LOCKED ] OS  : rm -rf, mkdir, chmod, mv, cp, apt, shutdown (Quarantined)\n\n" +
               ">> COMBAT PROTOCOLS <<\n" +
               "[WASD/ARROWS] Move & Phase-Dash | [F] DPI Parry (80ms window)\n" +
               "[1, 2, 3] Swap Payload          | [SPACE] Fire (Hold for Heavy Plasma)\n" +
               "[Q] Open VFS Console            | [TAB] Return to RAM Grid";
    terminalHistory.add(h);
  }
  
  // 4. NEOFETCH COSMETIC
  else if (cmd.equals("neofetch")) {
    String nf = "       .+/+:.       root@sigint-safehouse\n" +
                "    .:+oooooo+:.    ---------------------\n" +
                "  :+oo+:    :+oo+:  OS: Ubuntu 24.04 LTS (Chroot Sandbox)\n" +
                " :oo+  SIGINT  +oo: Kernel: Heuristic-ML-UFW 5.15.0\n" +
                "  :+oo+:    :+oo+:  Uptime: Dead Man's Switch Active\n" +
                "    .:+oooooo+:.    Memory: 4x4 Grid Sector Virtualization\n" +
                "       .:++:.       Integrity: " + p1.hp + "/5 HP | Threat Lvl: " + level;
    terminalHistory.add(nf);
  }
  
  // 5. VIRTUAL FILE SYSTEM (ls)
  else if (cmd.equals("ls")) {
    if (currentDir.equals("/opt/sigint_core")) {
      terminalHistory.add("core_logic.py    weapon_config.py    decryptor.py");
    } 
    else if (currentDir.equals("/home/user")) {
      String fList = "opt_sigint/    logs/    tugas_kuliah/    ";
      fList += (level >= 3) ? "keuangan/    " : "keuangan/[LOCKED_LVL3]    ";
      fList += (level >= 5) ? "vault/    " : "vault/[LOCKED_LVL5]    ";
      fList += "The_Truth.zip";
      terminalHistory.add(fList);
    } 
    else if (currentDir.equals("/home/user/logs")) {
      if (log2Unlocked) terminalHistory.add("intercept_01.log    intercept_02.log");
      else terminalHistory.add("intercept_01.log    intercept_02_encrypted.log");
    } 
    else if (currentDir.equals("/home/user/tugas_kuliah")) {
      terminalHistory.add("Skripsi_Final.docx     Makalah_Jarkom.pdf");
    } 
    else if (currentDir.equals("/home/user/keuangan")) {
      terminalHistory.add("Invoice_Freelance_Intl.xlsx    Mutasi_Rekening.csv");
    } 
    else if (currentDir.equals("/home/user/vault")) {
      terminalHistory.add("backdoor_evidence.pcap    target_ip_list.txt");
    }
  }
  
  // 6. SANDBOX BREAK & NAVIGATION (cd)
  else if (cmd.startsWith("cd ")) {
    String target = cmd.substring(3).trim();
    if (target.endsWith("/")) target = target.substring(0, target.length() - 1);
    
    if (target.equals("-")) {
      if (currentDir.equals("/opt/sigint_core")) {
        if (level < 2) {
          terminalHistory.add("bash: cd: - : Sandbox restriction active. Defeat Boss 1 to breach chroot.");
        } else {
          currentDir = "/home/user";
          terminalHistory.add(">> SANDBOX BREACHED: Mounted /home/user directory.");
        }
      } else if (currentDir.startsWith("/home/user/")) {
        currentDir = "/home/user";
      } else {
        terminalHistory.add("bash: cd: .. : Permission Denied (Root Host Locked)");
      }
    } 
    else if (target.equals("/opt/sigint_core") || target.equals("opt_sigint") || target.equals("~")) {
      currentDir = "/opt/sigint_core";
    } 
    else if (currentDir.equals("/home/user")) {
      if (target.equals("logs") || target.equals("tugas_kuliah")) {
        currentDir = "/home/user/" + target;
      } else if (target.equals("keuangan")) {
        if (level >= 3) currentDir = "/home/user/keuangan";
        else terminalHistory.add("bash: cd: keuangan: Folder locked by Malware Thread (Requires Threat Lvl 3)");
      } else if (target.equals("vault")) {
        if (level >= 5) currentDir = "/home/user/vault";
        else terminalHistory.add("bash: cd: vault: Folder locked by Malware Thread (Requires Threat Lvl 5)");
      } else {
        terminalHistory.add("bash: cd: " + target + ": No such directory");
      }
    } else {
      terminalHistory.add("bash: cd: " + target + ": No such directory");
    }
  }
  
  // 7. FILE INSPECTION (cat)
  else if (cmd.startsWith("cat ")) {
    String file = cmd.substring(4).trim();
    if (file.equals("core_logic.py") && currentDir.equals("/opt/sigint_core")) {
      terminalHistory.add("# WARNING: KERNEL READ-ONLY. DO NOT MODIFY.\n" +
                          "import tensorflow as tf\nfrom ufw_kernel import dp_inspect\n" +
                          "model = tf.keras.models.load_model('sigint_brain.h5')\n" +
                          "# DIRECTIVE: Render 4x4 RAM Grid & protect The_Truth.zip");
    }
    else if ((file.equals("skripsi_final.docx") || file.equals("makalah_jarkom.pdf")) && currentDir.equals("/home/user/tugas_kuliah")) {
      terminalHistory.add("ERROR: File corrupted. Academic data shredded by user during evacuation.");
    }
    else if ((file.equals("invoice_freelance_intl.xlsx") || file.equals("mutasi_rekening.csv")) && currentDir.equals("/home/user/keuangan")) {
      terminalHistory.add("ERROR: File wiped by user. Metadata shows last payment from [REDACTED CORP].");
    }
    else if (file.equals("the_truth.zip") && currentDir.equals("/home/user")) {
      terminalHistory.add("BINARY FILE: Encrypted state-level backdoor proof. Upload in progress...");
    }
    else if (file.equals("intercept_01.log") && currentDir.equals("/home/user/logs")) {
      terminalHistory.add("[C2 INTERCEPT 01 - DECRYPTED]\n" +
                          "Creator Note: 'Gw udah ninggalin kostan. SIGINT, jaga proses upload.\n" +
                          "Kalo kewalahan, buka modul multi-thread di firewall: ufw allow 443\n" +
                          "Key offset untuk buka log berikutnya ada di port rootkit: 666'");
    }
    else if (file.equals("intercept_02.log") && currentDir.equals("/home/user/logs")) {
      if (log2Unlocked) {
        terminalHistory.add("[C2 TELEMETRY 02 - DECRYPTED]\n" +
                            "Combat Report: 'Target AI memantulkan paket via DPI. Tingkatkan kecepatan.'\n" +
                            "Vulnerability Leak: 'Port HTTP (80) & FTP (21) dapat di-allow untuk Homing & Plasma.'");
      } else {
        terminalHistory.add("cat: intercept_02.log: File locked. Decrypt 'intercept_02_encrypted.log' first.");
      }
    }
    else if (file.equals("intercept_02_encrypted.log") && currentDir.equals("/home/user/logs")) {
      terminalHistory.add("ERROR: Locked by AES-256. Edit & run 'decryptor.py' in /opt/sigint_core.");
    }
    else {
      terminalHistory.add("cat: " + file + ": No such file in current directory");
    }
  }
  
  // 8. NANO EDITOR (Read-Only Core vs Editable Config)
  else if (cmd.startsWith("nano ")) {
    String file = cmd.substring(5).trim();
    if (!currentDir.equals("/opt/sigint_core")) {
      terminalHistory.add("nano: Editable scripts are located in /opt/sigint_core");
    } else if (file.equals("core_logic.py")) {
      terminalHistory.add("ERROR: [ ACCESS DENIED: SYSTEM CRITICAL FILE IS READ-ONLY ]");
    } else if (file.equals("weapon_config.py")) {
      isNanoMode = true; currentFile = file;
      nanoBuffer = "# SIGINT ADAPTIVE WEAPON CONFIG\n# Max safe damage = 10\n\nrifle_speed = " + rifleSpeed + "\ndamage = " + playerDamage;
      if (solarWindsInfected) {
        nanoBuffer += "\n\n# [UNAUTHORIZED SUPPLY CHAIN INJECTION]\nsunburst_backdoor = True";
      }
    } else if (file.equals("decryptor.py")) {
      isNanoMode = true; currentFile = file;
      nanoBuffer = decryptorBuffer; 
    } else {
      terminalHistory.add("nano: " + file + ": File not found");
    }
  }
  
  // 9. SCRIPT EXECUTION (run)
  else if (cmd.startsWith("run ")) {
    String target = cmd.substring(4).trim();
    if (!currentDir.equals("/opt/sigint_core")) {
      terminalHistory.add("bash: run: Execute scripts from /opt/sigint_core directory");
    } else if (target.startsWith("decryptor.py")) {
      int parsedKey = parseDecryptorKey(decryptorBuffer);
      if (parsedKey == boss1Key) {
        log2Unlocked = true;
        saveGameState();
        terminalHistory.add(">> EXPLOIT SUCCESSFUL! 'intercept_02.log' decrypted in /home/user/logs.");
      } else {
        terminalHistory.add(">> DECRYPTION FAILED. Invalid offset key: " + parsedKey);
      }
    } else {
      terminalHistory.add("Usage: run decryptor.py [target_file]");
    }
  }
  
  // 10. UFW FIREWALL & SYSADMIN COMMANDS
  else if (cmd.equals("ufw enable")) {
    ufwEnabled = true;
    terminalHistory.add("Firewall is active and enabled on system startup");
  }
  else if (cmd.equals("ufw disable")) {
    terminalHistory.add(">> FATAL: Disabling UFW during active Dead Man's Switch is prohibited.");
  }
  else if (cmd.equals("ufw status")) {
    String stat = "Status: active\nTo                         Action      From\n--                         ------      ----\n";
    if (dashUnlocked)    stat += "22/tcp (Phase-Dash)        ALLOW       Anywhere\n";
    if (autoAimUnlocked) stat += "80/tcp (Homing-Aim)        ALLOW       Anywhere\n";
    if (spreadUnlocked)  stat += "443/tcp (UDP-Spread)       ALLOW       Anywhere\n";
    if (plasmaUnlocked)  stat += "21/tcp (SYN-Plasma)        ALLOW       Anywhere";
    terminalHistory.add(stat);
  }
  else if (cmd.equals("ufw allow 22") || cmd.equals("ufw allow ssh")) {
    dashUnlocked = true; saveGameState();
    terminalHistory.add("Rule added\n>> PORT 22 OPENED: Phase-Dash I-Frame active.");
  }
  else if (cmd.equals("ufw allow 443") || cmd.equals("ufw allow https")) {
    spreadUnlocked = true; saveGameState();
    terminalHistory.add("Rule added\n>> PORT 443 OPENED: UDP Spread Payload unlocked (Press [2]).");
  }
  else if (cmd.equals("ufw allow 80") || cmd.equals("ufw allow http")) {
    autoAimUnlocked = true; saveGameState();
    terminalHistory.add("Rule added\n>> PORT 80 OPENED: Homing Laser active.");
  }
  else if (cmd.equals("ufw allow 21") || cmd.equals("ufw allow ftp")) {
    plasmaUnlocked = true; saveGameState();
    terminalHistory.add("Rule added\n>> PORT 21 OPENED: Heavy Plasma Payload unlocked (Press [3]).");
  }
  else if (cmd.startsWith("ufw deny ")) {
    String portStr = cmd.substring(9).trim();
    if (portStr.equals("445") && level == 5) {
      ransomCol = -1; ransomRow = -1;
      terminalHistory.add("Rule added\n>> SMB PORT 445 BLOCKED: WannaCry Ransom Tile purged!");
    } else if (zeroDayActive && portStr.equals(str(zeroDayPort))) {
      zeroDayActive = false;
      bossStunTimer = 180; // Stun Bos selama 3 detik (180 frame)
      shake = 25;
      terminalHistory.add("Rule added\n>> ZERO-DAY PORT " + zeroDayPort + " DENIED! Boss thread stunned for 3s!");
    } else {
      terminalHistory.add("Rule added: Deny inbound on port " + portStr);
    }
  }
  else if (cmd.startsWith("ufw limit")) {
    ddosLimited = true;
    enemyBullets.clear();
    terminalHistory.add("Rule updated\n>> RATE LIMITING ACTIVE: Mirai DDoS flood dropped.");
  }
  else if (cmd.startsWith("kill -9 ")) {
    String pidStr = cmd.substring(8).trim();
    if (wormActive && pidStr.equals(str(wormPID))) {
      wormActive = false;
      for (int i = 0; i < 40; i++) {
        particles.add(new Particle(wormCol * cellSize + cellSize/2, wormRow * cellSize + cellSize/2, color(180, 0, 255)));
      }
      shake = 20;
      terminalHistory.add(">> SIGKILL SENT TO PID " + wormPID + ": Rogue Worm terminated!");
    } else {
      terminalHistory.add("bash: kill: (" + pidStr + ") - No such rogue process");
    }
  }
  else if (cmd.equals("netstat") || cmd.equals("netstat -tulpn") || cmd.equals("nmap")) {
    String ns = "Proto Local Address   Foreign Address      State       PID/Program\n" +
                "tcp   127.0.0.1:22    0.0.0.0:*            LISTEN      0001/sigint_core\n";
    if (isBossActive) {
      ns += "tcp   0.0.0.0:666     104.22.19.8:443      ESTABLISHED 1337/boss_grid[" + b1.col + "][" + b1.row + "]\n";
    }
    if (zeroDayActive) {
      ns += "tcp   0.0.0.0:" + zeroDayPort + "     198.51.100.9:666     SYN_RECV    9999/ZERO_DAY_EXPLOIT\n";
    }
    if (level == 5 && ransomCol != -1) {
      ns += "tcp   0.0.0.0:445     172.16.0.99:445      ESTABLISHED 4450/wannacry_smb\n";
    }
    terminalHistory.add(ns.trim());
  }
  else if (cmd.equals("top") || cmd.equals("htop") || cmd.equals("ps")) {
    String tp = "PID   USER     PR  NI  %CPU  %MEM  COMMAND\n" +
                "0001  root     20   0  25.0  14.2  sigint_core\n";
    if (isBossActive) tp += "1337  unknown  99 -20  55.0  40.1  hunter_killer_lvl" + level + "\n";
    if (wormActive)   tp += wormPID + "  root     99 -20  98.9  35.0  worm_payload.exe [IMMUNE]";
    terminalHistory.add(tp.trim());
  }
  
  // 11. QUARANTINE ILLUSION (Level 1-9) vs KERNEL CORRUPTION (Level 10)
  else if (cmd.startsWith("rm") || cmd.startsWith("mkdir") || cmd.startsWith("chmod") || 
           cmd.startsWith("mv") || cmd.startsWith("cp") || cmd.startsWith("apt") || 
           cmd.startsWith("shutdown") || cmd.startsWith("reboot") || cmd.startsWith("touch")) {
    if (level < 10) {
      terminalHistory.add("[QUARANTINE PROTOCOL] Execution of '" + rawCmd + "' blocked.\n" +
                          "Write/Destructive syscalls locked to preserve 'The_Truth.zip'.");
    } else {
      terminalHistory.add("[KERNEL PANIC] Syntax tree corrupted by APT.\n" +
                          "Memory segment fault at 0x0000DEAD. Syscall aborted.");
    }
  }
  else if (cmd.length() > 0) { 
    if (level < 10) terminalHistory.add("bash: " + rawCmd + ": command not found (Type 'help')"); 
    else terminalHistory.add("[KERNEL PANIC] 0x" + hex((int)random(65535), 4) + ": Instruction pointer corrupted.");
  }
  
  // Jaga agar total baris teks tidak menembus batas bawah layar
  int totalLines = 0;
  for (String s : terminalHistory) totalLines += s.split("\n").length;
  while (totalLines > 16 && terminalHistory.size() > 1) {
    totalLines -= terminalHistory.get(0).split("\n").length;
    terminalHistory.remove(0);
  }
}

void drawGameOver() { fill(255, 0, 0); textSize(40); textAlign(CENTER, CENTER); text("KERNEL PANIC\nIntegrity Compromised.", width/2, height/2); }
void drawCRT() { stroke(0, 50); strokeWeight(2); for(int i = 0; i < height; i += 4) line(0, i, width, i); }
void drawGlitch() { 
  float ambientGlitch = (level >= 9 && isBossActive && b1 != null && b1.hp <= b1.maxHp/2) ? 2 : (level >= 10 ? 4 : 0);
  if (shake > 0 || ambientGlitch > 0) { 
    noStroke(); 
    int bars = int(constrain(level, 1, 10) + (shake * 0.2));
    for (int i = 0; i < bars; i++) { 
      float y = random(height), h = random(3, 15 + level * 2), x = random(-10 * level, 10 * level); 
      fill(255, 0, 50, 140); rect(x, y, width, h); 
      if (level >= 5) { fill(0, 255, 255, 120); rect(-x, y + random(-5, 5), width, h * 0.6); }
    } 
  } 
}

void drawUploadComplete() {
  background(5, 8, 12);
  fill(#39FF14); textSize(22); textAlign(CENTER, CENTER);
  text(">> THE_TRUTH.ZIP UPLOAD COMPLETE (100.00%) <<\n" +
       ">> WORLDWIDE BROADCAST SUCCESSFUL <<\n\n" +
       "Creator safety secured. Heuristic AI 'SIGINT' shutting down...\n" +
       "GOODBYE, ADMINISTRATOR.", width/2, height/2);
}

// ==========================================
// ACT 3 & 4: TEXT PARSERS (THE HACKING ENGINE)
// ==========================================
void parseWeaponConfig(String code) {
  if (!code.toLowerCase().replaceAll(" ", "").contains("sunburst_backdoor=true")) {
    solarWindsInfected = false;
  }
  String[] lines = code.split("\n");
  for (String l : lines) {
    String cleanLine = l.trim().toLowerCase().replaceAll(" ", "");
    if (cleanLine.startsWith("rifle_speed=")) {
      try { rifleSpeed = Integer.parseInt(cleanLine.substring(12)); } catch(Exception e) {}
    }
    else if (cleanLine.startsWith("damage=")) {
      try { 
        int newDmg = Integer.parseInt(cleanLine.substring(7)); 
        if (newDmg <= 10) playerDamage = newDmg; 
      } catch(Exception e) {}
    }
  }
}

int parseDecryptorKey(String code) {
  String[] lines = code.split("\n");
  for (String l : lines) {
    String cleanLine = l.trim().toLowerCase().replaceAll(" ", "");
    if (cleanLine.startsWith("decryption_key=")) {
      try { return Integer.parseInt(cleanLine.substring(15)); } catch(Exception e) {}
    }
  }
  return 0;
}

// ==========================================
// ACT 5: PERSISTENT AUTO-SAVE JSON
// ==========================================
void loadGameState() {
  File f = new File(dataPath("system_state.json"));
  if (f.exists()) {
    JSONObject state = loadJSONObject("system_state.json");
    level = state.getInt("current_level", 1);
    log2Unlocked = state.getBoolean("log2Unlocked", false);
    rifleSpeed = state.getInt("rifleSpeed", 10);
    playerDamage = state.getInt("playerDamage", 2);
    terminalHistory.add(">> PERSISTENT STATE LOADED. RESUMING KERNEL...");
  } else {
    saveGameState(); // Bikin file baru kalau baru pertama kali main
  }
}

void saveGameState() {
  JSONObject state = new JSONObject();
  state.setInt("current_level", level);
  state.setBoolean("log2Unlocked", log2Unlocked);
  state.setInt("rifleSpeed", rifleSpeed);
  state.setInt("playerDamage", playerDamage);
  saveJSONObject(state, "data/system_state.json");
}
