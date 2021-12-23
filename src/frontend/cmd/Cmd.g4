// cmd.g4
grammar Cmd;

// Fragments
fragment N      : ('n') ;
fragment E      : ('e') ;
fragment W      : ('w') ;
fragment DIGIT  : [0-9];


// Tokens
MUL: '*' ;
DIV: '/' ;
ADD: '+' ;
SUB: '-' ;
NEW: N E W ;
NWE: N W E ;    // place holder
NUMBER: DIGIT+ ([.,] DIGIT+)? ;
WHITESPACE: [ \r\n\t]+ -> skip;
NEWLINE : ('\r'? '\n' | '\r')+ ;
VAR: [a-zA-Z];

// Rules
start: 
    line+ EOF;

line: (command | expression | prefix | fun | NEWLINE)+;

command
    : NEW VAR;

expression
   : expression op=('*'|'/') expression # MulDiv
   | expression op=('+'|'-') expression # AddSub
   | op=('*'|'/') expression expression # MulDivPre
   | op=('+'|'-') expression expression # AddSubPre
   | NUMBER                             # Number
   ;

fun
    : VAR '(' VAR ')';

prefix
//    : op=('*'|'/') expression expression # MulDivPre
//    | op=('*'|'/') expression expression # AddSubPre
//    | NUMBER                             # Number
    : NWE
    ;