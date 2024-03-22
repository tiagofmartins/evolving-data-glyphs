import java.util.Collections;

GlyphModel gm;
DataTable dt;

Integer[] relations;
int indexDataRow = 0;

void settings() {
  size(600, 800);
  smooth(8);
  pixelDensity(displayDensity());
}

void setup() {
  frameRate(30);
  surface.setResizable(true);

  String pathInputCSV = dataPath("artists_20_100.csv");
  dt = new DataTable(pathInputCSV, null);
  //dt.saveToCSV(pathInputCSV.replace(".csv", "_normalised.csv"));

  gm = new GlyphModel();
  relations = new Integer[gm.getNumAttrs()];
  setGlyphToDataRow(gm.getNumAttrs(), indexDataRow);
}

void draw() {
  background(255);
  float glyphSize = width * 0.4;
  gm.draw(getGraphics(), width/2 - glyphSize/2, height - glyphSize * 1.25, glyphSize);
  drawGlyphAttrs();
}

void mouseReleased() {
  int graphicalAttrs = int(map(mouseX, 0, width, 0, gm.getNumAttrs()));
  indexDataRow = int(random(0, dt.getNumRows()));
  setGlyphToDataRow(graphicalAttrs, indexDataRow);
}

void setGlyphToDataRow(int numGraphicalAttrs, int indexDataRow) {
  ArrayList<Integer> attrsIndexesShuffled = new ArrayList<>();
  for (int i = 0; i < gm.getNumAttrs(); i++) {
    attrsIndexesShuffled.add(i);
  }
  Collections.shuffle(attrsIndexesShuffled);

  for (int i = 0; i < gm.getNumAttrs(); i++) {
    if (i <= numGraphicalAttrs) {
      relations[attrsIndexesShuffled.get(i)] = int(random(0, dt.getNumColumns()));
    } else {
      relations[attrsIndexesShuffled.get(i)] = null;
    }
  }

  Float[] inputData = new Float[gm.getNumAttrs()];
  for (int i = 0; i < gm.getNumAttrs(); i++) {
    if (relations[i] != null) {
      inputData[i] = dt.getValueNorm(indexDataRow, relations[i]);
    } else {
      inputData[i] = null;
    }
  }
  
  gm.setAttributes(inputData);
}

void drawGlyphAttrs() {
  textSize(13);
  stroke(220);
  float currY = 30;
  for (int i = -1; i < gm.getNumAttrs(); i++) {
    String[] text = {"", "", "", ""};
    if (i == -1) {
      text = new String[]{"GRAPHICAL_ATTR", "DATA_COL", "VALUE", "VALUE_NORM"};
      fill(32);
    } else {
      text[0] = gm.getAttrName(i);
      if (relations[i] != null) {
        text[1] = dt.getColumnName(relations[i]);
        text[2] = dt.getValue(indexDataRow, relations[i]);
        text[3] = nf(dt.getValueNorm(indexDataRow, relations[i]), 0, 3);
        fill(32);
      } else {
        fill(180);
      }
    }
    text(text[0], 20, currY);
    text(text[1], 160, currY);
    text(text[2], 375, currY);
    text(text[3], 500, currY);
    currY += 6;
    line(20, currY, width - 20, currY);
    currY += 16;
  }
}
