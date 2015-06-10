{
  function node(type, value) {
    return { type: type, value: value };
  }
}

start
  = exprs:Expressions* { return node("Program", exprs) }

Whitespace
  = [ \t]

Digit "Digit"
  = [0-9]

Digits "Digits"
  = digits:Digit+ { return digits.join("") }

Float "Float"
  = float:(("+"/"-")?Digits"."Digits) { return parseFloat(float.join(""), 10) }

Integer "Integer"
  = int:(("+"/"-")?Digits) { return parseInt(int.join(""), 10) }

Number "Number"
  = float:Float { return node("Number", float) }
  / int:Integer { return node("Number", int) }

Alphabet "Alphabet"
  = [a-zA-Z]

Symbol "Symbol"
  = [!@#$%\^&*()\-_=\+\[\]\{\}\|;:'.,<>/?\\`~]

NewLine "NewLine"
  = [\n]

Char "Char"
  = (Alphabet / Digit / Symbol / Whitespace / NewLine)

String "String"
  = "\"" chars:Char* "\"" { return node("String", chars.join("")) }

Boolean "Boolean"
  = "true"  { return node("Boolean", true) }
  / "false" { return node("Boolean", false) }

ReservedWord "ReservedWord"
  = "let"

Identifier "Identifier"
  = !ReservedWord first:("_" / Alphabet) rest:("_" / Alphabet / Digit)* { return node("Identifier", first + rest.join("")) }

Atom "Atom"
  = Number
  / String
  / Boolean
  / Identifier

WhitespaceOrNewLine "WhitespaceOrNewLine"
  = Whitespace
  / NewLine

Argument
  = Atom
  / "(" Whitespace* !AssignmentExpression expr:Expression Whitespace* ")" { return expr }

Arguments "Arguments"
  = Whitespace+ arg:Argument { return arg }

InvocationExpression "InvocationExpression"
  = fn:Identifier args:Arguments* { return node("InvocationExpression", [fn, node("Arguments", args)]) }

Block "Block"
  = "{" WhitespaceOrNewLine* exprs:Expressions* WhitespaceOrNewLine* "}" { return node("Block", exprs) }

RHS "RHS"
  = block:Block { return block }
  / invExpr:InvocationExpression { return invExpr }
  / atom:Atom { return atom }

Identifiers "Identifiers"
  = Whitespace+ id:Identifier { return id }

AssignmentExpression "AssignmentExpression"
  = "let" ids:Identifiers+ Whitespace+ "=" Whitespace* rhs:RHS { return node("AssignmentExpression", [ids, rhs]) }

ArithmeticOperator "ArithmeticOperator"
  = "/"                                                                                                { return node("DivisionOperator", "/") }
  / "*"                                                                                                { return node("MultiplicationOperator", "*") }
  / "+"                                                                                                { return node("AdditionOperator", "+") }
  / "-"                                                                                                { return node("SubtractionOperator", "-") }

LogicalOperator "LogicalOperator"
  = "&&"                                                                                               { return node("AndOperator", "&&") }
  / "||"                                                                                               { return node("OrOperator", "||") }
  / "=="                                                                                               { return node("EqualityOperator", "==") }
  / "!="                                                                                               { return node("InequalityOperator", "!=") }
  / "<="                                                                                               { return node("LTEOperator", "<=") }
  / ">="                                                                                               { return node("GTEOperator", ">=") }
  / "<"                                                                                                { return node("LTOperator", "<") }
  / ">"                                                                                                { return node("GTOperator", ">") }

BinaryOperator "BinaryOperator"
  = ArithmeticOperator
  / LogicalOperator

UnaryLogicalOp "UnaryLogicalOp"
  = "!"

OperatorExpression "OperatorExpression"
  = arg1:Argument Whitespace* binaryOp:BinaryOperator Whitespace* arg2:Argument { return node("OperatorExpression", [arg1, binaryOp, arg2]) }
  / unaryLogicalOp:UnaryLogicalOp expr:(Atom / Expression) { return node("UnaryLogicalOperation", expr) }

IfElseExpression "IfElseExpression"
  = "if" Whitespace* "(" Whitespace* opExpr:(OperatorExpression / Atom)  Whitespace* ")" Whitespace*
  thenBlock:Block Whitespace* "else" Whitespace* elseBlock:Block { return node("IfElseExpression", [opExpr, thenBlock, elseBlock]) }
  / "if" Whitespace* "(" Whitespace* opExpr:(OperatorExpression / Atom)  Whitespace* ")" Whitespace*
  thenBlock:Block { return node("IfElseExpression", [opExpr, thenBlock, null]); }

Expression "Expression"
  = assgnExpr:AssignmentExpression { return assgnExpr }
  / ifExpr:IfElseExpression { return ifExpr }
  / opExpr:OperatorExpression { return opExpr }
  / invExpr:InvocationExpression { return invExpr }
  / atom:Atom { return atom }
  / "(" Whitespace* expr:Expression Whitespace* ")" { return expr }

ExpressionTerminator "ExpressionTerminator"
  = [;\n]

Expressions
  = Whitespace* expr:Expression? Whitespace* ExpressionTerminator Whitespace* { return expr }
