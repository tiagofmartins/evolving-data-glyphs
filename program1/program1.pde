DataTable dt;

void settings() {
  size(1100, 800);
  smooth(8);
}

void setup() {
  frameRate(60);
  surface.setResizable(true);
  
  dt = new DataTable(dataPath("artists_20.csv"), new int[]{2});
  println(dt.getValue(3, 0));
  println(dt.getValueNorm(3, 0));
}

void draw() {
  background(255);
}
