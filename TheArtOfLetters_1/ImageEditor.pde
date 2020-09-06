// version 1.3 -- see update info starting @ line 83.
// September 19, 2016
// author: Harlan Howe

/**
   Summary of methods in ImageEditor
   =>There are six ways you can create a new ImageEditor: you can give it ...
       • an existing PImage,
       • an existing ImageEditor (not in "Editing Mode"), of which you want a copy,
       • a filename (which will load this graphics file),
       • a width & height (which will create an opaque, blank image),
       • a width & height & color (which will create an blank image with the color), or
       • an (x, y, w, h) rectangle, which will copy the contents of the current window into a new ImageEditor.
       
     For example, you might say:
       ImageEditor editor = new ImageEditor("picture.jpg");
       or
       ImageEditor editor = new ImageEditor(600,600,new color(128,0,255));

  =>You can ask an ImageEditor for its width() or for its height()
  
  =>You can ask the ImageEditor to resize the main window to the size of this picture, or a multiple of the size of the picture:
    For example, if the image is (320 x 240) you might say
        editor.resizeWindowToImage();  // this would make the window be (320 x 240)
          or
        editor.resizeWindowToImage(2,1); // this would make the window be (640 x 240)
  
  =>You can have the ImageEditor draw its image onto the main window with its upper-left corner at a specific coordinate:
        editor.drawAt(0,0);
    This only works when you are NOT in "Editing Mode."
        
  =>You can set the ImageEditor into "Editing Mode" - this is the mode in which you can read and write pixel data, but you cannot
    draw while you are in this mode.
        editor.startEditing();
        editor.stopEditing();
    (I suggest you indent your code between start and stop.)    
    You can also ask whether it is in "Editing Mode."
        if (editor.isEditing())
            println("In editing mode.");

  =>In "Editing Mode," you can ask for color information for a given pixel:
       •editor.getRedAt(x,y); // returns a number 0-255
       •editor.getGreenAt(x,y); // returns a number 0-255
       •editor.getBlueAt(x,y); // returns a number 0-255
       •editor.getAlphaAt(x,y); // returns a number 0-255
       •editor.getColorAt(x,y); // returns a huge "color" number (0 - 4,294,967,295) that represents the full RGB value.
                                // this large color number is the sort of thing you get when you say "new color(255,128,0)"
       (also can say redAt(x,y), greenAt(x,y), blueAt(x,y), alphaAt(x,y), colorAt(x,y)...)
       
  =>In "Editing Mode," you can change the color information for a given pixel:
       •editor.setRedAt(r,x,y);
       •editor.setGreenAt(g,x,y);
       •editor.setBlueAt(b,x,y);
       •editor.setAlphaAt(a,x,y);
       •editor.setColorAt(c,x,y);

  =>In any mode, you can ask whether a given set of coordinates fits within the size of this PImage:
       •if (editor.inBounds(x,y))
           println("Yep, it's in bounds.");

  =>If you are not in "Editing Mode," you can ask for the PImage in this ImageEditor.
       •PImage imageCopy = editor.getImage();

  =>If you are not in "Editing Mode," you can ask for this ImageEditor to save its PImage
       as a file. The filename you give it determines the graphics format. I think you could use .jpg, .gif, .tif, or .png.
       •editor.save("myCoolerFile.png");
       
  =>If you are not in "Editing Mode," you can ask the this ImageEditor to give you a new
       ImageEditor that consists of a portion of the image in this Image editor, based on
       (x, y, w, h) - relative to this ImageEditor's internal coordinates. If you choose 
       values for the image that are out of bounds for the picture, you will get black for
       the extra areas; or if you add a "true" to the end of the parameters, you get
       transparent at the out-of-bounds areas.
       • ImageEditor smallIE = editor.subArea(100,-100,500,30);
           //there will be a black bar across the top of this image (at least), since that part
           //is clearly be out of bounds
        or
       • ImageEditor tinyIE = editor.subArea(-50,0,editor.width(),editor.height(),true);
           //There will be a 50px wide transparent area on the left edge of the image, at least.
           //    The image will be the same size as the original, but the right edge will be cropped.
*/

