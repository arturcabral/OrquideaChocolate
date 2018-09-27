import geomerative.*;

RShape grp;
RPoint[][] pointPaths;

String fileName = "exemplo"; // Name of the file you want to convert, as to be in the same directory
String penUp= "M03 S0 \n"; // Command to control the pen, it change beetween differents firmware
String penDown = "M03 S20 \n";// This settings was made for my custom CNC Drawing machine

public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { 0, 75};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = {0, 75};// These settings also change between your configuration

String gcodecommand ="G0 F16000 \n G0"+ penUp; // String to store the Gcode we wil save later

float xmag, ymag, newYmag, newXmag = 0;
float z = 0;

boolean ignoringStyles = false;
boolean estadoImpressoraImprimindo = false;
int filesaved = 0;
public controleSerial serialControle ; // Controlador para mandar via interface serial!
public leitorPlanta leitor ; // Controlador para mandar via interface serial!
public GeradorCirculo controlador; // Controlador para o circulo e formatos
public TradutorGcode tradutorGcode; // Controlador para o tradutor de circulos para GCODE 

class obraArte17 implements Runnable{
    long minPrime;
    
    obraArte17(long minPrime) {
         this.minPrime = minPrime;
    }
        
    //  Thread com comportamento utilizada para ser feito em paralelo para imprimir
    public void run(){
        while(true){
            print("\t################## RODANDO ##################\n");
            delay(2000);
            //testa se eh coded por que nao sei
            if(estadoImpressoraImprimindo){
                print("\t################## IMPRIME pela impressora 3D##################\n");    
                while(pontosGcodeBuffer == null);     // ESPERA chegar as listas do pontos em Gcode
                for(String comando :pontosGcodeBuffer){
                        print(comando);
                        serialControle.mandaComandoGcode(comando);
                      
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
  size(600, 600, P3D);
  obraArte17 controleImpressora = new obraArte17(143);
  new Thread(controleImpressora).start();
  serialControle = new controleSerial(this,true);
  leitor = new leitorPlanta(this);
  controlador = new GeradorCirculo();
  tradutorGcode = new TradutorGcode();
}

synchronized void draw() {
    
    if(!estadoImpressoraImprimindo)
        leitor.desenhaGraficoPlanta();
    if (keyPressed && key == ENTER && !estadoImpressoraImprimindo){
        estadoImpressoraImprimindo = true;
        // VERY IMPORTANT: Allways initialize the library before using it
        pontosGcodeBuffer = tradutorGcode.toGcodeBufferStrings(this,controlador,leitor.retornaValorLidoPlanta());
        print("\t################## DETECTEI ENTER ##################\n");
    } 
    //print("\t################## to no DELAY !##################\n");
    //delay(3000);
}
