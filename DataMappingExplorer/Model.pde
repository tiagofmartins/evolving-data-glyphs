class GlyphModel {

  // Array with the names of the attributes
  final String[] attrsNames = {
    "colour_bg", // colour of background
    "num_squares", // number of squares
    "opacity_squares", // opacity of squares
    // ...
  };

  GlyphModel() {
  }

  /**
   * Draws the glyph based on the given values.
   * The input values for the attributes vary between 0 and 1, or null.
   * When an attribute value is null, a default graphic option is used.
   */
  void draw(PGraphics pg, float x, float y, float dim, Float[] attrsValues) {
    // Create hashmap containing the pair name-value of each attribute
    HashMap<String, Float> attrs = new HashMap<String, Float>();
    for (int i = 0; i < attrsNames.length; i++) {
      attrs.put(attrsNames[i], attrsValues[i]);
    }
    
    pg.push();
    println(attrs.get("colour_bg"));
    // TODO draw glyph here
    pg.pop();
  }
  
  /**
   * Returns the number of attributes.
   */
  int getNumAttrs() {
    return attrsNames.length;
  }
}
