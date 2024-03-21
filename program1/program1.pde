GlyphModel gm;
DataTable dt;
Population pop;

void settings() {
  size(1100, 800);
  smooth(8);
}

void setup() {
  frameRate(60);
  surface.setResizable(true);

  String pathInputCSV = dataPath("artists_20.csv");
  dt = new DataTable(pathInputCSV, null);
  //dt.saveToCSV(pathInputCSV.replace(".csv", "_normalised.csv"));

  gm = new GlyphModel();

  pop = new Population(
    10, 1, 2, 0.3, 0.1, // genetic parameters
    2, 8, 0.2, // relations parameters
    gm, dt); // glyph and data objects
}

void draw() {
  updateLayout();
  
  background(255);
  noFill();
  stroke(200);
  strokeWeight(1);
  for (int i = 0; i < pop.getSize(); i++) {
    float cellX = cellSize * i;
    for (int g = 0; g < numGlyphs; g++) {
      float cellY = cellSize * g;
      rect(cellX, cellY, cellSize, cellSize);
      gm.setAttributes(pop.getIndividual(i).getValuesForGlyphAttrs(selectedDataRows.get(g)));
      gm.draw(getGraphics(), cellX + glyphMargin, cellY + glyphMargin, glyphSize);
    }
  }
}

void mouseReleased() {
  pop.init();
}

ArrayList<Integer> selectedDataRows = new ArrayList<Integer>();
int numGlyphs;
float cellSize;
float glyphSize;
float glyphMargin;
int prevWidth;
int prevHeight;

void updateLayout() {
  if (width == prevWidth && height == prevHeight) {
    return;
  }
  prevWidth = width;
  prevHeight = height;

  cellSize = width / (float) pop.getSize();
  glyphSize = cellSize * 0.7;
  glyphMargin = (cellSize - glyphSize) / 2f;

  numGlyphs = max(floor(height / cellSize), 1);
  numGlyphs = min(numGlyphs, dt.getNumRows());
  while (selectedDataRows.size() < numGlyphs) {
    selectedDataRows.add(int(random(0, dt.getNumRows())));
  }
}