/**
    What's new in version 1.3
       • fixed "error" in setRedAt(), setGreenAt(), setBlueAt() 
            - the resulting images had wound up semi-transparent.
       • Fixed inconsistency with "colorAt()" vs. "getRedAt()." Now you can use
           either colorAt() or getColorAt() syntax - they both work for color, red, green, 
           blue or alpha
       • added setAlphaAt() and getAlphaAt() methods.
       • added save() method
       • added constructor that takes another ImageEditor (not in edit mode) to make a copy
       • added subArea() method that returns an IE containing a portion of this one's image.
*/

//-------------------------------------------------------------- Class starts here!
class ImageEditor
{
  int myWidth, myHeight, myNumPixels;
  PImage myImage;
  color[] myPixels;
  boolean isEditing;

  /**
  * loads the given filename and creates an imageEditor of it.
  * @param the name of the file holding an image that we should use.
  */
  ImageEditor(String filename)
  {
     this(loadImage(filename));  
  }

  /**
  * creates an ImageEditor of specified (width,height) that starts off blank - using ARGB format.
  * @param width - the width of the blank image created.
  * @param height  the height of the blank image created.
  */
  ImageEditor(int width, int height)
  {
     this(width,height,color(0,0,0)); 
  }
  
  /**
  * creates an ImageEditor of specified (width,height) that starts off filled with color c - using ARGB format.
  * @param width - the width of the blank image created.
  * @param height - the height of the blank image created.
  * @param color - which color goes in each pixel (but alpha will be full opaque.)
  */
  ImageEditor(int width, int height, color c)
  {
     this(createImage(width,height,ARGB));
     startEditing();
     for (int x = 0; x<width; x++)
       for (int y = 0; y<height; y++)
         setColorAt(changeAlphaInColor(c,255),x,y);
     stopEditing();
  }
  
  
  /*
  * creates an ImageEditor of specified (w, h) that is filled with content from the screen,
  * using the rectangular section (startX, startY, w, h) as the source of that content.
  * Note: the rectangular section must fall within the confines of the screen.
  */
  ImageEditor(int startX, int startY, int w, int h)
  {
     this(w,h);
     if (startX+w>width || startY+h>height)
       throw new RuntimeException("Attempted to create image with rectangular data from ("+
                                   startX+", "+startY+") to ("+(startX+w)+", "+(startY+h)+
                                   "), but the screen is only "+width+" x "+height+" pixels.");
     loadPixels();
     startEditing();
     for (int y = 0; y<h; y++)
        for( int x = 0; x<w; x++)
          setColorAt(pixels[(startX+x)+width*(startY+y)], x,y);
     stopEditing();
     updatePixels();
  }  
  
  /**
  * creates an ImageEditor with a <i>copy</i> of the specified image, starting off out of editing mode.
  * @param inImage - the image to copy and use.
  */
  ImageEditor(PImage inImage)
  {
      if (inImage == null)
      {
        throw new RuntimeException("Attempted to create an ImageEditor with a null image.");
      }
    myImage = createImage(inImage.width,inImage.height,ARGB);
    myImage.copy(inImage,0,0,inImage.width,inImage.height,0,0,inImage.width,inImage.height);
    myWidth = myImage.width;
    myHeight = myImage.height;    
    myNumPixels = myWidth * myHeight;
    isEditing = false;
  }
  /**
  * creates an ImageEditor with a <i>copy</i> of the image in the given ImageEditor. 
  * precondition: The given ImageEditor must <i>not</i> be in "Editing Mode."
  * @param IE2Copy - the ImageEditor to copy and use.
  */
  ImageEditor(ImageEditor IE2Copy)
  {
     this(IE2Copy.getImage());
  }
  
  int width()
  {   return myWidth; }
  
  int height()
  {   return myHeight; }
  
