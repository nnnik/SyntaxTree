#Include SyntaxTree.ahk
#Persistent

expressionElement := SyntaxTree.loadFromFile( "classSyntax.xml" )
text := fileOpen( "classSyntax.example", "r" ).Read()
parsed := new expressionElement( text )
for each, className in parsed.getChildrenBySEID( "className", "class" )
	Msgbox % ShowText( className, text )
ExitApp

ShowText( DOMObject, string )
{
	return SubStr( string, start := DOMObject.getStart(), DOMObject.getEnd() - start )
}