import processing.serial.*;

public class leitorPlanta implements Runnable{
    private Serial myPort;
    private int xPos = 0;         // horizontal position of the graph
    private PVector pontoAntigo = new PVector(0,0);
    private long intervaloValoresPlanta = 20000;
      
    leitorPlanta(PApplet parent){
        myPort = new Serial(parent, Serial.list()[1], 9600);
        myPort.bufferUntil('\n');
    }
    
    void run(){
        while(true){
            if(!estadoImpressoraImprimindo){
                desenhaGraficoPlanta();
            }
        }
    }
    
    
    float retornaValorLidoPlanta(){
        String inString = myPort.readStringUntil('\n');
        if (inString != null) {
          inString = trim(inString);
          print("\t################## VALOR RETORNADO PELA PLANTA"+ inString+"##################\n");
          return float(inString) % intervaloValoresPlanta; 
        }
        else return 0.0;
    }
    
    void desenhaGraficoPlanta(){
      float inByte = retornaValorLidoPlanta(); 
      inByte = map(inByte, 97, 30000, height/2, height - 100);
      println(inByte);
  
      stroke(255);
      line(pontoAntigo.x,pontoAntigo.y,xPos, height - inByte);
      pontoAntigo.set(xPos,height-inByte);
      if (xPos >= width) {
        xPos = 0;
        pontoAntigo.set(0,0);
        background (0);
      } else {
        xPos = xPos + 10;
      }
        
    }
}
