import geomerative.*;

RShape grp;
RPoint[][] pointPaths;

public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { 0, 75};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = {0, 75};// These settings also change between your configuration

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

void setup() {
  size(800, 600, P3D);
  background(0, 133, 232);
  serialControle = new controleSerial(this, true);
  leitor = new leitorPlanta(this);
  controladorCirculo = new GeradorCirculo();
  tradutorGcode = new TradutorGcode();
  controleImpressora = new obraArte17(143);
  new Thread(controleImpressora).start();
}

synchronized void draw() {
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