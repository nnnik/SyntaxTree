#Include SyntaxTree.ahk
#Persistent

expressionElement := SyntaxTree.loadFromFile( "classSyntax.xml" )
text := fileOpen( "classSyntax.example", "r" ).Read()
parsed := new expressionElement( text )

s :=  "All the classes and subclasses `ninside classSyntax.example: "
for each, className in parsed.getElementsBySEID( "className" )
	s .= ShowText( className, text ) . ", "
s .= "`nOnly the classes `ninside classSyntax.example: "
for each, sClass in parsed.getChildrenBySEID( "class" )
	s .= ShowText( sClass.getElementBySEID( "className" ), text ) . ", "
s .= "`nAll the methods `ninside classSyntax.example: "
for each, sMethod in parsed.getElementsBySEID( "methodName" )
	s .= ShowText( sMethod, text ) . ", "
Msgbox % s
ExitApp

ShowText( DOMObject, string )
{
	return SubStr( string, start := DOMObject.getStart(), DOMObject.getEnd() - start )
}