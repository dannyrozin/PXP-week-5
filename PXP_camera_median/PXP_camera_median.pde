// The world pixel by pixel 2020
// Daniel Rozin
// median a live video
import processing.video.*;

Capture ourVideo;                                 // variable to hold the video object
void setup() {
  size(1280, 720);
  frameRate(120);
  ourVideo = new Capture(this, width, height);    // open the capture in the size of the window
  ourVideo.start();                               // start the video
  noFill();
}

void draw() {
  if (ourVideo.available())  ourVideo.read();      // get a fresh frame as often as we can
   ourVideo.filter(GRAY);                          // median really works only in grayscale
  image(ourVideo,0,0);                            // we will be bluring just a circle of pixels, so draw the whole video to the screen
  ourVideo.loadPixels();                     // load the pixels array of the video 
  loadPixels();                              // load the pixels array of the window  
  int blurAmount = 3;                        // change this to make the effect more pronounced
  int divider=  (2*blurAmount+1)*(2*blurAmount+1);       // calculating how many pixels will be in the neighborhood of our pixel
  for (int x = max(mouseX-100, blurAmount); x<min(mouseX+100, width-blurAmount); x++) {     // looping 100 pixels around the mouse, we have to make sure we wont 
    for (int y = max(mouseY-100, blurAmount); y<min(mouseY+100, height-blurAmount); y++) {  // be accessing pixels outside the bounds of our array
     if (dist(mouseX, mouseY, x, y)< 100) {                       // lets just do a circle radius 100
        int[] pixArray= new int[0];                                     // create an empty array of ints
        for (int blurX=x- blurAmount; blurX<=x+ blurAmount; blurX++) {     // visit every pixel in the neighborhood
          for (int blurY=y- blurAmount; blurY<=y+ blurAmount; blurY++) {
            PxPGetPixel(blurX, blurY, ourVideo.pixels, width);     // get the RGB of our pixel and place in RGB globals
            int pixBrightness= (R+G+B)/3;                          // add the brightness of each pixel into the aray
            pixArray= append(pixArray,pixBrightness);
          }
        }
        pixArray=sort(pixArray);                                  // sort the array 
        int newValue = pixArray[pixArray.length/2];               // get the median of the array (middle value of)
        PxPSetPixel(x, y, newValue,newValue,newValue, 255, pixels, width);    // sets the R,G,B values to the window
      }
    }
  }
  updatePixels();                                    //  must call updatePixels oce were done messing with pixels[]
  ellipse (mouseX, mouseY, 200,200);                  // draw a circle to show the affected area as its a bit subtle
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
