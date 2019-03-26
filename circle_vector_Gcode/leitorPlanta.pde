import processing.serial.*;
//int width2 , height2 = 50;

public class leitorPlanta implements Runnable {
  private Serial myPort;
  private int xPos = 0;         // horizontal position of the graph
  private PVector pontoAntigo = new PVector(0, 0);
  private long intervaloValoresPlanta = 20000;

      leitorPlanta(PApplet parent) {
        myPort = new Serial(parent, Serial.list()[1], 9600);
        myPort.bufferUntil('\n');
      }

  void run() {
    while (true) {
      if (!estadoImpressoraImprimindo) {
        desenhaGraficoPlanta();
      }
    }
  }


  float retornaValorLidoPlanta() {
    String inString = myPort.readStringUntil('\n');
    if (inString != null) {
      inString = trim(inString);
      return int(inString) % intervaloValoresPlanta - 97.75;
    } else return 0.0;
  }

  void desenhaGraficoPlanta() {
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
