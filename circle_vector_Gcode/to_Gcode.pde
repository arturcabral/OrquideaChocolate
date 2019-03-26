import java.util.*;
import java.util.function.Consumer;

public class TradutorGcode {
  //CAMPOS
  // apendice global, um valor para extrusora
  // Incrementos por ponto quanto vai ser jogado por ponto pela extrusora
  // PontosRelativos eh o ponto zero para desenhar na impressora
  private double ApendiceGlobalComando = 0.0;
  private final float incrementoExtrusora = 2.5;
  private final float ALTURACAMADA = 1.0f;
  private int pontoYRelativo = 75/2;
  private int pontoXRelativo = 75/2;

  public TradutorGcode() {
  } 
  public TradutorGcode(int pontoXRelativo, int pontoYRelativo) { 
    this.setarPontoZero(pontoXRelativo, pontoYRelativo);
  } 

  //SET PONTO ZERO para ser como referencia
  public void setarPontoZero(int pontoXRelativo, int pontoYRelativo) {
    this.pontoXRelativo = pontoXRelativo;
    this.pontoYRelativo = pontoYRelativo;
  }
  // Funcao que retorna comandos para
  // reconfigura o gcode para estar pronto pra extrusar.
  String[] configuracaoInicialExtrusao() {
    ArrayList <String> listaComandosSetup = new ArrayList<String>();
    listaComandosSetup.add("M302 P1; \n");
    listaComandosSetup.add("G90; \n");
    listaComandosSetup.add("M302 P1; \n");
    listaComandosSetup.add("M82 ; \n");
    listaComandosSetup.add("G1 F7800.000 ; \n");
    return listaComandosSetup.toArray(new String[listaComandosSetup.size()]);
  }


  String[] toGcodeBufferStrings(PApplet parent, GeradorCirculo controlador, float intensidadeNoise) {
    ArrayList <String>retornoStrings = new ArrayList<String>(); 
    StringBuilder gcodecommand = new StringBuilder();
    RG.init(parent);
    RG.ignoreStyles(ignoringStyles);
    RG.setPolygonizer(RG.ADAPTATIVE);
    controlador.circulo(intensidadeNoise);
    grp = controlador.circulo;
    grp.centerIn(g, 100, 1, 1);
    pointPaths = grp.getPointsInPaths();
    translate(width/2, height/2);
    background(0, 133, 232);
    textSize(32);
    text("_imprimindo", -380, 250); 
    stroke(255);
    noFill();
    for (int i = 0; i<pointPaths.length; i++) {
      if (pointPaths[i] != null) {
        beginShape();
        for (int j = 0; j<pointPaths[i].length; j++) {
          vertex(pointPaths[i][j].x, pointPaths[i][j].y);
          float xmaped = map(pointPaths[i][j].x, -200, 200, xcoord[1], xcoord[0]);
          float ymaped = map(pointPaths[i][j].y, -200, 200, ycoord[0], ycoord[1]);   
          ApendiceGlobalComando += incrementoExtrusora ;
          gcodecommand.append("G1 X"+ str(xmaped+pontoXRelativo)+" Y"+str(ymaped+pontoYRelativo) +" E"+ApendiceGlobalComando+"; \n");
        }
        endShape();
      }
      gcodecommand.append("G92 E0; \n");
      gcodecommand.append( "M300 S300 P1000 ;\n");
      if (i == pointPaths.length-1) {
        String[] retornoAuxiliar = split(gcodecommand.toString(), '\n');
        for (int k=0; k<retornoAuxiliar.length; k++) 
          retornoStrings.add(retornoAuxiliar[k]+"\n");
      }
    }
    print("\t################## PONTOS ="+retornoStrings.size()+"################## \n");
    controlador.limpaCirculo();
    this.ApendiceGlobalComando = 0.0;
    return retornoStrings.toArray(new String[retornoStrings.size()]);
  }


  // Funcao prototipo que cria uma lista de Gcode de uma forma com 2 camadas (eixo z)
  String[] toGcodeBufferStringsVaseMode(PApplet parent, GeradorCirculo controlador, float intensidadeNoise) {
    ArrayList <String>retornoStrings = new ArrayList<String>(); 
    StringBuilder gcodecommand = new StringBuilder();
    RG.init(parent);
    RG.ignoreStyles(ignoringStyles);
    RG.setPolygonizer(RG.ADAPTATIVE);
    controlador.circulo(intensidadeNoise);
    grp = controlador.circulo;
    grp.centerIn(g, 100, 1, 1);
    pointPaths = grp.getPointsInPaths();
    translate(width/2, height/2);
    background(0, 133, 232);
    textSize(32);
    text("_imprimindo", -380, 250); 
    stroke(255);
    noFill();
    for (int i = 0; i<pointPaths.length; i++) {
      if (pointPaths[i] != null) {
        beginShape();
        for (int j = 0; j<pointPaths[i].length; j++) {
          vertex(pointPaths[i][j].x, pointPaths[i][j].y);
          float xmaped = map(pointPaths[i][j].x, -200, 200, xcoord[1], xcoord[0]);
          float ymaped = map(pointPaths[i][j].y, -200, 200, ycoord[0], ycoord[1]);   
          ApendiceGlobalComando += incrementoExtrusora ;
          gcodecommand.append("G1 X"+ str(xmaped+pontoXRelativo)+" Y"+str(ymaped+pontoYRelativo) +" E"+ApendiceGlobalComando+"; \n");
        }
        endShape();
      }
      if (i == pointPaths.length-1) {
        String[] retornoAuxiliar = split(gcodecommand.toString(), '\n');
        for (int k=0; k<retornoAuxiliar.length; k++) 
          retornoStrings.add(retornoAuxiliar[k]+"\n");
      } 
    }
    // SUBINDO PARA A PROXIMA CAMADA
    // DUPLICANDO PARA A PROXIMA CAMADA
    // adiciona gcode FAZ BARULHO
    // adiciona gcode Volta para casa
    retornoStrings.add("G1 Z"+ALTURACAMADA+" ;\n");         // Altera a posicao do eixo z, para o comeco da segunda camada
    for(String aux : (ArrayList<String>)retornoStrings.clone())
      retornoStrings.add(aux);
    retornoStrings.add("M300 S300 P1000 ;\n");
    retornoStrings.add("G28 ;\n");
    print("\t################## PONTOS ="+retornoStrings.size()+"################## \n");
    controlador.limpaCirculo();
    this.ApendiceGlobalComando = 0.0;
    return retornoStrings.toArray(new String[retornoStrings.size()]);
  }
}
