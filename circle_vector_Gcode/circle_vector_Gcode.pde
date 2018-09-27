import geomerative.*;

RShape grp;
RPoint[][] pointPaths;



public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { 0, 75};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = {0, 75};// These settings also change between your configuration

String gcodecommand;

float xmag, ymag, newYmag, newXmag = 0;
float z = 0;

boolean ignoringStyles = false;
boolean estadoImpressoraImprimindo = false;
int filesaved = 0;
public controleSerial serialControle ; // Controlador para mandar via interface serial!
public leitorPlanta leitor ; // Controlador para mandar via interface serial!
public GeradorCirculo controladorCirculo; // Controlador para o circulo e formatos
public TradutorGcode tradutorGcode; // Controlador para o tradutor de circulos para GCODE 
public Thread controladorThread; // Controlador do processo da Thread
public obraArte17 controleImpressora; // Classe principal da Obra


class obraArte17 implements Runnable {
  long minPrime;

  obraArte17(long minPrime) {
    this.minPrime = minPrime;
  }

  //  Thread com comportamento utilizada para ser feito em paralelo para imprimir
  public void run() {
    while (true) {
      print("\t################## RODANDO ##################\n");
      delay(2000);
      //testa se eh coded por que nao sei
      if (estadoImpressoraImprimindo) {
        print("\t################## IMPRIME pela impressora 3D##################\n");    
        while (pontosGcodeBuffer == null);     // ESPERA chegar as listas do pontos em Gcode
        for (String comando : pontosGcodeBuffer) {
          print(comando);
          serialControle.mandaComandoGcode(comando);
          if (!estadoImpressoraImprimindo)
            break;
        }

        delay(4000);
        print("\t################## fim da IMPRESSAO pela impressora 3D##################\n");
        estadoImpressoraImprimindo = false;   
        pontosGcodeBuffer = null;
      }
    }
  }
}

void setup() {
  size(800, 600, P3D);
  background(0, 133, 232);
  controleImpressora = new obraArte17(143);
  new Thread(controleImpressora).start();
  serialControle = new controleSerial(this, true);
  leitor = new leitorPlanta(this);
  controladorCirculo = new GeradorCirculo();
  tradutorGcode = new TradutorGcode();
}

synchronized void draw() {

  if (!estadoImpressoraImprimindo)
    leitor.desenhaGraficoPlanta();
  if (keyPressed && key == ENTER && !estadoImpressoraImprimindo) {
    estadoImpressoraImprimindo = true;
    // VERY IMPORTANT: Allways initialize the library before using it
    background(0, 133, 232);
    pontosGcodeBuffer = tradutorGcode.toGcodeBufferStrings(this, controladorCirculo, leitor.retornaValorLidoPlanta());
    controladorCirculo = new GeradorCirculo();
    print("\t################## DETECTEI ENTER ##################\n");
  } 
  if (keyPressed && key == 'k')
    estadoImpressoraImprimindo =false;     
  //print("\t################## to no DELAY !##################\n");
  //delay(3000);
}