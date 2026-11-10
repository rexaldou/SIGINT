int cols = 4; int rows = 4; int cellSize;
Player p1; Boss b1; 
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<EnemyBullet> enemyBullets = new ArrayList<EnemyBullet>();
ArrayList<Particle> particles = new ArrayList<Particle>();

int lastHitTime = 0; int deathTimer = 0; int gameState = 7; int level = 1; float shake = 0; 
JSONObject saveFile;

String inputText = ""; String currentHint = ">> FIREWALL ACTIVE.\nType 'help;' for commands.";
boolean dashUnlocked = false, autoAimUnlocked = false, spreadUnlocked = false, plasmaUnlocked = false; 
boolean isGodMode = false; 
boolean hasParriedOnce = false, clueDash = false, clueSpread = false, clueAim = false, cluePlasma = false;

int parryFlashTimer = 0; int freezeFrames = 0; 
int currentWeapon = 1; int chargeTime = 0; boolean isCharging = false;
String terminalHeader = "Ubuntu 24.04 LTS (GNU/Linux 5.15.0-generic x86_64)\nType 'help;' for available commands.";
String loreFullText = "LOG DATE: NOV 2026\n\nCRITICAL BREACH DETECTED IN SECTOR 7.\nUNIDENTIFIED MALWARE [ROOTKIT-CLASS] HAS INFILTRATED THE SYSTEM.\n\nGAMING ACCOUNTS COMPROMISED.\nSOCIAL MEDIA TOKENS CORRUPTED.\n\nDEPLOYING LAST LINE OF DEFENSE: FIREWALL.EXE\n\nYOUR DIRECTIVE: QUARANTINE THE THREAT.\nDO NOT FAIL.";
float loreCurrentIndex = 0; 

void setup() {
  size(600, 600); cellSize = width / cols; frameRate(60);
  p1 = new Player(0, 0, cellSize); b1 = new Boss(level); 
  File f = new File(dataPath("save.json"));
  if (!f.exists()) { saveFile = new JSONObject(); saveFile.setBoolean("system_corrupted", false); saveJSONObject(saveFile, "data/save.json"); } 
  else { saveFile = loadJSONObject("data/save.json"); if (saveFile.getBoolean("system_corrupted") == true) gameState = 5; }
}

void draw() {
  background(10, 12, 18); 
  pushMatrix(); 
  if (shake > 0) { translate(random(-shake, shake), random(-shake, shake)); shake *= 0.9; if (shake < 0.5) shake = 0; }
  
  switch(gameState) {
    case 7: drawLoreIntro(); break; case 0: drawMenu(); break; case 1: drawCombat(); break;
    case 2: drawTerminal(); break; case 3: drawGameOver(); break; case 4: drawWin(); break; 
    case 5: drawSystemLocked(); break; case 6: drawBossDeath(); break;
  }
  popMatrix(); 
  if (gameState != 5) { drawCRT(); drawGlitch(); }
}