  boolean isEditing()
  {   return isEditing; }
  
  
  /**
  * enter "editing mode" - you can now read and manipulate pixel data, but you
  * cannot draw the image until you exit this mode.
  */
  void startEditing()
  {
     if (!isEditing)
     {
       myImage.loadPixels();
       myPixels = myImage.pixels;
       isEditing = true;
     }
  }
  
  
  /**
  * exit "editing mode" - you can no longer read or manipulate pixel data,
  * but you can now draw the image.
  */
  void stopEditing()
  {
    if (isEditing)
    {
      myImage.updatePixels();
      isEditing = false;
    }
  }
  
  
  /**
  * indicates whether the given point is within this image.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  boolean inBounds(int x, int y)
  {
    return (x>=0) && (x<myWidth) && (y>=0) && (y<myHeight);
  }
  
  /**
  * returns the pixel color value at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the color of the pixel at (x,y)
  */
  color getColorAt(int x, int y)
  {
    if (!isEditing)
      throw new RuntimeException("Attempted to get pixel data at ("+x+", "+y+") but image is not in editing mode.");
    if (!inBounds(x,y))
      throw new RuntimeException("Attempted to get pixel data at ("+x+", "+y+") but this must fall between (0,0) and ("+(myWidth-1)+", "+(myHeight-1)+"), inclusive.");
    return myPixels[x+myWidth*y];
  }
  color colorAt(int x, int y) { return getColorAt(x,y);}
  /**
  * returns the red value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the red of the pixel at (x,y)
  */
  int getRedAt(int x, int y)
  {
    return getRedForColor(colorAt(x,y));
  }
  int redAt(int x, int y) {return getRedAt(x,y);}
  
    /**
  * returns the green value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the green of the pixel at (x,y)
  */
  int getGreenAt(int x, int y)
  {
    return getGreenForColor(colorAt(x,y));
  }
  int greenAt(int x, int y) { return getGreenAt(x,y);}
  
  /**
  * returns the blue value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the blue of the pixel at (x,y)
  */
  int getBlueAt(int x, int y)
  {
    return getBlueForColor(colorAt(x,y));
  }
  int blueAt(int x, int y) {return getBlueAt(x,y);}
  
  
  /**
  * returns the alpha value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the alpha of the pixel at (x,y)
  */
  int getAlphaAt(int x, int y)
  {
    return getAlphaForColor(colorAt(x,y));
  }
  int alphaAt(int x, int y){return getAlphaAt(x,y);}
  
  
  
  /**
  * updates the red portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the redness (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setRedAt(int val, int x, int y)
  {
     setColorAt(changeRedInColor(colorAt(x,y),val), x, y); 
  }
  
  /**
  * updates the green portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the greenness (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setGreenAt(int val, int x, int y)
  {
     setColorAt(changeGreenInColor(colorAt(x,y),val), x, y); 
  }
  /**
  * updates the blue portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the blueness (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setBlueAt(int val, int x, int y)
  {
     setColorAt(changeBlueInColor(colorAt(x,y),val), x, y); 
  }
  
    /**
  * updates the alpha portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the alpha (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setAlphaAt(int val, int x, int y)
  {
     setColorAt(changeAlphaInColor(colorAt(x,y),val), x, y); 
  }
  
  /**
  * updates the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the color to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setColorAt(color c, int x, int y)
  {
    if (!isEditing)
      throw new RuntimeException("Attempted to set pixel data at ("+x+", "+y+") but image is not in editing mode.");
    if (!inBounds(x,y))
      throw new RuntimeException("Attempted to set pixel data at ("+x+", "+y+") but this must fall between (0,0) and ("+(myWidth-1)+", "+(myHeight-1)+"), inclusive.");
    myPixels [x+myWidth*y] = c;
  }

  /**
  * draws the image at the given (x,y) location.
  * Note: this throws an exception (i.e., crashes) if we are in editing mode.
  * @param x - the x-coordinate in the current Matrix where the upper-left image of the image will start.
  * @param y - the y-coordinate in the current Matrix where the upper-left image of the image will start.
  */
  void drawAt(int x, int y)
  {
     if (isEditing)
       throw new RuntimeException("Attempted to draw image while in \"Editing Mode.\"");
     image(myImage,x,y);  
  }
  
  void save(String filename)
  {
     myImage.save(filename); 
  }
  
  /**
  * returns a copy of the PImage used in this ImageEditor; further edits to this ImageEditor will
  * not affect the copy returned.
  * @return a copy of the PImage currently used in this ImageEditor. 
  */
  PImage getImage()
  {
    if (isEditing)
       throw new RuntimeException("Attempted to grab image from Image Editor while in \"Editing Mode.\"");
    PImage tempImage = createImage(myWidth, myHeight,ARGB);
    tempImage.copy(myImage,0,0,myWidth,myHeight,0,0,myWidth,myHeight);
    return tempImage;
    
  }

