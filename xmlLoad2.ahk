#Include SyntaxTree.ahk


loadSyntaxTreeFromXML( fileName )
{
	static xmlObj := ComObjCreate( "Msxml2.DOMDocument.6.0" ), init := ( xmlObj.SetProperty("SelectionLanguage","XPath"), xmlObj.async := false )
	static elementNames := { reg:SyntaxTree.WordElement, alt:SyntaxTree.AlternativeElement, room:SyntaxTree.RoomElement, cons:SyntaxTree.ConsecutiveElement }, stringTypeElement := { reg:1 }
	
	xmlObj.load( fileName )
	
	
	definedList:= {}
	elementsID := {}
	mentions   := {}
	
	xmlElement     := xmlObj.documentElement.childNodes.item( 0 )
	elementType := elementNames[ xmlElement.nodeName ]
	
	xmlElementLayers  := [ xmlElement ]
	elementLayers     := [ baseElement := new elementType() ]
	indexLayers       := [ 0 ]
	
	Loop
	{
		While !( ( ++indexLayers.1 - 1 ) < xmlElementLayers.1.childNodes.length )
		{
			xmlElementLayers.removeAt( 1 )
			elementLayers.removeAt( 1 )
			indexLayers.removeAt( 1 )
			if !elementLayers.length()
				return baseElement
		}
		xmlElement := xmlElementLayers.1.childNodes.item( indexLayers.1 -1 )
		;Go along structure
		
		if !elementsID.hasKey( elementID := xmlElement.attributes.getNamedItem( "id" ).value )
		{
			elementBase := elementNames[ xmlElement.nodeName ]
			elementsID[ elementID ] := new elementBase()
		}
		element := elementsID[ elementID ]
		;Set up element if it doesn't exist
		
		elementLayers.1.getParseData()[ indexLayers.1 ] := element
		;add current element to it's parent
		
		if ( definedList[ elementID ] || ( stringTypeElement[ xmlElement.nodeName ] && !xmlElement.text ) || ( !stringTypeElement[ xmlElement.nodeName ] && !xmlElement.childNodes.length ) )
			continue
		;If the current element is a mention don't try to read the definition here
		
		if ( stringTypeElement[ xmlElement.nodeName ] )
			element.getParseData().1 := xmlElement.text ;define a text element
		else
		{
			xmlElementLayers.insertAt( 1, xmlElement )
			elementLayers.insertAt( 1, element )
			indexLayers.insertAt( 1, 0 )
			;push a container element onto the evaluation stack so that it's children will be the next that get evaluated
		}
		definedList[ elementID ] := 1
	}
}