void drawCRT() { stroke(0, 50); strokeWeight(2); for(int i = 0; i < height; i += 4) { line(0, i, width, i); } fill(255, random(2, 10)); noStroke(); rect(0, 0, width, height); }
void drawGlitch() {
  if (shake > 0) { noStroke(); for (int i = 0; i < int(random(4, 8)); i++) { float y = random(height), h = random(5, 30), xShift = random(-40, 40); fill(255, 0, 50, 150); rect(xShift, y, width, h); fill(0, 255, 255, 150); rect(-xShift, y + random(-10, 10), width, h); } }
}
void drawLoreIntro() { fill(#39FF14); textSize(18); textAlign(LEFT, TOP); if (loreCurrentIndex < loreFullText.length()) loreCurrentIndex += 0.5; String currentText = loreFullText.substring(0, min((int)loreCurrentIndex, loreFullText.length())); text(currentText, 40, 60); if (loreCurrentIndex >= loreFullText.length() && sin(millis() / 200.0) > 0) { fill(255); textAlign(CENTER, BOTTOM); text("> PRESS [ENTER] TO INITIALIZE <", width/2, height - 40); } }
void drawMenu() { fill(#39FF14); textSize(45); textAlign(CENTER, CENTER); text("FIREWALL.EXE", width/2, height/2 - 50); textSize(16); text("V 7.0 - ARSENAL PROTOCOL", width/2, height/2 - 15); if (sin(millis() / 200.0) > 0) { fill(255); text("> PRESS [ENTER] TO EXECUTE <", width/2, height/2 + 40); } }
void drawGameOver() { fill(255, 0, 0); textSize(40); textAlign(CENTER, CENTER); text("SYSTEM COMPROMISED\nMalware takes over.", width/2, height/2); }
void drawWin() { fill(#39FF14); textSize(40); textAlign(CENTER, CENTER); text("MALWARE QUARANTINED\nPress ENTER to advance.", width/2, height/2); }
void drawSystemLocked() { background(10, 10, 10); fill(255, 0, 0); textSize(40); textAlign(CENTER, CENTER); text("FATAL ERROR: SYSTEM FORMATTED", width/2, height/2 - 30); fill(255); textSize(16); text("Admin privileges revoked.", width/2, height/2 + 20); }
void drawTerminal() { fill(50, 50, 60, 200); rect(10, 10, width-20, height-20, 10); fill(0, 255, 255); textSize(14); textAlign(LEFT, TOP); text(terminalHeader, 20, 20); fill(#39FF14); textSize(14); text("root@firewall:~# " + currentHint, 20, 70); fill(255); textSize(16); text("root@firewall:~# " + inputText + (millis() % 1000 < 500 ? "_" : ""), 20, 350); fill(255, 150); textAlign(CENTER, BOTTOM); text("Press [TAB] to return to combat", width/2, height - 30); }

void drawCombat() {
  if (freezeFrames > 0) { freezeFrames--; return; }
  if (p1.iFrameTimer > 0) p1.iFrameTimer--; // KURANGIN TIMER KEBAL
  
  if (p1.hp <= 0) gameState = 3; 
  if (b1.hp <= 0 && gameState == 1) { 
    for (int i = 0; i < 150; i++) { particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(255, 120, 0))); particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(255, 255, 255))); }
    shake = 40; deathTimer = millis(); gameState = 6; return;
  }
  
  b1.update(p1); 
  if (b1.wantsToShoot) { enemyBullets.add(new EnemyBullet(b1.col, b1.row, cellSize)); b1.wantsToShoot = false; }
  
  stroke(#39FF14); strokeWeight(2);
  for (int i = 0; i < cols; i++) { for (int j = 0; j < rows; j++) { noFill(); rect(i * cellSize, j * cellSize, cellSize, cellSize); fill(50, 200, 50, 100); textSize(16); text("[" + i + "][" + j + "]", i*cellSize + cellSize/2, j*cellSize + cellSize/2 - 30); } }
  
  b1.display(cellSize); p1.display(cellSize); p1.displayUI(); 
  
  // RENDER BAR PLASMA CHARGE
  if (isCharging) {
    chargeTime++; fill(0, 255, 255); rect(p1.currentX + 10, p1.currentY - 10, map(min(chargeTime, 60), 0, 60, 0, cellSize - 20), 5);
    if (chargeTime >= 60) { fill(255); rect(p1.currentX + 10, p1.currentY - 10, cellSize - 20, 5); } // Tanda penuh
  }
  
  fill(0, 255, 255); textSize(14); textAlign(RIGHT, BOTTOM); text("WEAPON: " + currentWeapon + " | PRESS [Q] FOR TERMINAL", width - 15, height - 10);
  fill(255); textSize(16); textAlign(CENTER, TOP); if (isGodMode) text("SECURITY: ROOT (INVINCIBLE)", width/2, 15); else text("SECURITY LEVEL: " + level, width/2, 15);
  
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i); b.update(b1, autoAimUnlocked); b.display();
    if (b.checkHit(b1, cellSize)) { b1.hp -= b.type.equals("PLASMA") ? 10 : 2; if (!b.type.equals("PLASMA")) bullets.remove(i); shake = 5; } else if (!b.active) bullets.remove(i); 
  }
  
  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    EnemyBullet eb = enemyBullets.get(i); eb.update(p1, b1, cellSize); eb.display();
    if (eb.checkHitPlayer(p1, cellSize)) {
      if (p1.isParrying) { 
        eb.isMalware = false; shake = 25; parryFlashTimer = 5; freezeFrames = 3; p1.iFrameTimer = 60; // 1s KEBAL!
        if (!hasParriedOnce) { hasParriedOnce = true; clueDash = true; currentHint = ">> DATA FRAGMENT EXTRACTED FROM PARRY.\n>> Type 'help;' to inspect."; }
      } else if (p1.iFrameTimer == 0) {
        if (millis() - lastHitTime > 1000) { if (!isGodMode) p1.hp--; lastHitTime = millis(); shake = 20; currentHint = ">> BREACH DETECTED!"; }
        background(255, 0, 0, 100); enemyBullets.remove(i); 
      }
    } else if (eb.checkHitBoss(b1, cellSize)) { b1.hp -= 15; enemyBullets.remove(i); shake = 30; } else if (!eb.active) enemyBullets.remove(i);
  }
  
  // HIT BOX LANTAI MERAH VS BIRU
  if (b1.checkHit(p1)) {
    if (b1.isParryable && p1.isParrying) {
      b1.hp -= 20; shake = 30; parryFlashTimer = 5; freezeFrames = 3; p1.iFrameTimer = 60; b1.isAttacking = false;
      currentHint = ">> DPI SUCCESS: TILE ATTACK REFLECTED!";
    } else if (p1.iFrameTimer == 0 && millis() - lastHitTime > 1000) { 
      if (!isGodMode) p1.hp -= 2; lastHitTime = millis(); background(255, 0, 0, 100); shake = 25; 
      currentHint = ">> BREACH DETECTED: UNPARRYABLE TILE!";
    }
  }
  if (parryFlashTimer > 0) { filter(INVERT); parryFlashTimer--; }
}

void drawBossDeath() { stroke(#39FF14); strokeWeight(2); for (int i = 0; i < cols; i++) { for (int j = 0; j < rows; j++) { noFill(); rect(i * cellSize, j * cellSize, cellSize, cellSize); } } p1.display(cellSize); for (int i = particles.size() - 1; i >= 0; i--) { Particle p = particles.get(i); p.update(); p.display(); if (p.life <= 0) particles.remove(i); } if (millis() - deathTimer > 2000) gameState = 4; }
void resetGame() { p1 = new Player(0, 0, cellSize); b1 = new Boss(level); bullets.clear(); enemyBullets.clear(); particles.clear(); inputText = ""; lastHitTime = millis(); }

void keyPressed() {
  if (gameState == 5) { if (keyCode == BACKSPACE) { saveFile.setBoolean("system_corrupted", false); saveJSONObject(saveFile, "data/save.json"); gameState = 0; } return; }
  if (gameState == 7) { if (keyCode == BACKSPACE) gameState = 0; else if (keyCode == ENTER) { if (loreCurrentIndex >= loreFullText.length()) gameState = 0; else loreCurrentIndex = loreFullText.length(); } }
  else if (gameState == 0 && keyCode == ENTER) { gameState = 1; } 
  else if (gameState == 1) {
    boolean isDashing = (dashUnlocked && keyCode == SHIFT); p1.move(keyCode, key, cols, rows, isDashing); 
    
    // GANTI SENJATA PAKAI ANGKA
    if (key == '1') { currentWeapon = 1; currentHint = ">> PAYLOAD 1: PING RIFLE LOADED."; }
    if (key == '2' && spreadUnlocked) { currentWeapon = 2; currentHint = ">> PAYLOAD 2: BROADCAST SPREAD LOADED."; }
    if (key == '3' && plasmaUnlocked) { currentWeapon = 3; currentHint = ">> PAYLOAD 3: HEAVY PLASMA LOADED. (HOLD SPACE)"; }
    
    // NEMBAK
    if (key == ' ') {
      if (currentWeapon == 3 && plasmaUnlocked) { isCharging = true; } // Tahan Charge
      else {
        bullets.add(new Bullet(p1.col, p1.row, cellSize, "RIFLE"));
        if (currentWeapon == 2) { if (p1.row > 0) bullets.add(new Bullet(p1.col, p1.row - 1, cellSize, "RIFLE")); if (p1.row < rows - 1) bullets.add(new Bullet(p1.col, p1.row + 1, cellSize, "RIFLE")); }
      }
    }
    if (key == 'f' || key == 'F') { if (millis() - p1.lastParryAttempt > 1000) { p1.parryTimer = millis(); p1.lastParryAttempt = millis(); } else shake = 5; }
    if (key == 'q' || key == 'Q') gameState = 2; 
  }
  else if (gameState == 2) { 
    if (keyCode == BACKSPACE && inputText.length() > 0) inputText = inputText.substring(0, inputText.length() - 1);
    else if (keyCode == ENTER) { 
      String cmd = inputText.trim().toLowerCase(); 
      if (cmd.equals("clear;")) { currentHint = ""; } else if (cmd.equals("whoami;")) { currentHint = "root"; } else if (cmd.equals("ls;")) { currentHint = "bin/  boot/  etc/  malware.bin  save.json"; } else if (cmd.equals("pwd;")) { currentHint = "/var/log/firewall"; }
      else if (cmd.equals("netstat;") || cmd.equals("nmap;")) { currentHint = "PORT 666 OPEN (rootkit.exe)"; }
      
      else if (cmd.equals("help;")) { 
        String h = "AVAILABLE COMMANDS (Use ';' at the end):\n- SYS: clear;, ls;, pwd;, whoami;\n- NET: nmap;, netstat;\n- UFW: ufw status;, ufw disable;\n- SWAP: Press 1, 2, 3 in combat"; 
        if (clueDash || clueSpread || clueAim || cluePlasma) h += "\n\n>> UNCOVERED MODULES (Extract via 'ufw allow [PORT];'):";
        if (clueDash) h += "\n- Evade Module detected on PORT 22";
        if (clueSpread) h += "\n- Array Multi-fire detected on PORT 443";
        if (clueAim) h += "\n- Lock-on Homing detected on PORT 80";
        if (cluePlasma) h += "\n- Heavy Plasma Charge detected on PORT 21";
        currentHint = h;
      }
      else if (cmd.equals("ufw status;")) {
        String stat = "Status: active\nTo           Action      From\n";
        if (dashUnlocked) stat += "22/tcp       ALLOW       Anywhere (Evade)\n";
        if (autoAimUnlocked) stat += "80/tcp       ALLOW       Anywhere (Aim)\n";
        if (spreadUnlocked) stat += "443/tcp      ALLOW       Anywhere (Spread)\n";
        if (plasmaUnlocked) stat += "21/tcp       ALLOW       Anywhere (Plasma)\n";
        currentHint = stat;
      }
      else if (cmd.equals("ufw allow dash;") || cmd.equals("ufw allow 22;")) { dashUnlocked = true; currentHint = ">> PORT 22 OPENED: [SHIFT] to dash enabled."; } 
      else if (cmd.equals("ufw allow autoaim;") || cmd.equals("ufw allow 80;")) { autoAimUnlocked = true; currentHint = ">> PORT 80 OPENED: Homing laser enabled."; }
      else if (cmd.equals("ufw allow spread;") || cmd.equals("ufw allow 443;")) { spreadUnlocked = true; currentHint = ">> PORT 443 OPENED: Multi-fire enabled. Press [2] to equip."; }
      else if (cmd.equals("ufw allow plasma;") || cmd.equals("ufw allow 21;")) { plasmaUnlocked = true; currentHint = ">> PORT 21 OPENED: Heavy Plasma enabled. Press [3] to equip."; }
      
      else if (cmd.equals("sudo invincible;")) { isGodMode = true; currentHint = ">> ROOT ACCESS GRANTED. GOD MODE ENABLED."; }
      else if (cmd.equals("hp++;")) { p1.hp += 2; currentHint = ">> INTEGRITY RESTORED (+2 HP)."; }
      else { currentHint = "bash: " + cmd + ": command not found\nType 'help;' for available commands."; }
      inputText = ""; 
    } 
    else if (keyCode == TAB) gameState = 1; else if (key != CODED && keyCode != TAB && keyCode != ENTER) inputText += key;
  }
  else if (gameState == 3 && keyCode == ENTER) { saveFile.setBoolean("system_corrupted", true); saveJSONObject(saveFile, "data/save.json"); gameState = 5; }
  else if (gameState == 4 && keyCode == ENTER) { 
    level++; 
    if (level == 2) { clueSpread = true; currentHint = ">> MALWARE MUTATED (LVL 2).\n>> NEW DATA EXTRACTED. Type 'help;' in terminal."; }
    else if (level == 3) { clueAim = true; cluePlasma = true; currentHint = ">> MALWARE OVERCLOCKED (LVL 3).\n>> NEW DATA EXTRACTED. Type 'help;' in terminal."; }
    else currentHint = ">> MALWARE CRITICAL.\nExpect instant teleports!";
    resetGame(); gameState = 1; 
  }
}

// FUNGSI BARU BUAT NGELEPAS PLASMA CHARGE
void keyReleased() {
  if (gameState == 1 && key == ' ' && currentWeapon == 3 && plasmaUnlocked) {
    if (isCharging) {
      if (chargeTime >= 60) { bullets.add(new Bullet(p1.col, p1.row, cellSize, "PLASMA")); shake = 10; }
      isCharging = false; chargeTime = 0;
    }
  }
}
