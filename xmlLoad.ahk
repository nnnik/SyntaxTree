#Include SyntaxTree.ahk

loadSyntaxTreeFromXML( fileName )
{
	static xmlObj := ComObjCreate( "Msxml2.DOMDocument.6.0" ), init := ( xmlObj.SetProperty("SelectionLanguage","XPath"), xmlObj.async := false )
	static elementNames := { reg:SyntaxTree.WordElement, alt:SyntaxTree.AlternativeElement, room:SyntaxTree.RoomElement, cons:SyntaxTree.ConsecutiveElement }, stringTypeElements := { reg:1 }
	elementsID := []
	xmlObj.load( fileName )
	queryString := "//reg"
	Loop
	{
		xmlElements := xmlObj.SelectNodes( queryString )
		For element in xmlElements
		{
			if ( elementsID.hasKey( element.attributes.getNamedItem( "id" ).value ) || !element.attributes.getNamedItem( "id" ).value )
				continue
			
			if ( stringTypeElements[ element.nodeName ] )
			{
				elementType := elementNames[ element.nodeName ]
				lastElement := elementsID[ element.attributes.getNamedItem( "id" ).value ] := new elementType( element.text )
			}
			else
			{
				newParams := []
				for childElement in element.childNodes
					newParams.Push( elementsID[ childElement.attributes.getNamedItem( "id" ).value ] )
				elementType := elementNames[ element.nodeName ]
				lastElement := elementsID[ element.attributes.getNamedItem( "id" ).value ] := new elementType( newParams* )
			}
		}
		queryString .= "/.."
	} Until ( xmlElements.length = 1 )
	return lastElement
}