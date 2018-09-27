import java.util.*;
final String ApendiceGlobalComando = " E2.17858 ";


/*
void toGcodeArquivo() {

  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.ADAPTATIVE);
  circulo();
  grp = circulo;
  grp.centerIn(g, 100, 1, 1);
  pointPaths = grp.getPointsInPaths();
  translate(width/2, height/2);
  newXmag = mouseX/float(width) * TWO_PI;
  newYmag = mouseY/float(height) * TWO_PI;
  float diff = xmag-newXmag;
  if (abs(diff) >  0.01) { 
    xmag -= diff/4.0;
  }
  diff = ymag-newYmag;
  if (abs(diff) >  0.01) { 
    ymag -= diff/4.0;
  }
  rotateX(-ymag); 
  rotateY(-xmag); 
  background(0);
  stroke(255);
  noFill();
  if ( filesaved == 0) {
    for (int i = 0; i<pointPaths.length; i++) {
      if (pointPaths[i] != null) {
        beginShape();
        for (int j = 0; j<pointPaths[i].length; j++) {
          vertex(pointPaths[i][j].x, pointPaths[i][j].y);
          float xmaped = map(pointPaths[i][j].x, -200, 200, xcoord[1], xcoord[0]);
          float ymaped = map(pointPaths[i][j].y, -200, 200, ycoord[0], ycoord[1]);
          if (j == 1) {
            gcodecommand = gcodecommand + penDown;
          }
          gcodecommand = gcodecommand + "G1 X"+ str(xmaped)+" Y"+str(ymaped) +"\n";
        }
        endShape();
      }
      //gcodecommand = gcodecommand + penUp;

      if (i == pointPaths.length-1) {
        String[] gcodecommandlist = split(gcodecommand, '\n');
        saveStrings(fileName+".txt", gcodecommandlist); 
        filesaved = 1;
        println("finished");
      }
    }
  }
}
*/
String[] toGcodeBufferStrings(geradorCirculo controleCirculo) {
  ArrayList <String>retornoStrings = new ArrayList<String>(); 
  controleCirculo.circulo(true);
  grp = controleCirculo.circulo;
  grp.centerIn(g, 100, 1, 1);  
  pointPaths = grp.getPointsInPaths();
  translate(width/2, height/2);
  newXmag = mouseX/float(width) * TWO_PI;
  newYmag = mouseY/float(height) * TWO_PI;
  float diff = xmag-newXmag;
  if (abs(diff) >  0.01) { 
    xmag -= diff/4.0;
  }
  diff = ymag-newYmag;
  if (abs(diff) >  0.01) { 
    ymag -= diff/4.0;
  } 
  background(0);
  stroke(255);
  rotateX(-ymag); 
  rotateY(-xmag);
  noFill();
  for (int i = 0; i<pointPaths.length; i++) {
    if (pointPaths[i] != null) {
      beginShape();
      for (int j = 0; j<pointPaths[i].length; j++) {
        vertex(pointPaths[i][j].x, pointPaths[i][j].y);
        float xmaped = map(pointPaths[i][j].x, -200, 200, xcoord[1], xcoord[0]);
        float ymaped = map(pointPaths[i][j].y, -200, 200, ycoord[0], ycoord[1]);
        if (j == 1) {
          //gcodecommand = gcodecommand + penDown;
        }
        gcodecommand = gcodecommand + "G1 X"+ str(xmaped)+" Y"+str(ymaped) +ApendiceGlobalComando+"\n";
      }
      endShape();
    }
    gcodecommand = gcodecommand + "M72 P2 ;\n";
    if (i == pointPaths.length-1) {
       String[] retornoAuxiliar = split(gcodecommand, '\n');
       for(int k=0; k<retornoAuxiliar.length ; k++) 
           retornoStrings.add(retornoAuxiliar[k]+"\n");
    }
  }
  return retornoStrings.toArray(new String[retornoStrings.size()]);
}
