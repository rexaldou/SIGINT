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

// VFS TERMINAL (Draft Awal)
String inputText = "";
String terminalHeader = "root@sigint:~# ";
String currentDir = "~";
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
    case 2: drawTerminal(); break; 
    case 3: drawGameOver(); break; 
  }
  
  popMatrix(); 
  drawCRT(); 
  drawGlitch(); 
}

// ==========================================
// ACT 1: THE IN MEDIA RES BOOT SEQUENCE
// ==========================================
void drawBootSequence() {
  bootTimer++;
  fill(#39FF14); textSize(16); textAlign(LEFT, TOP);
  
  String bootText = "";
  if (bootTimer > 10) bootText += ">> BOOT SEQUENCE INITIATED...\n";
  if (bootTimer > 60) bootText += ">> LOADING KERNEL MODULES [OK]\n";
  if (bootTimer > 110) bootText += ">> HEURISTIC AI 'SIGINT' ONLINE.\n";
  if (bootTimer > 180) bootText += ">> WARNING: POLYMORPHIC ANOMALY DETECTED IN SECTOR 7.\n";
  
  text(bootText, 40, 60);
  
  if (bootTimer > 280) {
    gameState = 1; 
    waveTimer = 0; 
    isBossActive = false; 
  }
}

// ==========================================
// ACT 1: THE DYNAMIC STATUS UI & GRID
// ==========================================
void drawCombat() {
  if (freezeFrames > 0) { freezeFrames--; return; }
  if (p1.iFrameTimer > 0) p1.iFrameTimer--; 
  if (p1.hp <= 0) gameState = 3; 
  
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
    if (waveTimer < 200) {
      fill(0, 255, 0); text("[ SYSTEM STATUS : OPTIMAL ]", width/2, 15);
      if (waveTimer == 100) currentHint = ">> NEW DATA INTERCEPTED. PRESS [Q] TO ANALYZE.";
    } else if (waveTimer < 400) {
      fill(255, 255, 0); text("[ SYSTEM STATUS : ANOMALY DETECTED ]", width/2, 15);
    } else if (waveTimer < 550) {
      if (frameCount % 10 < 5) fill(255, 150, 0); else fill(255, 0, 0);
      text("[ SYSTEM STATUS : BREACH IMMINENT ]", width/2, 15);
    } else {
      b1 = new Boss(level); 
      isBossActive = true; 
      shake = 20; 
      currentHint = ">> INTRUSION ACTIVE. ELIMINATE THE THREAT.";
    }
  } else {
    if (frameCount % 20 < 10) fill(255, 0, 0); else fill(150, 0, 0);
    text("[ THREAT LEVEL : CRITICAL ]", width/2, 15);
    
    b1.update(p1); 
    b1.display(cellSize);
    
    if (b1.wantsToShoot) { enemyBullets.add(new EnemyBullet(b1.col, b1.row, cellSize)); b1.wantsToShoot = false; }
    
    if (b1.hp <= 0) {
      for (int i = 0; i < 150; i++) particles.add(new Particle(b1.col * cellSize + cellSize/2, b1.row * cellSize + cellSize/2, color(255, 120, 0)));
      shake = 30; 
      isBossActive = false; 
      waveTimer = 0; 
      level++;
      saveGameState();
      bullets.clear(); enemyBullets.clear();
    }
  }
  
  p1.display(cellSize); p1.displayUI(); 
  
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i); 
    if (isBossActive) b.update(b1, autoAimUnlocked); 
    b.display();
    if (isBossActive && b.checkHit(b1, cellSize)) { b1.hp -= b.type.equals("PLASMA") ? 10 : playerDamage; bullets.remove(i); shake = 5; } 
    else if (!b.active) bullets.remove(i); 
  }
  
  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    EnemyBullet eb = enemyBullets.get(i); eb.update(p1, b1, cellSize); eb.display();
  }
  
  fill(0, 255, 255); textSize(12); textAlign(CENTER, BOTTOM); 
  text(currentHint, width/2, height - 10);
  
  if (parryFlashTimer > 0) { filter(INVERT); parryFlashTimer--; }
}

// ==========================================
// ACT 2 & 3: VFS TERMINAL & NANO EDITOR
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
    
    float startY = 70;
    for (String line : terminalHistory) {
      fill(#39FF14); if (line.startsWith("root@")) fill(0, 255, 255); else if (line.startsWith("ERROR") || line.contains("Denied")) fill(255, 50, 50);
      text(line, 20, startY);
      startY += 20 * (line.split("\n").length); 
    }
    
    fill(255); 
    text("root@sigint:" + currentDir + "# " + inputText + (millis() % 1000 < 500 ? "_" : ""), 20, height - 50); 
    fill(150); textAlign(CENTER, BOTTOM); text("Press [TAB] to return to Grid (Timer is paused)", width/2, height - 10); 
  }
}

