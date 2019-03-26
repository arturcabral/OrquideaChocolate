import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import geomerative.*; 
import processing.serial.*; 
import processing.serial.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class circle_vector_Gcode extends PApplet {



RShape grp;
RPoint[][] pointPaths;

public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { 0, 80};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = {0, 80};// These settings also change between your configuration

float xmag, ymag, newYmag, newXmag = 0;
float z = 0;

boolean ignoringStyles = false;
boolean estadoImpressoraImprimindo = false;
int contadorFramesRetracao = 0;                  // contador para o evento de retracao em alguns segundos. 
final int framesEventoRetracao = 5*(int)frameRate;// numero de frames para o numero de segundos a ser multiplicados
public controleSerial serialControle ;           // Controlador para mandar via interface serial!
public leitorPlanta leitor ;                     // Controlador para mandar via interface serial!
public GeradorCirculo controladorCirculo;        // Controlador para o circulo e formatos
public TradutorGcode tradutorGcode;              // Controlador para o tradutor de circulos para GCODE 
public Thread controladorThread;                 // Controlador do processo da Thread
public obraArte17 controleImpressora;            // Classe principal da Obra


class obraArte17 implements Runnable {
  long minPrime;

  obraArte17(long minPrime) {
    this.minPrime = minPrime;
  }

  //  Thread com comportamento utilizada para ser feito em paralelo para imprimir
  public synchronized void run() {
    while (true) {
      // Delay de 2 segundos para proximo standby
      // testa se recebeu uma ordem de impressao pelo booleano de estado
      // Caso nao tenha volte um pouco a impressora para nao cair chocolate pela gravidade
      delay(2000);
      if (estadoImpressoraImprimindo) {
        print("\t################## IMPRIME pela impressora 3D##################\n");    
        while (pontosGcodeBuffer == null);     // ESPERA chegar as listas do pontos em Gcode
        for (String comando : pontosGcodeBuffer) {
          serialControle.mandaComandoGcode(comando);
          if (!estadoImpressoraImprimindo)
            break;
        }
        pontosGcodeBuffer = null;        
        estadoImpressoraImprimindo = false;   
      }else if(serialControle != null){
          serialControle.modoEsperaChocolate();
      }
    }
  }
}

public void setup() {
  
  background(0, 133, 232);
  serialControle = new controleSerial(this, true);
  leitor = new leitorPlanta(this);
  controladorCirculo = new GeradorCirculo();
  tradutorGcode = new TradutorGcode();
  controleImpressora = new obraArte17(143);
  new Thread(controleImpressora).start();
}

public synchronized void draw() {
  if (!estadoImpressoraImprimindo)
    leitor.desenhaGraficoPlanta();
  if (keyPressed && key == ENTER && !estadoImpressoraImprimindo) {
    print("\t################## DETECTEI ENTER ##################\n");
    estadoImpressoraImprimindo = true;
    // VERY IMPORTANT: Allways initialize the library before using it
    background(0, 133, 232);
    pontosGcodeBuffer = tradutorGcode.toGcodeBufferStrings(this, controladorCirculo, leitor.retornaValorLidoPlanta());
  } 
  if (keyPressed && key == 'k')
    estadoImpressoraImprimindo =false;     
}



public class controleSerial {
  //CAMPOS
  private Serial myPort;
  private int tempoPorInstrucao = 450;


  //#################### METODOS ####################
  //Funcao que espera o arduino estar em wait
  public void esperaArduino() {
    String respostaArduino;
    //do { 
      delay(tempoPorInstrucao); 
    //  respostaArduino = myPort.readString();
    //} while (respostaArduino == null || !respostaArduino.trim().equals("wait"));
    //print("\t########NOVA OPERACAO ########\n");
  }


  //#################### CONTRUTORES //####################

  //Construtor que instancia o comunicador com a porta serial
  public  controleSerial(PApplet parent, boolean mandaCabecalho) {
    instanciarSerial(parent);
    delay(3000);
    if (mandaCabecalho)
      this.mandaCabecalhoGCode();
  }

  public synchronized void instanciarSerial(PApplet parent) {
    this.myPort=new Serial(parent, Serial.list()[0], 115200);
  }
  //Metodo de enviar o cabecalho para fazer mandar o inicio da comunicacao serial com a impressora
  public void mandaCabecalhoGCode() {
    myPort.write("M302 P1; \n");    // Permite extrusao a frio 
    esperaArduino();
    myPort.write("G28 ; \n");       // Volta pra casa 
    esperaArduino();
    myPort.write("G90; \n");        // Define as posicoes seguintes como absoluta(90) ou relativa(91)  
    esperaArduino();  
    myPort.write("M82; \n");        // Seta a extrusora como modo absoluto
    esperaArduino();
    myPort.write("G92 E0; \n");
    esperaArduino();
    myPort.write("G1 F7800.000; \n");
    esperaArduino();
    /*
      myPort.write("G1 E-2.00000 F2400.00000; \n");
     esperaArduino();
     myPort.write("G92 E0; \n");
     esperaArduino();
     myPort.write("G1 X92.415 Y93.003 F7800.000 ; \n");
     esperaArduino();
     myPort.write("G1 E2.00000 F2400.00000 ; \n");
     esperaArduino();
     myPort.write("G1 F1199.64 ; \n");
     esperaArduino();
     */
    /*
      myPort.write("G1 X94.168 Y91.524 E2.07096; \n");
     esperaArduino();
     myPort.write("G1 X96.320 Y90.731 E2.14192; \n");
     esperaArduino();
     myPort.write("G1 X97.500 Y90.625 E2.17858; \n");
     esperaArduino();
     */

    print("FIM TESTE");
  }
  //
  public void modoEsperaChocolate(){
    print("################### STANDBY! ###################\n");
    //myPort.write("G1 E-2.0 \n");
    //esperaArduino();
    myPort.write("G92 E0; \n");
    esperaArduino();
  }

  //manda um string de comando na porta serial
  public void mandaComandoGcode(String comando) {
    myPort.write(comando+"; \n");
    esperaArduino();
  }
}


public class leitorPlanta implements Runnable {
  private Serial myPort;
  private int xPos = 0;         // horizontal position of the graph
  private PVector pontoAntigo = new PVector(0, 0);
  private long intervaloValoresPlanta = 20000;

  leitorPlanta(PApplet parent) {
    myPort = new Serial(parent, Serial.list()[1], 9600);
    myPort.bufferUntil('\n');
  }

  public void run() {
    while (true) {
      if (!estadoImpressoraImprimindo) {
        desenhaGraficoPlanta();
      }
    }
  }


  public float retornaValorLidoPlanta() {
    String inString = myPort.readStringUntil('\n');
    if (inString != null) {
      inString = trim(inString);
      return PApplet.parseInt(inString) % intervaloValoresPlanta - 97.75f;
    } else return 0.0f;
  }

  public void desenhaGraficoPlanta() {
    float inByte = retornaValorLidoPlanta(); 
    inByte = map(inByte, 97, 30000, height/2, height - 100);
    textSize(32);
    text("orchis_food", 25, 43); 
    stroke(255);
    strokeWeight(2);
    line(pontoAntigo.x, pontoAntigo.y, xPos, height - inByte);
    pontoAntigo.set(xPos, height-inByte);
    if (xPos >= width) {
      xPos = 0;
      pontoAntigo.set(0, 0);
      background (0, 133, 232);
    } else {
      xPos = xPos + 10;
    }
  }
}
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
    } //solu\u00e7\u00e3o ponto morto
    print("\t################# NOISE = "+intensidadeNoise+"#################\n");
    circulo.addMoveTo(( r * cos(a)), (r * sin(a)));

    for (int i = 0; i < NUM; i ++) {
      float x = r * cos(a);
      float y = r * sin(a);
      a =  a + TWO_PI/NUM;
      if ((int)intensidadeNoise == 0) {
        intensidadeNoise = 1890.55f;
      }
      float noise = map(intensidadeNoise, 0, 20000, 0, 5);
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
  
  public void limpaCirculo(){
      this.circulo = new RShape();
  }
  
}


public class TradutorGcode {
  //CAMPOS
  // apendice global, um valor para extrusora
  // Incrementos por ponto quanto vai ser jogado por ponto pela extrusora
  // PontosRelativos eh o ponto zero para desenhar na impressora
  private double ApendiceGlobalComando = 0.0f;
  final float incrementoExtrusora = 1;
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
  public String[] configuracaoInicialExtrusao(){
      ArrayList <String> listaComandosSetup = new ArrayList<String>();
      listaComandosSetup.add("M302 P1; \n");
      listaComandosSetup.add("G90; \n");
      listaComandosSetup.add("M302 P1; \n");
      listaComandosSetup.add("M82 ; \n");
      listaComandosSetup.add("G1 F7800.000 ; \n");
      return listaComandosSetup.toArray(new String[listaComandosSetup.size()]);
  }


  public String[] toGcodeBufferStrings(PApplet parent, GeradorCirculo controlador, float intensidadeNoise) {
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
    this.ApendiceGlobalComando = 0.0f;
    return retornoStrings.toArray(new String[retornoStrings.size()]);
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "circle_vector_Gcode" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
