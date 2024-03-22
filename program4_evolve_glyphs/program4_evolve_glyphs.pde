GlyphModel gm;
DataTable dt;
Population pop;

ArrayList<Integer> selectedDataRows = new ArrayList<Integer>();

void settings() {
  size(1200, 800);
  smooth(8);
  pixelDensity(displayDensity());
}

void setup() {
  frameRate(30);
  surface.setResizable(true);

  gm = new GlyphModel();

  String pathInputCSV = dataPath("artists_20_100.csv");
  dt = new DataTable(
    pathInputCSV, // path to input CSV file
    null // array with indexes of columns to load (null == all columns)
    );
  //dt.saveToCSV(pathInputCSV.replace(".csv", "_normalised.csv"));

  pop = new Population(
    15, // number of individuals in the population
    1, // elite size
    2, // tournament size
    0.5, // probability of recombining individuals
    0.3, // probability of mutating each gene
    3, // minimum number of relations
    8, // maximum number of relations
    0.3, // probability of configuring a gene to create a relation
    gm, dt); // glyph and data objects
}

void draw() {
  background(240);
  calculateInterfaceLayout();
  drawInterface();
}

void mouseReleased() {
  // Change fitness (between 0 and 1) of an individual by clicking on it
  for (int i = 0; i < pop.getSize(); i++) {
    if (areasIndivs[i].contains(mouseX, mouseY)) {
      pop.getIndividual(i).setFitness(pop.getIndividual(i).getFitness() == 0 ? 1 : 0);
      break;
    }
  }
}

void keyReleased() {
  if (keyCode == ENTER || keyCode == RETURN) {
    // Press key [enter] to evolve new generation
    pop.evolve();
  } else if (key == 'r') {
    // Press key [r] to reset evolution
    pop.init();
  } else if (key == 'd') {
    // Press key [d] to randomise the indexes of the data rows used to preview individuals
    selectedDataRows.clear();
    while (selectedDataRows.size() < numGlyphs) {
      selectedDataRows.add(int(random(0, dt.getNumRows())));
    }
  } else if (key == 'i') {
    // Press key [i] to toggle information about individuals
    showInfo = !showInfo;
  }
}
