// The world pixel by pixel 2019
// Daniel Rozin
// paint with video above live video
import processing.video.*;
PImage ourImage;                                // well use this image to hold all the painted pixels

Capture ourVideo;                                 // variable to hold the video object
void setup() {
  size(1280, 720);
  ourVideo = new Capture(this, width, height);    // open the capture in the size of the window
  ourVideo.start(); 
  background(255);                                    // start the video
  ourImage =  createImage(width, height, ARGB);       // create an empty image with Alpha
  ourImage.loadPixels();
  for (int x = 0; x < width; x++) {                     // we want to start out with all the pixels
    for (int y = 0; y < height; y++) {                // in our image having an alpha of 0
      PxPSetPixel(x, y, 0, 0, 0, 0, ourImage.pixels, width);
    }
  }
  ourImage.updatePixels();
}



void draw() {
  ourImage.loadPixels();
  if (ourVideo.available())  ourVideo.read();  
  if (mousePressed) {
    for (int x = mouseX-20; x< mouseX+20; x++) {
      for (int y = mouseY-20; y< mouseY+20; y++) {
        int useX=  constrain(x, 0, width);                                // make sure were not acceesing pixels out side of the pixels array
        int useY=  constrain(y, 0, height);
        PxPGetPixel(useX, useY, ourVideo.pixels, width);  
        PxPSetPixel(useX, useY, R, G, B, 255, ourImage.pixels, width);        // setting the colors from the video to our image
      }                                                                       // important to set alpha to 255 
    }
  }
  ourImage.updatePixels();
  image (ourVideo, 0, 0);             // every time around we draw the live video
  image (ourImage, 0, 0);              // and the painted pixels above
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
