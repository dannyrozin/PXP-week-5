// The world pixel by pixel 2021
// Daniel Rozin
// paint with live loops on top of live video
import processing.video.*;
PImage[] ourImage = new PImage[100];                     // we'll have 100 images to hold all the painted pixels
int frameNum=0;                                         // this will count our frame in the loop
Capture ourVideo;                                 // variable to hold the video object
void setup() {
  size(1280, 720);
  ourVideo = new Capture(this, width, height);    // open the capture in the size of the window
  ourVideo.start(); 
  background(255);                                    // start the video


  for (int i = 0; i< 100; i++) {                          // well do the following to all 100 images:
    ourImage[i] =  createImage(width, height, ARGB);      // create an empty image with Alpha
    ourImage[i].loadPixels();                             // load the pixels of the new image
    for (int x = 0; x < width; x++) {                     // we want to start out with all the pixels
      for (int y = 0; y < height; y++) {                // in our image having an alpha of 0
        PxPSetPixel(x, y, 0, 0, 0, 0, ourImage[i].pixels, width);
      }
    }
  }
}



void draw() {
  frameNum = (++frameNum) % 100;                               // increment our frameNum variable up to 100
  ourImage[frameNum].loadPixels();                             // ourImage[frameNum] is now our active image for this frame
  if (ourVideo.available())  ourVideo.read();  
  if (mousePressed) {
    for (int x = mouseX-50; x< mouseX+50; x++) {               // lets do the effect for 50 pixels around the mouse
      for (int y = mouseY-50; y< mouseY+50; y++) {
        if (dist(x, y, mouseX, mouseY)< 50) {                  // lets have a circle "brush" radius 50
          int useX=  constrain(x, 0, width-1);                                // make sure were not acceesing pixels out side of the pixels array
          int useY=  constrain(y, 0, height-1);
          PxPGetPixel(useX, useY, ourVideo.pixels, width);  
          PxPSetPixel(useX, useY, R, G, B, 255, ourImage[frameNum].pixels, width);        // setting the colors from the video to our image
        }                                                                       // important to set alpha to 255
      }
    }
  }
  ourImage[frameNum].updatePixels();
  image (ourVideo, 0, 0);             // every time around we draw the live video
  image (ourImage[frameNum], 0, 0);              // and the painted pixels above
}



// our function for getting color components , it requires that you have global variables
// R,G,B   (not elegant but the simples way to go, see the example PxP methods in object for 
// a more elegant solution
int R, G, B, A;          // you must have these global varables to use the PxPGetPixel()
void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}


//our function for setting color components RGB into the pixels[] , we need to efine the XY of where
// to set the pixel, the RGB values we want and the pixels[] array we want to use and it's width

void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
