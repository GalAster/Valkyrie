grammar La;
import LaOperator;
// $antlr-format useTab false ;reflowComments false;
// $antlr-format alignColons hanging;
program: statement* EOF;
statement
    : emptyStatement
    | literalStatement eos?
    | expressionStatement eos?
    | assign_statement eos?;
/*====================================================================================================================*/
emptyStatement: eos;
eos: Semicolon;
symbol: Identifier (DOT Identifier)*;
/*====================================================================================================================*/
literalStatement: Number | String | Identifier;
/*====================================================================================================================*/
expressionStatement: expression (COMMA expression)*;
// High computing priority in the front
expression
    : op = prefix_ops right = expression                                  # PrefixExpression
    | left = expression op = postfix_ops                                  # PostfixExpression
    | left = symbol op = DOT right = expression                           # MethodApply
    | function_apply                                                      # FunctionApply
    | Number right = expression                                           # SpaceOperator
    | left = expression op = left_ops right = expression                  # LeftOperator
    | <assoc = right> left = expression op = right_ops right = expression # RightOperator
    | <assoc = right> id = assign_lhs op = assign_ops expr = assignable   # AssignOperator
    | data = listLiteral                                                  # List
    | left = expression data = indexLiteral                               # Index
    | data = dictLiteral                                                  # Dict
    | atom = literalStatement                                             # Literal
    | atom = symbol                                                       # SymbolExpression
    | '(' expression ')'                                                  # PriorityExpression;
/*====================================================================================================================*/
function_apply: symbol function_curry+;
function_curry: '(' function_params? ')';
function_params: expression (COMMA expression)*;
/*====================================================================================================================*/
assign_statement
    : id = assign_lhs expr = assignable # AssignStatement;
assignable: expression;
assign_lhs
    : Identifier                    # AssignValue
    | Identifier (DOT Identifier)+  # AssignAttribute
    | Identifier '(' Identifier ')' # AssignFunction
    | Identifier '[' Integer ']'    # AssignWithList;
assign_pass: Tilde | symbol;
/*====================================================================================================================*/
listLiteral
    : '{' element (COMMA? element)* COMMA? '}' # LiteralList
    | '{' COMMA? '}'                           # EmptyList;
indexLiteral: '[' index_valid (COMMA? index_valid)+? ']';
dictLiteral
    : '{' keyValue (COMMA keyValue)* COMMA? '}' # LiteralDict
    | '{' Colon '}'                             # EmptyDict;
keyValue
    : key = validKey Colon value = element     # NormalKey
    | key = Identifier Colon value = element   # SymbolKey
    | Power key = symbol Colon value = element # RawKey;
// $antlr-format alignColons trailing;
validKey      : Number | String | raw;
raw           : 'Raw' '(' text = String ')';
element       : (expression | dictLiteral | listLiteral | raw);
index_valid   : (symbol | Integer) Colon?;
signedInteger : (Plus | Minus)? Integer;
//FIXME: replace NUMBER with signedInteger
/*====================================================================================================================*/
LineComment                : Shebang ~[\r\n]* -> channel(HIDDEN);
PartComment                : Comment .*? Comment -> channel(HIDDEN);
WhiteSpace                 : UnicodeWhiteSpace+ -> skip;
NewLine                    : ('\r'? '\n' | '\r')+ -> skip;
String                     : SimpleString;
Identifier                 : NameStartCharacter NameCharacter*;
Number                     : Float | Integer;
Float                      : Digit+ Dot Digit* | Dot Digit+;
Integer                    : Digit+;
fragment Digit             : [0-9];
fragment OctalDigit        : [0-7];
fragment HexDigit          : [0-9a-fA-F];
fragment Letter            : [a-zA-Z];
fragment UnicodeWhiteSpace : [\p{White_Space}];
fragment SimpleString      : DoubleQuotation .*? DoubleQuotation;
fragment EmojiCharacter    : [\p{Emoji}];
fragment NameCharacter     : NameStartCharacter | Digit;
/*====================================================================================================================*/
// $antlr-format alignColons hanging;
prefix_ops
    : Plus
    | Minus
    | BitNot
    | LogicNot
    | Reciprocal
    | Increase;
postfix_ops: Increase;
left_ops
    : Plus
    | Minus
    | LeftShift
    | RightShift
    | LogicAnd
    | LogicNot
    | LogicOr
    | LogicXor
    | Equal
    | NotEqual
    | Equivalent
    | NotEquivalent
    | Grater
    | GraterEqual
    | Less
    | LessEqual
    | LogicAnd
    | LogicOr
    | Divide
    | Times
    | Multiply
    | Kronecker
    | TensorProduct
    | Concat
    | LeftShift
    | RightShift;
right_ops: Power | Surd;
assign_ops
    : Assign
    | PlusTo
    | MinusFrom
    | LetAssign
    | FinalAssign
    | DelayedAssign;
fragment NameStartCharacter
    : Dollar
    | [\p{Latin}]
    | [\p{Han}]
    | [\p{Hiragana}]
    | [\p{Katakana}]
    | [\p{Greek}];
//UNICODE_ID : [\p{General_Category=Other_Letter}]*; May Allow # $ % with special meaning English +
// Chinese + Japanese + Greeks
