class Individual {

  GlyphModel glyph; // reference to glyph model
  DataTable data; // reference to data table
  Integer[] genes; // array with integers that encode indexes of data columns
  float fitness; // quality score
  int minRelations; // minimum number of relations between data columns and glyph attributes
  int maxRelations; // maximum number of relations between data columns and glyph attributes
  float rateCreateRelation; // probability to configure a gene to create a relation

  Individual(int minRelations, int maxRelations, float rateCreateRelation, GlyphModel glyph, DataTable data) {
    this.minRelations = minRelations;
    this.maxRelations = maxRelations;
    this.rateCreateRelation = rateCreateRelation;
    this.glyph = glyph;
    this.data = data;

    // Create array to store genes.
    // This code version assumes that one graphical attribute
    // of the glyph can only be influenced by one data column or none.
    // This way, we have one gene for each graphic attribute of the glyph
    // and the gene value represents the index of a data column.
    // If the gene value is null, no data column influences the graphical attribute.
    genes = new Integer[glyph.getNumAttrs()];
  }

  /**
   * Returns a clean copy of the individual.
   */
  Individual getCopy() {
    Individual copy = new Individual(minRelations, maxRelations, rateCreateRelation, glyph, data);
    System.arraycopy(genes, 0, copy.genes, 0, genes.length);
    copy.fitness = fitness;
    return copy;
  }

  /**
   * Sets all genes to random values.
   */
  void randomise() {
    // Repeat until a new valid individual is generated
    while (true) {

      // Create genes with random values
      for (int i = 0; i < genes.length; i++) {
        if (random(1) < rateCreateRelation) {
          genes[i] = int(random(0, data.getNumColumns()));
        } else {
          genes[i] = null;
        }
      }

      // Check if individual is valid
      if (isValid()) {
        break;
      }
    }
    fitness = 0;
  }

  /**
   * Modifies values of genes with a given rate.
   * The mutation rate is per gene.
   */
  void mutate(float ratePerGene) {
    // Repeat until a new valid mutated version is generated
    while (true) {

      // Create clean copy of the individual
      Individual mutatedVersion = getCopy();

      // Apply mutation to genes
      for (int i = 0; i < mutatedVersion.genes.length; i++) {
        if (random(1) < ratePerGene) {
          if (random(1) < rateCreateRelation) {
            mutatedVersion.genes[i] = int(random(0, data.getNumColumns()));
          } else {
            mutatedVersion.genes[i] = null;
          }
        }
      }

      // Check if mutated version is valid
      if (mutatedVersion.isValid()) {
        System.arraycopy(mutatedVersion.genes, 0, genes, 0, mutatedVersion.genes.length);
        break;
      }
    }
  }

  /**
   * Return two new individuals (offspring) by recombining the genes
   * of this individual with the genes of another given individual
   * using a uniform crossover operation.
   */
  Individual[] recombineWith(Individual other) {
    // Repeat until two new valid individuals are generated
    while (true) {

      // Create clean copies of both parents
      Individual child1 = getCopy();
      Individual child2 = other.getCopy();

      // Recombine groups of genes
      for (int i = 0; i < child1.genes.length; i++) {
        if (random(1) < 0.5) {
          Integer geneTemp = child1.genes[i];
          child1.genes[i] = child2.genes[i];
          child2.genes[i] = geneTemp;
        }
      }

      // Check if new individuals are valid
      if (!child1.isValid() || !child2.isValid()) {
        continue;
      }

      // Return new individuals
      return new Individual[]{child1, child2};
    }
  }

  /**
   * Returns true if the individual is valid.
   */
  boolean isValid() {
    int numRelations = 0;
    for (int i = 0; i < genes.length; i++) {
      if (genes[i] != null) {
        numRelations++;
      }
    }
    if (numRelations < minRelations || numRelations > maxRelations) {
      return false;
    }
    return true;
  }

  /**
   * Sets fitness value.
   */
  void setFitness(float fitness) {
    this.fitness = fitness;
  }

  /**
   * Returns fitness value.
   */
  float getFitness() {
    return fitness;
  }

  /**
   * Returns normalised values to be used as graphical attributes of the glyph.
   */
  Float[] getValuesForGlyphAttrs(int row) {
    Float[] output = new Float[genes.length];
    for (int i = 0; i < genes.length; i++) {
      if (genes[i] != null) {
        output[i] = data.dataRowsNormalised.get(row)[genes[i]];
      } else {
        output[i] = null;
      }
    }
    return output;
  }

  /**
   * Returns JSON object with the data of the individual.
   */
  JSONObject getJSON() {
    JSONObject json = new JSONObject();
    JSONArray jsonGenes = new JSONArray();
    for (int i = 0; i < genes.length; i++) {
      JSONObject jsonGene = new JSONObject();
      jsonGene.setString("glyph_attr", glyph.attrsNames[i]);
      jsonGene.setInt("column_index", genes[i] != null ? genes[i] : -1);
      jsonGene.setString("column_name", genes[i] != null ? data.columsNames[genes[i]] : "");
      jsonGenes.append(jsonGene);
    }
    json.setJSONArray("genes", jsonGenes);
    json.setFloat("fitness", fitness);
    return json;
  }

  /**
   * Returns array with strings describing the relations.
   */
  ArrayList<String> getRelationsInfo(Integer exampleRowIndex) {
    ArrayList<String> relations = new ArrayList<String>();
    for (int i = 0; i < genes.length; i++) {
      if (genes[i] != null) {
        String relationText = glyph.attrsNames[i] + "  ←  " + data.columsNames[genes[i]];
        if (exampleRowIndex != null) {
          relationText += " [" + data.getValue(exampleRowIndex, genes[i]) + "]";
        }
        relations.add(relationText);
      }
    }
    return relations;
  }
}
