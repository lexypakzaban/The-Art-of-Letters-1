TextReader myTR;
ImageEditor myIE;
PFont wordFont;
float letter_x;
float letter_y;
float y;
float x;

//https://www.chicagotribune.com/news/local/breaking/ct-homer-simpson-live-pizza-debate-met-0517-20160516-story.html

void setup()
{
  size (400,400);
  //myTR = new TextReader("DaveBarry.txt");
  myTR = new TextReader("D'oh","\n");
  myIE = new ImageEditor("homer.jpg");
  wordFont = createFont("sans-serif",10);
  textFont(wordFont);
  myIE.resizeWindowToImage(1,1);
  letter_x = 0;
  letter_y = 10;
  y=10;
  x=0;
  background(0);
}

void draw()
{ 
  myIE.startEditing();
  
  int r = myIE.getRedAt(int(x),int(y));
  int g = myIE.getGreenAt(int(x),int(y));
  int b = myIE.getBlueAt(int(x),int(y));
    
  fill(r,g,b);
  
  String letter = myTR.nextLetter();
  x = x + textWidth(letter);
  
  if(myTR.isAtEnd())
  {
    myTR.resetToStart();
  }
  if(x>400)
  {
    x = 0;
    y = y + 10;
  }
  
  if(y > 513)
  {
    noLoop();
  }
  
  if(letter_x < 400)
  {
    //String letter = myTR.nextLetter();
    text(letter,letter_x,letter_y);
    letter_x = letter_x + textWidth(letter);
  }
  
  else
  {
    letter_x = 0;
    letter_y = letter_y + 10;
    //String letter = myTR.nextLetter();
    text(letter,letter_x,letter_y);
    letter_x = letter_x + textWidth(letter);
  }
  
  myIE.stopEditing();
  save("resultInWindow.png");
}
