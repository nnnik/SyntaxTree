#Include SyntaxTree.ahk

testExpressionSyntax := new SyntaxTree.RoomElement( new SyntaxTree.WordElement( "\s*-?\d+(\.\d+)?" ) , new SyntaxTree.AlternativeElement( new SyntaxTree.WordElement( "\s*\+" ), new SyntaxTree.WordElement( "\s*\-" ), new SyntaxTree.WordElement( "\s*\*" ), new SyntaxTree.WordElement( "\s*\\" ) ) )
test  := new testExpressionSyntax( "1   +2*3\   -1.234123 - 2" )

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