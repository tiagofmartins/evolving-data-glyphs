GlyphModel gm = new GlyphModel();
TestDataset td = new TestDataset(3, 30);

void settings() {
  size(1400, 900);
  smooth(8);
}

void setup() {
  frameRate(60);
  surface.setResizable(true);
}

void draw() {
  background(255);
  
  td.preview(getGraphics(), 20, 20, width - 40, 150);
  
  int selectedRow = round(constrain(map(mouseX, 20, width - 20, 0, 1), 0, 1) * (td.numRows - 1));
  float rowW = (width - 40) / float(td.numRows - 1);
  float lineX = 20 + rowW * selectedRow;
  stroke(0);
  line(lineX, 20, lineX, 170);
  
  Float[] selectedValues = td.getRowNormalised(selectedRow);
  textAlign(CENTER, TOP);
  for (int col = 0; col < td.numCols; col++) {
    fill(td.colours[col]);
    text(nf(selectedValues[col], 0, 3), lineX, 180 + col * g.textSize * 1.2);
  }
  
  gm.draw(getGraphics(), mouseX, mouseY, 200, selectedValues);
}

void keyReleased() {
  if (key == 'd') {
    td = new TestDataset(3, 30);
  }
}
