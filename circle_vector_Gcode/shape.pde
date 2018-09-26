
public class geradorCirculo{
  
    private int NUM = 100;
    private int intervaloAtualPontos = 0;
    private int comprimentoIntervalo = 10;
    private float ultimoX = 0 ;
    private float ultimoY = 0 ;
    private float a = 0 ;
    private float r = 100;
    private float t = 100;
    public RShape circulo = new RShape();
    
    geradorCirculo(PApplet parent){
        RG.init(parent);
        RG.ignoreStyles(ignoringStyles);
        RG.setPolygonizer(RG.ADAPTATIVE);
        if (active) { r = map((noise(t)), 0, 1, 100, 100+50); } //solução ponto morto
        ultimoX =  r * cos(a);
        ultimoY = (r * sin(a));
    }
    
    synchronized void circulo(boolean active) {
      int j;
      this.circulo.addMoveTo(( ultimoX), (ultimoY));
      for (j = 0; j < comprimentoIntervalo; j++) {
        float x = ultimoX = r * cos(a);
        float y = ultimoY = r * sin(a);
        a =  a + TWO_PI/NUM;
        t = t+ 0.3; //intensidade do ruido 
        float n = noise(t);
        n = map(n, 0, 1, 100, 100+50);
        if (active == true) {
          r = n;
        }
        circulo.addLineTo(x, y);
        this.intervaloAtualPontos = (this.intervaloAtualPontos+1)%(NUM+1);
      }
      //circulo.addClose();
    }
    
   void desenhaCirculo(){
       //grp.centerIn(g, 100, 1, 1);
       stroke(#ffffff);
       noFill();
       translate(width/2, height/2);
       this.circulo.draw();
       this.circulo = new RShape();
       stroke(000);
   }
}
