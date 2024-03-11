class TestDataset {

  int numCols;
  int numRows;
  float[][] data;
  float[] minPerCol;
  float[] maxPerCol;
  color[] colours;

  TestDataset(int numCols, int numRows) {
    this.numCols = numCols;
    this.numRows = numRows;
    data = new float[numCols][numRows];
    minPerCol = new float[numCols];
    maxPerCol = new float[numCols];
    colours = new color[numCols];
    for (int col = 0; col < numCols; col++) {
      float xoff = random(1000);
      minPerCol[col] = Float.POSITIVE_INFINITY;
      maxPerCol[col] = Float.NEGATIVE_INFINITY;
      for (int row = 0; row < data[col].length; row++) {
        float value = noise(xoff) * 100;
        data[col][row] = value;
        minPerCol[col] = min(minPerCol[col], value);
        maxPerCol[col] = max(maxPerCol[col], value);
        xoff = xoff + .1;
      }
      colours[col] = color(random(64, 255), random(64, 255), random(64, 255));
    }
  }

  void preview(PGraphics pg, float x, float y, float w, float h) {
    pg.push();
    pg.noFill();
    pg.stroke(200);
    pg.strokeWeight(1);
    pg.rect(x, y, w, h);

    for (int row = 0; row < numRows; row++) {
      float markX = map(row, 0, numRows - 1, x, x + w);
      pg.line(markX, y, markX, y + h);
    }

    pg.blendMode(MULTIPLY);
    pg.strokeWeight(6);
    for (int col = 0; col < numCols; col++) {
      pg.stroke(colours[col]);
      pg.beginShape();
      for (int row = 0; row < numRows; row++) {
        float pointX = map(row, 0, numRows - 1, x, x + w);
        float pointY = map(data[col][row], minPerCol[col], maxPerCol[col], y + h, y);
        pg.vertex(pointX, pointY);
      }
      pg.endShape();
    }
    pg.pop();
  }
  
  Float[] getRowNormalised(int indexRow) {
    Float[] output = new Float[numCols];
    for (int col = 0; col < numCols; col++) {
      output[col] = map(data[col][indexRow], minPerCol[col], maxPerCol[col], 0, 1);
    }
    return output;
  }
}
