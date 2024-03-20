class Individual {

  DataTable data; // reference to data table
  GlyphModel glyph; // reference to glyph model
  float[] genes; // arraw with floats [0,1]
  float fitness; // quality score

  Individual(DataTable data, GlyphModel glyph) {
    this.data = data;
    this.glyph = glyph;

    // Create array to store the genes.
    // This code version assumes that one graphical attribute
    // of the glyph can only be influenced by one data column or none.
    genes = new float[glyph.getNumAttrs()];
  }

  Individual getCopy() {
    return null;
  }

  void randomise() {
  }

  void mutate() {
  }

  Individual[] recombineWith(Individual other) {
    return null;
  }

  void setFitness(float fitness) {
    this.fitness = fitness;
  }

  float getFitness() {
    return fitness;
  }
}
