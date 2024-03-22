class GlyphModel {

  // Array with the names of the attributes
  final String[] attrsNames = {
    "colour_bg", // colour of background
    "num_lines", // number of lines (pattern)

    "type_mainFigure",
    "colour_mainFigure", // colour of middle figure
    "size_mainFigure",
    "opacity_mainFigure", // opacity of squares
    // "position_rot_mainFigure"


    "num_subFigures",
    "type_subFigures",
    "colour_subFigures",
    "size_subFigures",
    "opacity_subFigures",

    "vertical_stroke",
    "vertical_x",

    "cross_x",
    "cross_y",
    "cross_size",
    "cross_weigth"
  };

  HashMap<String, Float> attrs;

  // DEFAULT VALUES
  // color palettes
  color bg_default = color(255);
  color mainFigure_default = color(150);
  color bg_ini = color(255, 100, 0);
  color bg_fin = color(10, 150, 255);



  // mainFigure
  int main_opacity = 255;
  color main_ini = color(0, 100, 0);
  color main_fin = color(10, 150, 200);

  // subFigures
  float sub_percent = 0.2; // tamanho max, em relação ao canvas
  int nSub_max = 10; // numero de sub figuras máximo
  color sub_default = color(210);
  color sub_ini = color(250, 0, 200);
  color sub_fin = color(10, 0, 255);

  // vertical && cross weigths
  float stroke_v = 20;



  GlyphModel() {
  }

  void setAttributes(Float[] attrsValues) {
    // Create hashmap containing the pair name-value of each attribute
    attrs = new HashMap<String, Float>();
    for (int i = 0; i < attrsNames.length; i++) {
      attrs.put(attrsNames[i], attrsValues[i]);
    }
  }

  /**
   * Draws the glyph based on the given values.
   * The input values for the attributes vary between 0 and 1, or null.
   * When an attribute value is null, a default graphic option is used.
   */
  void draw(PGraphics pg, float x, float y, float dim) {
    pg.push();
    pg.translate(x, y);
    pg.strokeWeight(1);
    pg.strokeCap(SQUARE);

    // Fundo
    pg.noStroke();
    if (attrs.get("colour_bg") != null) pg.fill(lerpColor(bg_ini, bg_fin, attrs.get("colour_bg")));
    else pg.fill(bg_default);
    pg.rect(0, 0, dim, dim);

    if (attrs.get("num_lines") != null) drawLinePattern(pg, attrs.get("num_lines"), dim);


    // Main
    float opacity = (attrs.get("opacity_mainFigure") != null) ? attrs.get("opacity_mainFigure")*255 : main_opacity;

    if (attrs.get("colour_mainFigure") != null) pg.fill(lerpColor(main_ini, main_fin, attrs.get("colour_mainFigure")), opacity);
    else pg.fill(mainFigure_default, opacity);


    // a dimensão da figura dependerá se o rotation está on ou off
    // terá que ser mais pequena, caso o ratation esteja on.

    float dim_mainFigure = (attrs.get("size_mainFigure") != null) ? attrs.get("size_mainFigure")*dim : dim;

    pg.noStroke();


    if (attrs.get("type_mainFigure") != null) drawFigure(pg, dim/2f, dim/2f, attrs.get("type_mainFigure"), dim_mainFigure);
    else pg.circle(dim/2f, dim/2f, dim_mainFigure*0.75);


    // subFigures

    pg.stroke(255);

    if (has_params(attrs, "subFigures")) {

      // numero figuras e tamanho
      int nFig = (attrs.get("num_subFigures") != null) ? int(attrs.get("num_subFigures") * nSub_max) : 1;
      float dim_subFigure = (attrs.get("size_subFigures") != null) ? attrs.get("size_subFigures")*dim*sub_percent : dim*sub_percent;


      // falta a cor!
      opacity = (attrs.get("opacity_subFigures") != null) ? attrs.get("opacity_subFigures")*255 : main_opacity;

      if (attrs.get("colour_subFigures") != null) pg.fill(lerpColor(sub_ini, sub_fin, attrs.get("colour_subFigures")), opacity);
      else pg.fill(sub_default, opacity);

      float ang = TWO_PI/float(nFig);
      float px, py;
      for (int i = 0; i < nFig; i++) {
        px = dim/2 + (dim*0.25) * cos(ang*i);
        py = dim/2 + (dim*0.25) * sin(ang*i);

        if (attrs.get("type_subFigures") != null) drawFigure(pg, px, py, attrs.get("type_subFigures"), dim_subFigure);
        else pg.square(px, py, dim_subFigure*0.75);
      }
    }

    if (has_params(attrs, "vertical")) {

      pg.stroke(200);

      if (attrs.get("vertical_stroke") != null) pg.strokeWeight(attrs.get("vertical_stroke")*stroke_v);
      else pg.strokeWeight(1);

      float pos_x = (attrs.get("vertical_x") != null) ? attrs.get("vertical_x")*dim : dim/2;

      pg.line(pos_x, 0, pos_x, dim);
    }

    if (has_params(attrs, "cross")) {
      /*"cross_x",
       "cross_y",
       "cross_size",
       "cross_weigth"*/
       
       pg.stroke(50);

      if (attrs.get("cross_weigth") != null) pg.strokeWeight(attrs.get("cross_weigth")*stroke_v);
      else pg.strokeWeight(1);
      
      float size = (attrs.get("cross_size") != null) ? attrs.get("cross_size") * 30 : 30;
      float pos_x = (attrs.get("cross_x") != null) ? attrs.get("cross_x")*dim : dim/2;
      float pos_y = (attrs.get("cross_y") != null) ? attrs.get("cross_y")*dim : dim/2;
      
      pg.strokeCap(SQUARE);
      pg.line(pos_x-size/2, pos_y-size/2, pos_x+size/2, pos_y+size/2);
      pg.line(pos_x-size/2, pos_y+size/2, pos_x+size/2, pos_y-size/2);
    }

    pg.pop();
  }

  boolean has_params(HashMap<String, Float> vals, String attribute) {
    for (String k : vals.keySet()) {
      if (k.contains(attribute) && vals.get(k) != null) return true;
    }
    return false;
  }

  /**
   * Returns the number of attributes.
   */
  int getNumAttrs() {
    return attrsNames.length;
  }

  void drawLinePattern(PGraphics pg, float n_lines, float dim) {
    float n = ceil(n_lines*10);
    float inc = dim/n;

    pg.stroke(255);
    for (int i = 1; i < n; i++) {
      pg.line(inc*i, 0, 0, inc*i);
      pg.line(dim-inc*i, dim, dim, dim-inc*i);
      pg.line(dim-inc*i, 0, dim, inc*i);
      pg.line(0, dim-inc*i, inc*i, dim);
    }

    pg.line(0, 0, dim, dim);
    pg.line(dim, 0, 0, dim);
  }

  // limite: só têm 10 figuras possíveis.
  // futuro: saber o tipo de dado:
  //         - se for quantitativo ser uma coisa,
  //         - se for categórico outra  -> saber níveis

  void drawFigure(PGraphics pg, float x, float y, float n_lines, float dim) {
    float n = ceil(n_lines*10);
    float rad = dim*0.5;

    if (n < 1) {
      pg.ellipse(x, y, dim, dim/2);
    } else if (n < 2) {
      star(pg, x, y, dim/2, dim/3, false);
    } else if (n < 3) {
      star(pg, x, y, dim/2, dim/3, true);
    } else if (n < 10) {
      float inc = TWO_PI/n;
      float ini = -HALF_PI;
      pg.beginShape();
      for (int i = 0; i < n; i++) {
        pg.vertex(x+rad*cos(ini+inc*i), y+rad*sin(ini+inc*i));
      }
      pg.endShape(CLOSE);
    } else {
      pg.circle(x, y, rad);
    }
  }

  void star(PGraphics pg, float x, float y, float radius1, float radius2, boolean curve) {
    int npoints = (curve) ? 7 : 5;
    float angle = TWO_PI / float(npoints);
    float halfAngle = angle/2.0;
    float sx, sy;
    pg.beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      sx = x + cos(-HALF_PI+a) * radius1;
      sy = y + sin(-HALF_PI+a) * radius1;
      if (curve) pg.curveVertex(sx, sy);
      else pg.vertex(sx, sy);

      sx = x + cos(-HALF_PI+a+halfAngle) * radius2;
      sy = y + sin(-HALF_PI+a+halfAngle) * radius2;
      if (curve) pg.curveVertex(sx, sy);
      else pg.vertex(sx, sy);
    }
    pg.endShape(CLOSE);
  }
}
