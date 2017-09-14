#Include SyntaxTree.ahk

testExpressionSyntax := new SyntaxTree.RoomElement( new SyntaxTree.WordElement( "\s*\d+(\.\d+)?" ) , new SyntaxTree.AlternativeElement( new SyntaxTree.WordElement( "\s*\+" ), new SyntaxTree.WordElement( "\s*\-" ) ) )
test  := new testExpressionSyntax( "1  +1" )
test2 := new testExpressionSyntax( "3-4" )