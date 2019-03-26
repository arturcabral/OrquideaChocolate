import processing.serial.*;


public class controleSerial {
  //CAMPOS
  private Serial myPort;
  private int tempoPorInstrucao = 450;


  //#################### METODOS ####################
  //Funcao que espera o arduino estar em wait
  void esperaArduino() {
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
    this.myPort=new Serial(parent, Serial.list()[0], 115200); //<>//
  }
  //Metodo de enviar o cabecalho para fazer mandar o inicio da comunicacao serial com a impressora
  void mandaCabecalhoGCode() {
    myPort.write("M302 P1; \n");    // Permite extrusao a frio 
    esperaArduino();
    myPort.write("G28 ; \n");       // Volta pra casa 
    esperaArduino();
    myPort.write("G90; \n");        // Define as posicoes seguintes como absoluta(90) ou relativa(91)  
    esperaArduino();  
    myPort.write("M82; \n");        // Seta a extrusora como modo absoluto
    esperaArduino();
    myPort.write("G92 E0; \n"); //zera o comprimeiro do extrusor 
    esperaArduino();
    myPort.write("G1 F7800.000; \n"); //deposita algo 
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
  void modoEsperaChocolate(){
    print("################### STANDBY! ###################\n");
    //myPort.write("G1 E-2.0 \n");
    //esperaArduino();
    myPort.write("G92 E0; \n");
    esperaArduino();
  }

  //manda um string de comando na porta serial
  void mandaComandoGcode(String comando) {
    myPort.write(comando+"; \n");
    esperaArduino();
  }
}