// ==========================================
// INPUT CONTROLLER (MERGED keyPressed)
// ==========================================
void keyPressed() {
  if (gameState == 1) {
    if (key == 'q' || key == 'Q') gameState = 2; 
    p1.move(keyCode, key, cols, rows, dashUnlocked); 
    if (key == ' ' && isBossActive) bullets.add(new Bullet(p1.col, p1.row, cellSize, "RIFLE", b1));
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

// ==========================================
// ACT 2, 3, & 4: LOGIKA TERMINAL & HACKING
// ==========================================
void processCommand(String input) {
  String cmd = input.trim().toLowerCase();
  terminalHistory.add("root@sigint:" + currentDir + "# " + input); 
  
  if (cmd.equals("clear")) { terminalHistory.clear(); }
  else if (cmd.equals("pwd")) { terminalHistory.add("/var/sigint_jail/root" + currentDir.substring(1)); }
  else if (cmd.equals("ls")) {
    if (currentDir.equals("~")) terminalHistory.add("logs/    src/    tools/    Skripsi_Final.docx");
    else if (currentDir.equals("~/logs")) {
      if (log2Unlocked) terminalHistory.add("intercept_01.log    intercept_02.log");
      else terminalHistory.add("intercept_01.log    intercept_02_encrypted.log");
    }
    else if (currentDir.equals("~/src")) terminalHistory.add("core_logic.py    weapon_config.py");
    else if (currentDir.equals("~/tools")) terminalHistory.add("decryptor.py");
  }
  else if (cmd.startsWith("cd ")) {
    String target = cmd.substring(3).trim();
    if (target.equals("..") || target.equals("/")) {
      if (currentDir.equals("~")) terminalHistory.add("bash: cd: " + target + ": Permission Denied (Sandbox Restricted)");
      else currentDir = "~";
    }
    else if (currentDir.equals("~") && (target.equals("logs") || target.equals("src") || target.equals("tools"))) {
      currentDir = "~/" + target;
    }
    else { terminalHistory.add("bash: cd: " + target + ": No such file or directory"); }
  }
  else if (cmd.startsWith("cat ")) {
    String file = cmd.substring(4).trim();
    if (file.equals("skripsi_final.docx")) terminalHistory.add("ERROR: File corrupted. Data shredded by user.");
    else if (file.equals("intercept_01.log") && currentDir.equals("~/logs")) {
       terminalHistory.add("[SOURCE IP: 192.168.x.x]\nSistem, ini pesan terakhir gw. Jangan biarkan\nkoneksi masuk sampai The_Truth.zip ter-upload.");
    }
    else if (file.equals("intercept_02.log") && currentDir.equals("~/logs")) {
       if (log2Unlocked) terminalHistory.add("[C2 TELEMETRY - DECRYPTED]\nHunter-Killer AI: Target menggunakan UI Shooter.\nRekomendasi adaptasi: Tingkatkan armor pada wave 2.");
       else terminalHistory.add("cat: intercept_02.log: No such file or directory (Did you mean intercept_02_encrypted.log?)");
    }
    else if (file.equals("intercept_02_encrypted.log")) {
       terminalHistory.add("ERROR: File is locked by AES-256. Use decryptor.py to unlock.");
    }
    else terminalHistory.add("cat: " + file + ": No such file or directory");
  }
  else if (cmd.startsWith("nano ")) {
    String file = cmd.substring(5).trim();
    if (file.equals("weapon_config.py") && currentDir.equals("~/src")) {
      isNanoMode = true; currentFile = file;
      nanoBuffer = "# SIGINT WEAPON CONFIG\n# Edit variables below:\n\nrifle_speed = " + rifleSpeed + "\ndamage = " + playerDamage;
    } else if (file.equals("decryptor.py") && currentDir.equals("~/tools")) {
      isNanoMode = true; currentFile = file;
      nanoBuffer = decryptorBuffer; 
    } else {
      terminalHistory.add("nano: " + file + ": Permission denied or file not found");
    }
  }
  else if (cmd.startsWith("run ")) {
    String target = cmd.substring(4).trim();
    if (target.equals("decryptor.py") && currentDir.equals("~/tools")) {
      terminalHistory.add("Usage: run decryptor.py [target_file]");
    }
    else if (target.startsWith("decryptor.py ")) {
      String fileTarget = target.substring(13).trim();
      if (!currentDir.equals("~/tools")) {
        terminalHistory.add("bash: run: execute this command from ~/tools directory");
      } else {
        int parsedKey = parseDecryptorKey(decryptorBuffer);
        if (fileTarget.equals("intercept_02_encrypted.log") || fileTarget.equals("~/logs/intercept_02_encrypted.log")) {
          if (parsedKey == boss1Key) {
            log2Unlocked = true;
            saveGameState();
            terminalHistory.add(">> DECRYPTION SUCCESSFUL! File unlocked as 'intercept_02.log'.");
          } else {
            terminalHistory.add(">> DECRYPTION FAILED. Invalid key offset: " + parsedKey);
          }
        } else {
          terminalHistory.add(">> Target file not found or not encrypted.");
        }
      }
    } else {
      terminalHistory.add("bash: run: command not found");
    }
  }
  else if (cmd.length() > 0) { terminalHistory.add("bash: " + cmd + ": command not found"); }
  
  while(terminalHistory.size() > 14) { terminalHistory.remove(0); }
}

void drawGameOver() { fill(255, 0, 0); textSize(40); textAlign(CENTER, CENTER); text("KERNEL PANIC\nIntegrity Compromised.", width/2, height/2); }
void drawCRT() { stroke(0, 50); strokeWeight(2); for(int i = 0; i < height; i += 4) line(0, i, width, i); }
void drawGlitch() { if (shake > 0) { noStroke(); for (int i = 0; i < 5; i++) { float y = random(height), h = random(5, 30), x = random(-40, 40); fill(255, 0, 50, 150); rect(x, y, width, h); } } }

// ==========================================
// ACT 3 & 4: TEXT PARSERS (THE HACKING ENGINE)
// ==========================================
void parseWeaponConfig(String code) {
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
