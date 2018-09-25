import geomerative.*;

RShape grp;
RPoint[][] pointPaths;

String fileName = "exemplo"; // Name of the file you want to convert, as to be in the same directory
String penUp= "M03 S0 \n"; // Command to control the pen, it change beetween differents firmware
String penDown = "M03 S20 \n";// This settings was made for my custom CNC Drawing machine

public String[] pontosGcodeBuffer;  //  Buffer de strings com comandos da forma ja calculada

float[] xcoord = { -108, -195};// These variables define the minimum and maximum position of each axis for your output GCode 
float[] ycoord = { -108, -195};// These settings also change between your configuration

String gcodecommand ="G0 F16000 \n G0"+ penUp; // String to store the Gcode we wil save later

float xmag, ymag, newYmag, newXmag = 0;
float z = 0;

boolean ignoringStyles = false;
int filesaved = 0;

public controleSerial serialControle ; // Controlador para mandar via interface serial!

void setup() {
  size(600, 600, P3D);
  // VERY IMPORTANT: Allways initialize the library before using it
  pontosGcodeBuffer = toGcodeBufferStrings();
  serialControle = new controleSerial(this,true);
}

void draw() {
    for(String comando :pontosGcodeBuffer)
        serialControle.mandaComandoGcode(comando);
}
