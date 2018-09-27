import java.util.*;

public class TradutorGcode {
      //CAMPOS
      // apendice global, um valor para extrusora
      // Incrementos por ponto quanto vai ser jogado por ponto pela extrusora
      // PontosRelativos eh o ponto zero para desenhar na impressora
      private double ApendiceGlobalComando = 2.17858;
      final float incrementoExtrusora = 1;
      private int pontoYRelativo = 75/2;
      private int pontoXRelativo = 75/2;

      public TradutorGcode(){ 
      } 
      public TradutorGcode(int pontoXRelativo, int pontoYRelativo){ 
          this.setarPontoZero(pontoXRelativo,pontoYRelativo);
      } 
      
      //SET PONTO ZERO para ser como referencia
      public void setarPontoZero(int pontoXRelativo, int pontoYRelativo){
          this.pontoXRelativo = pontoXRelativo;
          this.pontoYRelativo = pontoYRelativo;
      }
      
      String[] toGcodeBufferStrings(PApplet parent,GeradorCirculo controlador,float intensidadeNoise) {
          ArrayList <String>retornoStrings = new ArrayList<String>(); 
          RG.init(parent);
          RG.ignoreStyles(ignoringStyles);
          RG.setPolygonizer(RG.ADAPTATIVE);
          controlador.circulo(intensidadeNoise);
          grp = controlador.circulo;
          grp.centerIn(g, 100, 1, 1);
          pointPaths = grp.getPointsInPaths();
          translate(width/2, height/2);
          newXmag = mouseX/float(width) * TWO_PI;
          newYmag = mouseY/float(height) * TWO_PI;
          float diff = xmag-newXmag;
          if (abs(diff) >  0.01) { 
            xmag -= diff/4.0;
          }
          diff = ymag-newYmag;
          if (abs(diff) >  0.01) { 
            ymag -= diff/4.0;
          }
          rotateX(-ymag); 
          rotateY(-xmag); 
          background(0);
          stroke(255);
          noFill();
          for (int i = 0; i<pointPaths.length; i++) {
            if (pointPaths[i] != null) {
              beginShape();
              for (int j = 0; j<pointPaths[i].length; j++) {
                vertex(pointPaths[i][j].x, pointPaths[i][j].y);
                float xmaped = map(pointPaths[i][j].x, -200, 200, xcoord[1], xcoord[0]);
                float ymaped = map(pointPaths[i][j].y, -200, 200, ycoord[0], ycoord[1]);
                if (j == 1) {
                  //gcodecommand = gcodecommand + penDown;
                }
                ApendiceGlobalComando += incrementoExtrusora ;
                gcodecommand = gcodecommand + "G1 X"+ str(xmaped+pontoXRelativo)+" Y"+str(ymaped+pontoYRelativo) +" E"+ApendiceGlobalComando+"; \n";
              }
              endShape();
            }
            gcodecommand = gcodecommand + "M72 P2 ;\n";
            if (i == pointPaths.length-1) {
               String[] retornoAuxiliar = split(gcodecommand, '\n');
               for(int k=0; k<retornoAuxiliar.length ; k++) 
                   retornoStrings.add(retornoAuxiliar[k]+"\n");
            }
          }
          return retornoStrings.toArray(new String[retornoStrings.size()]);
    }
}
