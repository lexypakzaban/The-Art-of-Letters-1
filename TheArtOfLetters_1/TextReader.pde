class TextReader
{
  //Version 1.2.0
  //Written by Harlan Howe
  /**
  *  A class for reading text from a .txt file.... It loads the text into memory and then keeps track
  *  of a "pointer" - the TextReader object can take requests for the "next" Letter, Word, or Line; 
  *  the pointer is where the next selection of text will begin, and it automatically advances 
  *  after each request.
  *  Consider a file with the following text:
  >        Redo the Right Thing
  >        by Spike Mulligan
  >        starring Weird Al Yankovich
  *  The following lines would generate the following results:
  *  TextReader tr = new TextReader(<the filename>);
  *  tr.nextLetter() --> "R"
  *  tr.nextLetter() --> "e"
  *  tr.nextWord()   --> "do"
  *  tr.nextWord()   --> "the"
  *  tr.nextLine()   --> "Right Thing"
  *  tr.nextLetter() --> "b"
  *  tr.nextLetter() --> "y"
  *  tr.nextLetter() --> " "
  *  tr.nextLetter() --> "S"
  *  tr.nextWord()   --> "pike"
  *  tr.nextWord()   --> "Mulligan"
  *  tr.nextWord()   --> "starring"
  *  tr.nextLetter() --> "W"
  *  tr.nextLine()   --> "eird Al Yankovich"
  *  tr.nextWord()   --> null
  */
  String[] lines;
  int currentLine, currentIndex;
  /**
  *  builds a text reader from a .txt file in the project folder.
  */
  TextReader(String filename)
  {
     lines = loadStrings(filename); //Note: loadStrings creates an array of strings, one for each line of text.
     if (lines == null)
     {
       println("I could not open \""+filename+".\" Are you sure you have the file name correct?");
       throw new RuntimeException("Could not open file: \""+filename+".\"");
     }
     currentLine = 0;
     currentIndex = 0;
  } 
  
  /**
  * builds a text reader from a String and a "delimiter" - that is a string that will be used to divy up the main string into parts.
  * Typically, this might be a "\n" character, but for the purpose of demonstration:
  *    TextReader TR = new TextReader("Eenie*Meenie*Minie*Moe","*") 
  * would become a text reader based on an array of strings: ["Eenie","Meenie","Minie","Moe"].
  */
  TextReader(String content, String delimiter)
  {
    lines = content.split(delimiter);
    currentLine = 0;
    currentIndex = 0;
  }
  
  /**
  * builds a text reader from an exisiting array of Strings
  */
  TextReader(String[] array)
  {
    lines = array;
    currentLine = 0;
    currentIndex = 0;
  }
  
  /**
  * returns whether this text reader has run out of space.
  */ 
  boolean isAtEnd()
  {
    return (currentLine == lines.length) || (currentLine == lines.length-1 && currentIndex == lines[lines.length-1].length());
  }
  
  /**
  * returns whether this text reader has additional content to provide.
  */
  boolean hasMore()
  {
    return ! isAtEnd(); // the "!" here means "not"
  }
  
  /**
  *  returns the next letter (or other non-space, non-return character) in the file, advancing the
  *  pointer forward by one notch.
  *  If the file is at an end, returns null.  
  */
  String nextLetter()
  {
     if (isAtEnd())
       return null;
     if (currentIndex<lines[currentLine].length())
     {
        currentIndex++;
        return lines[currentLine].substring(currentIndex-1,currentIndex); 
     }
     currentLine++;
     currentIndex = 0;
     return nextLetter();
  }
  
  /**
  * returns the remainder of the line, advancing the pointer to the start of the next line.
  * If the file is at an end, returns null.
  */
  String nextLine()
  {
    if (isAtEnd())
      return null;
    if (currentIndex<lines[currentLine].length())
    {
       String output = lines[currentLine].substring(currentIndex);
       currentLine++;
       currentIndex = 0;
       return output; 
    }
    currentLine++;
    currentIndex = 0;
    return nextLine();
  }
  
  /**
  * returns the next sequence of non-space, non-return characters, not including the space. 
  * Advances the pointer to the next non-space, non-return character.
  * If the file is at an end, returns null.
  */
  String nextWord()
  {
    if (isAtEnd())
      return null;
    if (currentIndex == lines[currentLine].length())
    {  currentIndex=0;
       currentLine++;
       return nextWord();
    }
    int nextSpace = lines[currentLine].indexOf(" ",currentIndex);
    if (nextSpace ==-1)
      return nextLine();
    String output = lines[currentLine].substring(currentIndex,nextSpace);
    currentIndex = nextSpace+1;
    while (currentIndex < lines[currentLine].length() && lines[currentLine].substring(currentIndex,currentIndex+1).equals(" "))
      currentIndex++;
    if (currentIndex == lines[currentLine].length())
    {
      currentIndex = 0;
      currentLine++;
    }
    return output;
  }
  
  /**
  * sets the pointer back to the beginning of the text.
  */ 
  void resetToStart()
  {
    currentIndex =0;
    currentLine = 0;
  }
  
  /**
  * sets the pointer back to the beginning of the text.
  */
  void reset()
  {
    resetToStart(); // this is just a simple wrapper for resetToStart().
  }
}
