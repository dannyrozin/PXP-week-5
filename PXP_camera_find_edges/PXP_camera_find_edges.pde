// The world pixel by pixel 2022
// Daniel Rozin
// find edges on a live video
import processing.video.*;

Capture ourVideo;                                 // variable to hold the video object
void setup() {
  size(1280, 720);
  frameRate(120);
  ourVideo = new Capture(this, width, height);    // open the capture in the size of the window
  ourVideo.start();                               // start the video
}

void draw() {
  if (ourVideo.available())  ourVideo.read();      // get a fresh frame as often as we can
  //ourVideo.filter(BLUR,1);                 // blur the video a bit first to get rid of noise
  ourVideo.loadPixels();                     // load the pixels array of the video 
  loadPixels();                              // load the pixels array of the window  
  int edgeAmount = 1;                        // this will do a neighborhood of 9 pixels, 3x3
  for (int x =  edgeAmount; x< width-edgeAmount; x++) {     // we have to make sure we wont 
    for (int y = edgeAmount; y< height-edgeAmount; y++) {  // be accessing pixels outside the bounds of our array
      PxPGetPixel(x, y, ourVideo.pixels, width);          // get the R,G,B of the "our pixel" , the central pixel
      int thisR= R;                                         // place the RGB of our pixel in variables
      int thisG=G;
      int thisB=B;
      float colorDifference=0;
      for (int blurX=x- edgeAmount; blurX<=x+ edgeAmount; blurX++) {     // visit every pixel in the neighborhood
        for (int blurY=y- edgeAmount; blurY<=y+ edgeAmount; blurY++) {
          PxPGetPixel(blurX, blurY, ourVideo.pixels, width);     // get the RGB of our pixel and place in RGB globals
         
          colorDifference+=   dist(R, G, B, thisR, thisG, thisB);        // dist calclates the distance in 3D colorspace beween the center pixel
        }                                                          // and the neighboring pixels and adds to "colorDifference"
      }
      if (colorDifference> mouseX) {
        PxPSetPixel(x, y, 0, 0, 0, 255, pixels, width);    // sets the pixels black
      } else {
        PxPSetPixel(x, y, 255, 255, 255, 255, pixels, width);    // sets the pixels white
      }
    }
  }
  updatePixels();                                    //  must call updatePixels once we're done messing with pixels[]
  println (frameRate);
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
