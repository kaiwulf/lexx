grammar CAS;

options {
    language=Go;
}

program
    : command* EOF
    ;

command
    : expression NEWLINE
    | EXIT NEWLINE
    | QUIT NEWLINE
    | HELP NEWLINE
    | NEWLINE
    ;

expression
    : INT LBRACK expression RBRACK                      // integral expr
    | DIFF LBRACK expression RBRACK                     // differential expr
    | FUNC LPAREN expression RPAREN                     // function expr
    | SETOP LPAREN expression ',' expression RPAREN     // set operation expr
    | expression POW expression                         // power expr
    | expression (MULT | DIV) expression                // mult/div expr
    | expression (PLUS | MINUS) expression              // add/sub expr
    | LPAREN expression RPAREN                          // paren expr
    | MINUS expression                                  // negative expr
    | atom                                              // atom expr
    ;

atom
    : number
    | VAR
    | CONST
    ;

number
    : INTEGER
    | DECIMAL
    ;

EXIT    : 'exit' | 'EXIT';
QUIT    : 'quit' | 'QUIT';
HELP    : 'help' | 'HELP';
INT     : 'int';
DIFF    : 'diff';

SETOP   : 'union' | 'intersection' | 'compliment' | 'difference';

VAR     : [a-z];

CONST   : 'pi' | 'e' | [a-z][0-9];

INTEGER     : [0-9]+;
DECIMAL     : [0-9]+ . [0-9]+;

PLUS    : '+';
MINUS   : '-';
MULT    : '*';
DIV     : '/';
POW     : '^';

LPAREN  : '(';
RPAREN  : ')';
LBRACK  : '[';
RBRACK  : ']';

NEWLINE     : [\r\n]+;
WS          : [ \t]+ -> skip;