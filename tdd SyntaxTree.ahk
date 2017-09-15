#Include SyntaxTree.ahk

operatorSigns := [ "+", "-", "*", "/" ]


operatorList := [] 
for each, operatorSign in operatorSigns
	operatorList.Push( new SyntaxTree.WordElement( "\s*\" . operatorSign ) )
operatorElement := new SyntaxTree.AlternativeElement( operatorList* )

numberElement := new SyntaxTree.WordElement( "\s*(\+|-)?\d+(\.\d+)?" )
valueElement  := new SyntaxTree.AlternativeElement( numberElement )

expressionElement := new SyntaxTree.RoomElement( valueElement, operatorElement )

bracketElement := new SyntaxTree.RoomElement( valueElement, operatorElement, new SyntaxTree.WordElement( "\s*(\+|\-)?\(" ), new SyntaxTree.WordElement( "\s*\)" ) ) ;Left and right borders
valueElement.addAlternative( bracketElement )

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