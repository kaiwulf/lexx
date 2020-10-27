// cmd.g4
grammar Cmd;

// Tokens
// NEW: 'new';
MUL: '*' ;
DIV: '/' ;
ADD: '+' ;
SUB: '-' ;
NUMBER: [0-9]+;
WHITESPACE: [ \r\n\t]+ -> skip;
VAR: [a-zA-Z];

// Rules
start: 
    command
    | expression EOF;


command
    : op=('new') VAR;

expression
   : expression op=('*'|'/') expression # MulDiv
   | expression op=('+'|'-') expression # AddSub
   | NUMBER                             # Number
   ;