  /**
  * changes the size of the main window to match that of the PImage used in this ImageEditor.
  */  
  void resizeWindowToImage()
  {
     surface.setSize(myWidth,myHeight); 
  }
  
  /**
  * changes the size of the main window to a multiple of the width and height of this ImageEditor's PImage.
  * @param mx - the integer multiplier for x
  * @param my - the integer multiplier for y
  * precondition: mx and my are both >= 1.
  */
  void resizeWindowToImage(int mx, int my)
  {
    surface.setSize(myWidth*max(1,mx), myHeight*max(1,my));

  }
  
  ImageEditor subArea(int x, int y, int w, int h)
  {
    return subArea(x,y,w,h,false);
  }
  
  ImageEditor subArea(int x, int y, int w, int h, boolean transparentBorder)
  {
    if (isEditing)
       throw new RuntimeException("Attempted to grab subArea from Image Editor while in \"Editing Mode.\"");
    
    int xMax = min(myWidth,x+w);
    int yMax = min(myHeight, y+h);
    int xMin = max(0, x);
    int yMin = max(0, y);
    println (xMax,yMax,xMin,yMin);
    ImageEditor result = new ImageEditor(w,h,color(0,0,0,0));
    this.startEditing();
    result.startEditing();
      if (transparentBorder)
        for (int y3 = 0; y3 < h; y3++)
          for (int x3 = 0; x3<w; x3++)
            result.setAlphaAt(0, x3,y3);
      for (int yy = yMin; yy < yMax; yy++)
          for (int xx = xMin; xx < xMax; xx++)
          {
              int destX = xx-x;
              int destY = yy-y;
              //println ("            ",destX,destY);
              result.setColorAt(this.colorAt(xx,yy), destX, destY);
          }  
          
    result.stopEditing();
    this.stopEditing();
    return result;
  }
  
  /********************************************************************************************************
  * THE MATERIAL PAST THIS POINT IS USED BY OTHER METHODS IN THIS CLASS. YOU DO NOT NEED TO WORRY ABOUT IT.
  * PLEASE DO NOT CHANGE IT.
  */
  
  final int ALPHA_BIT_SHIFT = 24;
  final int RED_BIT_SHIFT = 16;
  final int GREEN_BIT_SHIFT = 8;
  final int BLUE_BIT_SHIFT = 0;
  final int ALL_ONES = 0xFFFFFFFF;
  
  int getRedForColor(color c)
  {
    return getBitsAtShift(c,RED_BIT_SHIFT);
  }
  
  int getGreenForColor(color c)
  {
    return getBitsAtShift(c,GREEN_BIT_SHIFT);
  }
  
  int getBlueForColor(color c)
  {
    return getBitsAtShift(c,BLUE_BIT_SHIFT);
  }
  
  int getAlphaForColor(color c)
  {
    return getBitsAtShift(c,ALPHA_BIT_SHIFT);
  }
  
  int getBitsAtShift(color c, int shift)
  {
    return (c & (255<<shift)) >> shift;
  }
  
  color setByteAtShift(color c, int val, int shift)
  {
     return ((val & 255)<<shift) | (c & (ALL_ONES - (255<<shift))); 
  }
  color changeRedInColor(color c, int val)
  {
    return ((val & 255)<<RED_BIT_SHIFT) | (c &(ALL_ONES - (255<<RED_BIT_SHIFT)));
  }
  color changeGreenInColor(color c, int val)
  {
    return ((val & 255)<<GREEN_BIT_SHIFT) | (c &(ALL_ONES - (255<<GREEN_BIT_SHIFT)));
  }
  color changeBlueInColor(color c, int val)
  {
    return ((val & 255)<<BLUE_BIT_SHIFT) | (c &(ALL_ONES - (255<<BLUE_BIT_SHIFT)));
  }
  color changeAlphaInColor(color c, int val)
  {
    return ((val & 255)<<ALPHA_BIT_SHIFT) | (c &(ALL_ONES - (255<<ALPHA_BIT_SHIFT)));
  }
  
  
}
