class Particle {
  float x, y, vx, vy;
  float life, maxLife;
  color c;

  Particle(float startX, float startY, color pColor) {
    x = startX; 
    y = startY;
    // Ledakan mekar ke segala arah dengan kecepatan acak!
    vx = random(-15, 15); 
    vy = random(-15, 15);
    maxLife = random(30, 80); // Umur partikel (dalam frame)
    life = maxLife;
    c = pColor;
  }

  void update() {
    x += vx; 
    y += vy;
    // Gesekan virtual (Friction) biar partikelnya melambat di akhir
    vx *= 0.9; 
    vy *= 0.9; 
    life--;
  }

  void display() {
    noStroke();
    // Warnanya makin pudar seiring waktu (opacity berkurang)
    fill(c, map(life, 0, maxLife, 0, 255));
    // Bentuk partikelnya kotak kecil ala serpihan data
    rect(x, y, random(3, 8), random(3, 8));
  }
}
