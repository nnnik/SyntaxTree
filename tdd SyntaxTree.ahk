#Include SyntaxTree.ahk
#Include xmlLoad2.ahk
#Persistent

expressionElement :=syn := loadSyntaxTreeFromXML( "basicMultiLineAssignment.xml" )
Gui, Add, Edit, w600 h600 vOutPut
Gui, Add, Button, gEval, Evaluate
Gui, Show
return
Eval:
Gui, Submit, NoHide
test  := new expressionElement( OutPut )
Msgbox % showcontent( test )
return
GUIClose:
ExitApp

ShowContent( parsedSyntaxTree )
{
	if !isObject( parsedSyntaxTree.content )
		return "[" . parsedSyntaxTree.content . "]"
	s := "["
	For each, element in parsedSyntaxTree.content
		s .= showContent( element ) . ", "
	return SubStr( s, 1, -2 ) . "] "
}