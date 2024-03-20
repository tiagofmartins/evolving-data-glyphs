DataTable dt;

void settings() {
  size(1100, 800);
  smooth(8);
}

void setup() {
  frameRate(60);
  surface.setResizable(true);
  
  String pathInputCSV = dataPath("artists_20.csv");
  dt = new DataTable(pathInputCSV, new int[]{2});
  dt.saveToCSV(pathInputCSV.replace(".csv", "_normalised.csv"));
}

void draw() {
  background(255);
}
