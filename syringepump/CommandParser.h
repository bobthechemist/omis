/*
 * CommandParser is responsible for reading commands from the serial input and
 * determining the validity of the syntax.
 */

/* TODO
 *  Reflect on how to appropriately handle multiple pumps.  Should the number of pumps be the purview of the command parser or the main loop?
 */
#ifndef CommandParser_h
#define CommandParser_h

class CommandParser {
  public:
    CommandParser();

    void read(void); // Called in serialEvent
    void parse(void); // Separate into command and argument(s)
    boolean validate(void); // command completion and sanity checks
    void print(void); // For debugging purposes
    void refresh(void); // Clears command and resets complete flag
    String operation;
    String argument;
    int whichPump; // Indicates which pump the command parser is speaking to

  private:
    
    String command; 
    boolean commandComplete;   

};

#endif
