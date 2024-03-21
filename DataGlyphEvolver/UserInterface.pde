boolean showInfo = true;
int spaceAround = 20;
int spaceBelow = 45;
int spaceColumns = 15;

int numGlyphs;
float cellSize;
float glyphSize;
float glyphMargin;
int prevWidth;
int prevHeight;
Area[] areasIndivs = null;
Area[][] areasGlyphs = null;


void calculateInterfaceLayout() {
  if (width == prevWidth && height == prevHeight) {
    return;
  }
  prevWidth = width;
  prevHeight = height;

  cellSize = (width - spaceAround * 2 - spaceColumns * (pop.getSize() - 1)) / (float) pop.getSize();
  glyphSize = cellSize * 0.7;
  glyphMargin = (cellSize - glyphSize) / 2f;

  numGlyphs = max(floor((height - (spaceAround + spaceBelow)) / cellSize), 1);
  numGlyphs = min(numGlyphs, dt.getNumRows());
  while (selectedDataRows.size() < numGlyphs) {
    selectedDataRows.add(int(random(0, dt.getNumRows())));
  }

  areasIndivs = new Area[pop.getSize()];
  areasGlyphs = new Area[pop.getSize()][numGlyphs];
  for (int i = 0; i < pop.getSize(); i++) {
    float colX = spaceAround + (cellSize + spaceColumns) * i;
    float colY = spaceAround;
    float colW = cellSize;
    float colH = cellSize * numGlyphs;
    areasIndivs[i] = new Area(colX, colY, colW, colH);
    for (int g = 0; g < numGlyphs; g++) {
      float cellY = colY + cellSize * g;
      areasGlyphs[i][g] = new Area(colX, cellY, cellSize, cellSize);
    }
  }
}


void drawInterface() {
  // Draw rectangle behind each individual (column)
  noStroke();
  fill(255);
  for (Area a : areasIndivs) {
    rect(a.x, a.y, a.w, a.h);
  }

  // Draw rectangle around each glyph
  noFill();
  stroke(220);
  strokeWeight(1);
  for (int i = 0; i < pop.getSize(); i++) {
    for (Area a : areasGlyphs[i]) {
      rect(a.x, a.y, a.w, a.h);
    }
  }

  // Draw rectangles to highlight certain individuals (mouseover and fitness)
  noFill();
  for (int i = 0; i < pop.getSize(); i++) {
    if (pop.getIndividual(i).getFitness() > 0) {
      strokeWeight(3);
      stroke(0);
    } else if (areasIndivs[i].contains(mouseX, mouseY)) {
      strokeWeight(1);
      stroke(100);
    } else {
      continue;
    }
    rect(areasIndivs[i].x, areasIndivs[i].y, areasIndivs[i].w, areasIndivs[i].h);
  }

  // Draw glyphs
  for (int i = 0; i < pop.getSize(); i++) {
    for (int g = 0; g < numGlyphs; g++) {
      gm.setAttributes(pop.getIndividual(i).getValuesForGlyphAttrs(selectedDataRows.get(g)));
      gm.draw(getGraphics(), areasGlyphs[i][g].x + glyphMargin, areasGlyphs[i][g].y + glyphMargin, glyphSize);
    }
  }

  // Draw text presenting controls
  fill(150);
  textSize(13);
  textAlign(LEFT, BOTTOM);
  text("Controls:     [click over indiv] change fitness     [enter] evolve     [r] reset     [d] change data examples     [i] toggle info", spaceAround, height- spaceAround);

  // Show information about the individual below the cursor
  if (showInfo) {
  myNestedLoop:
    for (int i = 0; i < pop.getSize(); i++) {
      for (int g = 0; g < numGlyphs; g++) {
        if (areasGlyphs[i][g].contains(mouseX, mouseY)) {
          textAlign(LEFT, TOP);
          textSize(13);
          textLeading(getGraphics().textSize * 1.4);

          ArrayList<String> textLines = pop.getIndividual(i).getRelationsInfo(selectedDataRows.get(g));
          String text = "";
          float textW = 0;
          for (String line : textLines) {
            textW = max(textW, textWidth(line));
            text += line + "\n";
          }
          float textH = getGraphics().textLeading * (textLines.size() - 0.333);
          float textMargin = getGraphics().textLeading;

          Area popupArea = new Area(mouseX, mouseY, textW + textMargin * 2, textH + textMargin * 2);
          if (popupArea.getRight() > width) {
            popupArea.x = mouseX - popupArea.w;
          }
          if (popupArea.getBottom() > height) {
            popupArea.y = mouseY - popupArea.h;
          }

          push();
          strokeWeight(1);
          stroke(200);
          fill(255);
          rect(popupArea.x, popupArea.y, popupArea.w, popupArea.h);
          fill(32);
          text(text, popupArea.x + textMargin, popupArea.y + textMargin);
          pop();

          break myNestedLoop;
        }
      }
    }
  }
}


class Area {
  float x;
  float y;
  float w;
  float h;

  Area(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  PVector getCenter() {
    return new PVector(x + w / 2, y + h / 2);
  }

  float getRight() {
    return x + w;
  }

  float getBottom() {
    return y + h;
  }

  boolean contains(float pX, float pY) {
    return pX >= x && pX < getRight() && pY >= y && pY < getBottom();
  }
}
