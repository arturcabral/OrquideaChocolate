import geomerative.*;
import controlP5.*;

protected enum ESTADOS{
  IMPRIMINDO,
  REBOBINANDO,
  PARADO
}

ControlP5 cp5;          // Slider de interface para as camadas

RShape grp;
RPoint[][] pointPaths;

public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { 0, 80};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = {0, 80};// These settings also change between your configuration

protected float xmag, ymag, newYmag, newXmag = 0;
protected float z = 0;

protected boolean rebobina = false;                    // valor Booleano do botao de rebobina
protected boolean ignoringStyles = false;
protected boolean estadoImpressoraImprimindo = false;
protected ESTADOS estadosMaquina = ESTADOS.PARADO ;        // Array de booleano 
protected int contadorFramesRetracao = 0;                  // contador para o evento de retracao em alguns segundos. 
protected int numeroDeCamadas = 1 ;                        // contador
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
      // SE ESTADO REBOBINA usa o metodo de rebobina
      delay(2000);
      if (estadosMaquina ==  ESTADOS.IMPRIMINDO) {
        print("\t################## IMPRIME pela impressora 3D##################\n");    
        while (pontosGcodeBuffer == null);     // ESPERA chegar as listas do pontos em Gcode
        for (String comando : pontosGcodeBuffer) {
          serialControle.mandaComandoGcode(comando);
          if (estadosMaquina !=  ESTADOS.IMPRIMINDO)
            break;
        }
        pontosGcodeBuffer = null;        
        estadosMaquina = ESTADOS.PARADO;   
      }
      if(estadosMaquina == ESTADOS.REBOBINANDO){
        serialControle.modoRebobinaExtrusora();
        estadosMaquina = ESTADOS.PARADO;
      }
    }
  }
}

void setup() {
//fullScreen();
  size(560,420);
  background(0, 133, 232);
  serialControle = new controleSerial(this, true);
  leitor = new leitorPlanta(this);
  controladorCirculo = new GeradorCirculo();
  tradutorGcode = new TradutorGcode();
  controleImpressora = new obraArte17(143); 
  cp5 = new ControlP5(this);
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("numeroDeCamadas")
     .setPosition(100,50)
     .setRange(1,5)
     .setNumberOfTickMarks(5)
     .setSliderMode(Slider.FLEXIBLE)
     ;
  new Thread(controleImpressora).start();
  // create a toggle
  cp5.addToggle("rebobina")
     .setPosition(40,100)
     .setSize(50,20)
     ;
     
}





synchronized void draw() {
  // LEITURA dos DADOS PLANTA
  if (estadosMaquina ==  ESTADOS.PARADO || estadosMaquina == ESTADOS.REBOBINANDO)
    leitor.desenhaGraficoPlanta();
  // DISPARA EVENTO de GERAR FORMA e SEU GCODE 
  // ESCONDE OS BOTOES pq ficam repitidos
  if (keyPressed && key == ENTER && estadosMaquina == ESTADOS.PARADO) {
    print("\t################## DETECTEI ENTER ##################\n");
    estadosMaquina = ESTADOS.IMPRIMINDO;
    // VERY IMPORTANT: Allways initialize the library before using it
    background(0, 133, 232);
    pontosGcodeBuffer = tradutorGcode.toGcodeBufferStringsVaseMode(this, controladorCirculo, leitor.retornaValorLidoPlanta(),numeroDeCamadas);
    
  } 
  // PARA A IMPRESSAO
  if (estadosMaquina == ESTADOS.IMPRIMINDO && keyPressed && key == 'k')
    estadosMaquina = ESTADOS.PARADO;    
  // REBOBINA
  if( estadosMaquina == ESTADOS.PARADO && rebobina){
      estadosMaquina = ESTADOS.REBOBINANDO;
       print("\t################## DETECTEI REBOBINA ##################\n");
  }
    
}
