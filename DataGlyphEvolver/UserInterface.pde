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
          PImage relationsFigure = getRelationsOverview(pop.getIndividual(i), selectedDataRows.get(g));
          Area relationsFigureArea = new Area(mouseX, mouseY, relationsFigure.width, relationsFigure.height);
          if (relationsFigureArea.getRight() > width) {
            relationsFigureArea.x = mouseX - relationsFigureArea.w;
          }
          if (relationsFigureArea.getBottom() > height) {
            relationsFigureArea.y = mouseY - relationsFigureArea.h;
          }
          image(relationsFigure, relationsFigureArea.x, relationsFigureArea.y);
          noFill();
          strokeWeight(1);
          stroke(200);
          rect(relationsFigureArea.x, relationsFigureArea.y, relationsFigureArea.w, relationsFigureArea.h);
          
          break myNestedLoop;
        }
      }
    }
  }
}


PImage getRelationsOverview(Individual indiv, Integer indexExampleDataRow) {
  float margin = 10;
  float textSize = 13;
  float textLeading = 15;
  float linesSpaceW = 40;
  float spaceBelowValue = textLeading * 0.4;
  float spacePoint = 8;

  pushStyle();
  textSize(textSize);
  
  ArrayList<PVector> anchorsLeft = new ArrayList<PVector>();
  ArrayList<PVector> anchorsRight = new ArrayList<PVector>();
  ArrayList<String> dataNames = new ArrayList<String>();
  ArrayList<String> dataValues = new ArrayList<String>();
  ArrayList<String> glyphAttrs = new ArrayList<String>();
  for (int i = 0; i < indiv.genes.length; i++) {
    Integer gene = indiv.genes[i];
    if (gene != null) {
      if (!dataNames.contains(indiv.data.columsNames[gene])) {
        dataNames.add(indiv.data.columsNames[gene]);
        dataValues.add(indiv.data.getValue(indexExampleDataRow, gene));
      }
      glyphAttrs.add(indiv.glyph.attrsNames[i]);
    }
  }

  float colLeftW = 0;
  for (int i = 0; i < dataNames.size(); i++) {
    colLeftW = max(colLeftW, textWidth(dataNames.get(i)), textWidth(dataValues.get(i)));
  }
  float colRightW = 0;
  for (int i = 0; i < glyphAttrs.size(); i++) {
    colRightW = max(colRightW, textWidth(glyphAttrs.get(i)));
  }

  for (int i = 0; i < dataNames.size(); i++) {
    anchorsLeft.add(new PVector(margin + colLeftW + spacePoint, margin + textLeading * 0.5 + (i + 0.2) * (textLeading * 2 + spaceBelowValue)));
  }
  for (int i = 0; i < glyphAttrs.size(); i++) {
    anchorsRight.add(new PVector(margin + colLeftW + linesSpaceW, margin + textLeading * 0.5 + i * (textLeading + spaceBelowValue)));
  }

  int imageW = round(anchorsRight.get(0).x + spacePoint + colRightW + margin);
  int imageH = round(max(anchorsLeft.get(anchorsLeft.size() - 1).y, anchorsRight.get(anchorsRight.size() - 1).y) + textLeading + margin);
  PGraphics pg = createGraphics(imageW, imageH);
  pg.beginDraw();
  pg.background(255);

  pg.textAlign(RIGHT, CENTER);
  for (int i = 0; i < dataNames.size(); i++) {
    pg.fill(128);
    pg.text(dataNames.get(i), anchorsLeft.get(i).x - spacePoint, anchorsLeft.get(i).y - textLeading * 0.5);
    pg.fill(32);
    pg.text(dataValues.get(i), anchorsLeft.get(i).x - spacePoint, anchorsLeft.get(i).y + textLeading * 0.5);
  }
  pg.textAlign(LEFT, CENTER);
  for (int i = 0; i < glyphAttrs.size(); i++) {
    pg.fill(32);
    pg.text(glyphAttrs.get(i), anchorsRight.get(i).x + spacePoint, anchorsRight.get(i).y);
  }

  pg.stroke(64);
  pg.strokeWeight(4);
  for (PVector p : anchorsLeft) {
    pg.point(p.x, p.y);
  }
  for (PVector p : anchorsRight) {
    pg.point(p.x, p.y);
  }

  pg.strokeWeight(1.5);
  for (int i = 0; i < indiv.genes.length; i++) {
    Integer gene = indiv.genes[i];
    if (gene != null) {
      PVector p1 = anchorsRight.get(glyphAttrs.indexOf(indiv.glyph.attrsNames[i]));
      PVector p2 = anchorsLeft.get(dataNames.indexOf(indiv.data.columsNames[gene]));
      pg.line(p1.x, p1.y, p2.x, p2.y);
    }
  }

  pg.endDraw();
  popStyle();

  return pg;
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
