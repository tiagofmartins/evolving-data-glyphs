import java.util.Comparator;

class Population {

  int popSize;
  int eliteSize;
  int tournamentSize;
  float crossoverRate;
  float mutationRate;

  int minRelations; // minimum number of relations between data columns and glyph attributes
  int maxRelations; // maximum number of relations between data columns and glyph attributes
  float rateCreateRelation; // probability to configure a gene to create a relation

  GlyphModel glyph; // reference to glyph model
  DataTable data; // reference to data table

  Individual[] individuals;
  int generations;

  /**
   * Creates a population of individuals based on the given parameters.
   */
  Population(int popSize, int eliteSize, int tournamentSize, float crossoverRate, float mutationRate, int minRelations, int maxRelations, float rateCreateRelation, GlyphModel glyph, DataTable data) {
    this.popSize = popSize;
    this.eliteSize = eliteSize;
    this.tournamentSize = tournamentSize;
    this.crossoverRate = crossoverRate;
    this.mutationRate = mutationRate;
    this.minRelations = minRelations;
    this.maxRelations = maxRelations;
    this.rateCreateRelation = rateCreateRelation;

    this.glyph = glyph;
    this.data = data;

    this.individuals = new Individual[popSize];

    init();
  }

  /**
   * Initialises the population with random individuals.
   */
  void init() {
    // Fill population with random individuals
    for (int i = 0; i < popSize; i++) {
      individuals[i] = new Individual(minRelations, maxRelations, rateCreateRelation, glyph, data);
      individuals[i].randomise();
    }

    // Evaluate individuals
    //evaluator.assignFitness(individuals);

    // Sort individuals in the population by fitness (fittest first)
    sortIndividualsByFitness();

    // Reset generations counter
    generations = 0;
  }

  /**
   * Evolves new generation of individuals.
   */
  void evolve() {
    // Create a new array to store the individuals that will be in the next generation
    Individual[] newGeneration = new Individual[popSize];

    // Copy the elite to the next generation (assuming individuals are already sorted by fitness)
    for (int i = 0; i < eliteSize; i++) {
      newGeneration[i] = individuals[i].getCopy();
    }

    // Breed new individuals with crossover
    for (int i = eliteSize; i < popSize; i += 2) {
      Individual[] newIndivs;
      if (random(1) < crossoverRate) {
        Individual parent1 = tournamentSelection();
        Individual parent2 = tournamentSelection();
        newIndivs = parent1.recombineWith(parent2);
      } else {
        newIndivs = new Individual[]{tournamentSelection().getCopy(), tournamentSelection().getCopy()};
      }
      newGeneration[i] = newIndivs[0];
      if (i + 1 < popSize) {
        newGeneration[i + 1] = newIndivs[1];
      }
    }

    // Mutate new individuals
    for (int i = eliteSize; i < popSize; i++) {
      newGeneration[i].mutate(mutationRate);
    }

    // Evaluate individuals
    //evaluator.assignFitness(newGeneration);

    // Replace individuals in the population with the new ones
    for (int i = 0; i < popSize; i++) {
      individuals[i] = newGeneration[i];
    }

    // Sort individuals in the population by fitness
    sortIndividualsByFitness();

    // Increment the number of generations
    generations += 1;
  }

  /**
   * Return one individual selected using tournament.
   */
  private Individual tournamentSelection() {
    // Select a set of individuals at random
    Individual[] tournament = new Individual[tournamentSize];
    for (int i = 0; i < tournament.length; i++) {
      int randomIndex = int(random(0, individuals.length));
      tournament[i] = individuals[randomIndex];
    }

    // Return the fittest individual from the selected ones
    Individual fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }
    return fittest;
  }

  /**
   * Sorts individuals in the population by fitness in descending order.
   */
  private void sortIndividualsByFitness() {
    Arrays.sort(individuals, new Comparator<Individual>() {
      public int compare(Individual indiv1, Individual indiv2) {
        return Float.compare(indiv2.getFitness(), indiv1.getFitness());
      }
    }
    );
  }

  /**
   * Returns the individual located at the given index.
   */
  Individual getIndividual(int index) {
    return individuals[index];
  }

  /**
   * Returns the number of individuals in the population.
   */
  int getSize() {
    return popSize;
  }

  /**
   * Returns the number of generations evolved so far.
   */
  int getGenerations() {
    return generations;
  }
}
