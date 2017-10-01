#Include SyntaxTree.ahk
#Persistent

Gui, Add, Edit, w600 h600 vOutPut, 1+1
Gui, Add, Button, gEval, Evaluate
selectFile := ""
Loop, Files,% A_ScriptFullPath . "\..\*.xml"
	selectFile .= ( firstFile ? A_LoopFileName : firstFile := A_LoopFileName ) . "|"
Gui, Add, DropDownList, gSelect vParseMode, % SubStr( selectFile, 1, -1 )
GuiControl,Choose , ParseMode, 4
Gui, Show
GoSub, Select
return
Eval:
Gui, Submit, NoHide
Msgbox % ShowParsedSyntaxTree( new expressionElement( OutPut ) )
return
GUIClose:
ExitApp
Select:
GUI, Submit, NoHide
expressionElement := new SyntaxTree( ParseMode )
;Msgbox % ShowSyntaxTreeStructure( expressionElement )
return

ShowParsedSyntaxTree( parsedSyntaxTree )
{
	return ShowContent( parsedSyntaxTree.document )
}

ShowContent( parsedSyntaxTree )
{
	if !hasClass( parsedSyntaxTree, SyntaxTree.ContainerElement )
		return parsedSyntaxTree.getText()
	s := "["
	For each, element in parsedSyntaxTree.content
		s .= showContent( element ) . ", "
	return SubStr( s, 1, -2 ) . "] "
}

ShowSyntaxTreeStructure( syntaxTree )
{
	return ShowStructure( syntaxTree.parseData )
}

ShowStructure( parsedSyntaxTree )
{
	static instances := 0, objList := {}, typeList := {}
	instances++
	if ( !id := objList[ &parsedSyntaxTree ] )
	{
		if ( parsedSyntaxTree.getID() )
			id := parsedSyntaxTree.getID()
		else
		{
			regExMatch( parsedSyntaxTree.__class, "\.(\w+)Element", out )
			if !typeList.hasKey( out1 )
				typeList[out1] := 0
			id := out1 . "." . ++typeList
		}
		objList[ &parsedSyntaxTree ] := id
	}
	s := id . "`t:"
	if !isObject( parsedSyntaxTree.parseData.1 )
		s .= """" . parsedSyntaxTree.parseData.1 . """`n"
	else
	{
		a := []
		for each, element in parsedSyntaxTree.parseData
		{
			if ( !id := objList[ &element ] )
			{
				if ( element.getID() )
					id := element.getID()
				else
				{
					regExMatch( element.__class, "\.(\w+)Element", out )
					if !typeList.hasKey( out1 )
						typeList[out1] := 0
					id := out1 . "." . ++typeList[out1]
				}
				objList[ &element ] := id
				a.Push( ShowStructure( element ) )
			}
			s .= " " . id
		}
		s .= "`n"
		for each, entry in a
			s .= entry
	}
	if ( --instances = 0 )
		objList := {}, typeList := {}
	return s
}