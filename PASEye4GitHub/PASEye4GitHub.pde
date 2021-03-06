/*
Rendere l'algoritmo di pupil detection + rock solid!!!
*/
import processing.video.*;

//variabili del meccanismo di smoothing() 
int numReadings=4;
int numReadingsNorth=4;
int []eastXs=new int[numReadings];
int []northYs=new int[numReadingsNorth];
int totalEast,totalNorth,indexEast,indexNorth,averageEast,averageNorth;
//var per i 2 colori in gioco nello sketch
color pupil=color(217,10,245);
color lensColor=color(10,239,245);
//coordinate del punto più a est e di quello più a nord della pupil
int eastX,eastY,northX,northY;
//coordinate del punto più a ovest e di quello più a sud della pupil
int ovestX,ovestY,sudX,sudY;

//soglia di distinzione tra i pixel scuri della pupil e il chiaro dell'iride
int threshold=115; 
//int threshold=15; 

//coordinate della lente                                           
int cursorX,cursorY;  
//coordinate del darkest point della pupil
int darkestX,darkestY;
//var di monitoraggio
boolean visualize=false;
int monitorSwitch=0;
int camWidth = 640;
int camHeight = 480;
//int lensWidth = 640;
//int lensHeight = 480;
int lensWidth = 540;
int lensHeight = 300;
//int oldX = 10000;
//int oldY = 10000;
Capture cam;
int gest_Destra = 310;
int gest_Sinistra = 220;
//centro è tra 220 e 310

int posizione = 1;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;        // Data received from the serial port

int time;
int wait = 1500;

boolean tick;



void setup() {
  size(camWidth, camHeight);
  String[] cameras = Capture.list();
  cam = new Capture(this, camWidth, camHeight, 30);
  cam.start();
  
    String portName = Serial.list()[0];
  //print(portName);
  myPort = new Serial(this, portName, 9600);
  
  time = millis();//store the current time
}

void draw() {
  //reset del darkest
  int darkest=255;
  
  if (cam.available() == true){
    cam.read();
  }

  PImage frame=cam;                 //buffering

  //mirroring
  pushMatrix();
  translate(width, 0);
  scale(-1, 1);
  image(frame, 0, 0);
  popMatrix();
  
  //darkest point scan
  //provare ad aggiungere un vincolo per lo scanning, al fine che rimanga vicino al centro della lente
  //così da evitare il disturbo di ciglia, sopracciglia ecc... Anche se non è un granché come algoritmo!

  //int ics = 0;
  for(int y=cursorY;y<cursorY+lensHeight;y++){
    for(int x=cursorX;x<cursorX+lensWidth;x++){
      color ink=get(x,y);
      if(brightness(ink)<darkest){
        darkest=int(brightness(ink));
        darkestX=x;
        darkestY=y;
      
      }
    }
  }


  //Initialize east e north point
  eastX=darkestX;
  eastY=darkestY;
  northX=darkestX;
  northY=darkestY;
  
  //centro
  posizione = 1;
  
  //destra
  if (eastX > gest_Destra){
   // manda "6/n" alla seriale 36
   if(millis() - time >= wait){
        fill(204);                    // change color and
        myPort.write("DESTRA-");              // send an H to indicate mouse is over square
        tick = !tick;//if it is, do something
        time = millis();//also update the stored time
      }
      
        posizione = 2;
  }
  
  //sinistra
  if (eastX < gest_Sinistra){
   // manda "6/n" alla seriale 36
   if(millis() - time >= wait){
        fill(204);                    // change color and
        tick = !tick;//if it is, do something
        time = millis();//also update the stored time
      }
      
        posizione = 0;
  }
  
  
  //Initialize ovest e sud point
  //ovestX=oldX;
  //ovestY=oldY;
  //sudX=oldX;
  //sudY=oldY;
  
  if(monitorSwitch==3){
    println("ovestX:  "+ovestX);
  }
  if(monitorSwitch==4){
    println("sudX:  "+sudX);
  }
  if(monitorSwitch==5){

   if (posizione == 0){
      println("Posizione : SINISTRA");
    }    
    if (posizione == 1){
      println("Posizione : CENTRO");
    }    
    if (posizione == 2){
      println("Posizione : DESTRA");
    }
    
  }
   
   
 if (posizione == 0){
      myPort.write('s');              // send an H to indicate mouse is over square

    }    
    if (posizione == 1){
      myPort.write('c');              // send an H to indicate mouse is over square
    }    
    if (posizione == 2){
      myPort.write('d');              // send an H to indicate mouse is over square
    }
    
    
  horizontalScan(1,-1);       //1° quadrante
  horizontalScan(1,1);        //2° quadrante
  horizontalScan(-1,1);       //3° quadrante
  horizontalScan(-1,-1);      //4° quadrante
  
  verticalScan(1,-1);
  verticalScan(1,1);
  verticalScan(-1,1);
  verticalScan(-1,-1);
  
  if(visualize){
    noStroke();
    fill(lensColor);
    stroke(lensColor);
    smoothingEast();                     //tutte le variabili devono rimanere global
    line(eastX,0,eastX,height);  
    stroke(lensColor);
    fill(lensColor);
    smoothingNorth();
    line(0,northY,width,northY);
  }
  
/*
    noStroke();
    fill(lensColor);
    stroke(lensColor);
    //smoothingEast();                     //tutte le variabili devono rimanere global
    line(ovestX,0,ovestX,height);
    stroke(lensColor);
    fill(lensColor);
    //smoothingNorth();
    line(0,sudY,width,sudY);
*/
  
  //disegna la lente
  stroke(lensColor);
  fill(lensColor, 0);  //set transparency
  //rect((width-lensWidth)/2, (height -lensHeight) /2, lensWidth, lensHeight);
  rect(cursorX, cursorY,lensWidth, lensHeight);
  strokeWeight(3);
  point(darkestX,darkestY);
  strokeWeight(1);
}
