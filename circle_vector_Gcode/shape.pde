public class GeradorCirculo {

  boolean active = true;
  int NUM = 100;
  float a = 0 ;
  float r = 100;
  float t = 100;
  public RShape circulo;

  GeradorCirculo() {
    this.circulo = new RShape();
  }

  public void circulo(float intensidadeNoise) {
    if (active) { 
      r = map((noise(t)), 0, 1, 100, 100+50);
    } //solução ponto morto

    circulo.addMoveTo(( r * cos(a)), (r * sin(a)));

    for (int i = 0; i < NUM; i ++) {
      float x = r * cos(a);
      float y = r * sin(a);
      a =  a + TWO_PI/NUM;
      if (intensidadeNoise == 0) {
        intensidadeNoise = 1890.55;
      }
      float noise = map(intensidadeNoise, 0, 20000, 0, 5);

      print("\t################## VALOR MAPEADO PARA NOISE = "+noise+"##################\n");
      t = t+ noise; //intensidade do ruido 
      float n = noise(t);
      n = map(n, 0, 1, 100, 100+50);
      if (active == true) {
        r = n;
      }
      circulo.addLineTo(x, y);
    }
    circulo.addClose();
  }
}