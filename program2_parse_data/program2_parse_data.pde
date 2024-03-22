DataTable dt;

void setup() {
  String pathInputCSV = dataPath("artists_20_100.csv");
  dt = new DataTable(pathInputCSV, null);
  //dt.saveToCSV(pathInputCSV.replace(".csv", "_normalised.csv"));
  exit();
}

void draw() {
}
