#Include SyntaxTree.ahk
#Persistent

expressionElement := SyntaxTree.loadFromFile( "classSyntax.xml" )
parsed := new expressionElement( text := fileOpen( "classSyntax.example", "r" ).Read() )
for each, className in parsed.getChildrenBySEID( "class" )
	Msgbox % ShowText( className.getElementBySEID( "className" ), text )
ExitApp

ShowText( DOMObject, string )
{
	return SubStr( string, start := DOMObject.getStart(), DOMObject.getEnd() - start )
}

ShowContent( parsedSyntaxTree )
{
	if !isObject( parsedSyntaxTree.content )
		return "[" . parsedSyntaxTree.content . "]"
	s := "["
	For each, element in parsedSyntaxTree.content
		s .= showContent( element ) . ", "
	return SubStr( s, 1, -2 ) . "] "
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