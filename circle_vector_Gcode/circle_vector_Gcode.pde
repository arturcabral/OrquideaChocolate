import geomerative.*;

RShape grp;
RPoint[][] pointPaths;

String fileName = "exemplo"; // Name of the file you want to convert, as to be in the same directory
String penUp= "M03 S0 \n"; // Command to control the pen, it change beetween differents firmware
String penDown = "M03 S20 \n";// This settings was made for my custom CNC Drawing machine

public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { 0, 50};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = { 0, 50};// These settings also change between your configuration

String gcodecommand ="G0 F16000 \n G0"+ penUp; // String to store the Gcode we wil save later

float xmag, ymag, newYmag, newXmag = 0;
float z = 0;

boolean ignoringStyles = false;
boolean estadoImpressoraImprimindo = false;
boolean active = false; // BOOLEANO dizendo que vai ter noise


geradorCirculo controleCirculo; // objeto controlador do gerador do circulo

int filesaved = 0;


class obraArte17 implements Runnable{
    public controleSerial serialControle ; // Controlador para mandar via interface serial!
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
                /*for(String comando :pontosGcodeBuffer){
                        print(comando);
                        serialControle.mandaComandoGcode(comando);
                      
                }
                */
                delay(4000);
                print("\t################## fim da IMPRESSAO pela impressora 3D##################\n");
                estadoImpressoraImprimindo = false;  
                active = false;
            }
        }
    }
    
}





//FUNCAO SETUP
void setup() {
  // Seta os settings da janela e engine de desenho
  // Seta Frame Rate = 60
  // Instancia gerador de circulo, controle PARALELO do controle serial da impressora
  // Da start no programa controlador do controlador da impressora
  size(600, 600, P3D);
  frameRate(30);
  controleCirculo = new geradorCirculo(this); 
  // VERY IMPORTANT: Allways initialize the library before using it
  //pontosGcodeBuffer = toGcodeBufferStrings(controleCirculo);
  obraArte17 controleImpressora = new obraArte17(143);
  new Thread(controleImpressora).start();
  //serialControle = new controleSerial(this,true);
}



void draw() {
    //Background para limpar a cena
    background(000);
    if (keyPressed && key == ENTER && !estadoImpressoraImprimindo){
        estadoImpressoraImprimindo = true;
        active = true;
        print("\t################## DETECTEI ENTER ##################\n");
    }
    controleCirculo.circulo(active);  
    controleCirculo.desenhaCirculo();
    //print("\t################## to no DELAY !##################\n");
    //delay(3000);
}
