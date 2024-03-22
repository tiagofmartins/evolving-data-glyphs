import java.util.Collections;

GlyphModel gm;
Float[] randomData;

void settings() {
  size(600, 800);
  smooth(8);
  pixelDensity(displayDensity());
}

void setup() {
  frameRate(30);
  surface.setResizable(true);
  
  gm = new GlyphModel();
  randomData = new Float[gm.getNumAttrs()];
  setGlyphToRandomData(gm.getNumAttrs());
}

void draw() {
  background(255);
  float glyphSize = width * 0.4;
  gm.draw(getGraphics(), width/2 - glyphSize/2, height - glyphSize * 1.25, glyphSize);
  drawGlyphAttrs();
}

void mouseReleased() {
  int graphicalAttrs = int(map(mouseX, 0, width, 0, gm.getNumAttrs()));
  setGlyphToRandomData(graphicalAttrs);
}

void setGlyphToRandomData(int numGraphicalAttrs) {
  ArrayList<Integer> attrsIndexesShuffled = new ArrayList<>();
  for (int i = 0; i < gm.getNumAttrs(); i++) {
    attrsIndexesShuffled.add(i);
  }
  Collections.shuffle(attrsIndexesShuffled);
  
  for (int i = 0; i < gm.getNumAttrs(); i++) {
    if (i <= numGraphicalAttrs) {
      randomData[attrsIndexesShuffled.get(i)] = random(0, 1);
    } else {
      randomData[attrsIndexesShuffled.get(i)] = null;
    }
  }
  
  gm.setAttributes(randomData);
}

void drawGlyphAttrs() {
  textSize(13);
  stroke(220);
  float currY = 30;
  for (int i = -1; i < gm.getNumAttrs(); i++) {
    String[] text = {"", ""};
    if (i == -1) {
      text = new String[]{"GRAPHICAL_ATTR", "VALUE"};
      fill(32);
    } else {
      text[0] = gm.getAttrName(i);
      if (randomData[i] != null) {
        text[1] = nf(randomData[i], 0, 3);
        fill(32);
      } else {
        fill(180);
      }
    }
    text(text[0], 20, currY);
    text(text[1], 160, currY);
    currY += 6;
    line(20, currY, 225, currY);
    currY += 16;
  }
}
