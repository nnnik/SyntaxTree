#Include SyntaxTree.ahk
#Include xmlLoad2.ahk

expressionElement :=syn := loadSyntaxTreeFromXML( "testSyntax.xml" )
InputBox, TestExpression, Please input a mathematical expression, Please input a mathematical expression 
test  := new expressionElement( TestExpression )
Msgbox % showcontent( test )

ShowContent( parsedSyntaxTree )
{
	if !isObject( parsedSyntaxTree.content )
		return "[" . parsedSyntaxTree.content . "]"
	s := "["
	For each, element in parsedSyntaxTree.content
		s .= showContent( element ) . ", "
	return SubStr( s, 1, -2 ) . "] "
}