#Include OOPFunctions.ahk

class SyntaxTree
{
	
	static debug := 0
	
	static elementNames := { opt: SyntaxTree.OptionalElement, val:SyntaxTree.ValueElement, nval:SyntaxTree.notValueElement, range:SyntaxTree.RangeElement, nrange:SyntaxTree.notRangeElement, alt:SyntaxTree.AlternativeElement, room:SyntaxTree.RoomElement, cons:SyntaxTree.ConsecutiveElement, null:SyntaxTree.ValidElement }
	
	loadFromFile( fileName )
	{
		static xmlObj := ComObjCreate( "Msxml2.DOMDocument.6.0" ), init := xmlObj.async := false
		xmlObj.load( fileName )
		
		definedList:= {}
		elementsID := {}
		
		xmlElementLayers  := []
		elementLayers     := []
		indexLayers       := []
		
		xmlElement     := xmlObj.documentElement.childNodes.item( 0 )
		
		Loop
		{
			
			if !( ( elementID := xmlElement.attributes.getNamedItem( "id" ).value ) && elementsID.hasKey( elementID ) )
			{
				elementBase := This.elementNames[ xmlElement.nodeName ]
				element := new elementBase()
				if ( elementID )
					elementsID[ elementID ] := element
			}
			else
				element := elementsID[ elementID ]
				;create a new undefined element if it doesn't exist yet otherwise load it from array
			
			if ( A_Index > 1 )
				elementLayers.1.getParseData()[ indexLayers.1 ] := element
			else
				baseElement := element
				;add current element to it's parent
			
			if !( ( elementId && definedList[ elementID ] ) || ( hasClass( element, This.ContainerElement ) ? !xmlElement.childNodes.length : !xmlElement.text ) )
			{
				;If the current element is not a reference read it's definition here
				
				xmlElementAttributes := xmlElement.attributes
				Loop % xmlElementAttributes.length()
				{
					attribute := xmlElementAttributes.item( A_Index-1 )
					if hasCalleable( element,  "set" . attribute.name )
						element[ "set" . attribute.name ].call( element, attribute.value )
				}
				;load element attributes
				
				if ( !isClass( element, This.ValidElement ) ) ;if an element is not a null element
				{
					if ( hasClass( element, This.ContainerElement ) ) ;check if an element is a container element
					{
						xmlElementLayers.insertAt( 1, xmlElement )
						elementLayers.insertAt( 1, element )
						indexLayers.insertAt( 1, 0 )
					;if so push it onto the evaluation stack so that it's children will be the next that get evaluated
					}
					else
						element.getParseData().1 := xmlElement.text ;otherwise define a text element
					
				}
				if ( elementID )
					definedList[ elementID ] := 1 ;set an element as defined
			}
			
			While !( ( ++indexLayers.1 - 1 ) < xmlElementLayers.1.childNodes.length )
			{
				;If the current parent element is fully evaluated
				
				xmlElementLayers.removeAt( 1 )
				elementLayers.removeAt( 1 )
				indexLayers.removeAt( 1 )
				;go upwards in the hierachy until you find an unevaluated one
				
				if !elementLayers.length()
					return baseElement
				;and if the top of the hierachy is reached return the highestmost 
			}
			xmlElement := xmlElementLayers.1.childNodes.item( indexLayers.1 -1 )
			;Go to the next element
		}
	}
	
	class ValidElement
	{
		
		__New( parseData* )
		{
			This.parseData := parseData
			This.__New := This.matchStart
			This.init()
		}
		
		getEnd()
		{
			return This.end
		}
		
		getStart()
		{
			return This.start
		}
		
		getContent()
		{
			return This.content
		}
		
		matchStart( mString, startPos := 1, parent := "" )
		{
			This.end     := This.start := startPos
			This.match( mString )
			This.errors := []
			This.parent := parent
		}
		
		pushError( AdditionalInfo )
		{
			If ( !SyntaxTree.debug )
			{
				;Msgbox % This.__Class . "`n" . This.id . "`n" . AdditionalInfo "`nat " This.getEnd()
				Throw exception( "Parsing Error", This.__Class, "Error at Position:" . This.getEnd() . " " . AdditionalInfo )
			}
			else
				This.errors.Push( exception( "Parsing Error", This.__Class, "Error at Position:" . This.getEnd() . " " . AdditionalInfo ) )
		}
		
		hasErrors()
		{
			return !!This.errors.Length()
		}
		
		isEmpty()
		{
			return ( This.getEnd() = This.getStart() )
		}
		
		getParseData()
		{
			return This.parseData
		}
		
		setID( id := "" )
		{
			This.id := id
		}
		
		getID()
		{
			return This.id
		}
		
		getParentBySEID( SEID )
		{
			parent := This
			While isObject( parent := parent.getParent() )
				if ( parent.getID() = SEID )
					return parent
		}
		
		getParent()
		{
			return This.parent
		}
	}
	
	class ContainerElement extends SyntaxTree.ValidElement
	{
		
		matchStart( mString, startPos := 1, parent := "" )
		{
			This.end := This.start := startPos
			This.errors := []
			This.content := []
			This.match( mString )
			This.parent := parent
		}
		
		tryPush( element, mString )
		{
			try 
			{
				em := new element( mString, This.getEnd(), This )
				if ( isObject( em ) && hasClass( element, SyntaxTree.validElement ) && !em.hasErrors() )
				{
					This.directPush( em )
					return 1
				}
			}
			catch e
				This.collectError( element, e )
			if ( isObject( em ) )
				This.collectErrors( em )
			return 0
		}
		
		directPush( element )
		{
			if ( SyntaxTree.debug || !element.isEmpty() ) 
			{
				This.content.push( element )
				This.end := element.getEnd()
			}
			if ( removed && element.getEnd() > This.getEnd() )
				This.end := element.getEnd()
		}
		
		getElementsBySEID( SEID )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			results 		:= []
			if !IsObject( SEID )
				SEID := [ SEID ]
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return results
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( SEID, element.getID() ) )
					results.push( element )
				if ( hasClass( element, SyntaxTree.ContainerElement ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}
		
		getElementBySEID( SEID )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			if !IsObject( SEID )
				SEID := [ SEID ]
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return 
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( SEID, element.getID() ) )
					return element
				if ( hasClass( element, SyntaxTree.ContainerElement ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}
		
		getChildrenBySEID( childSEID, parentSEID := "" )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			results 		:= []
			if !IsObject( childSEID )
				childSEID := [ childSEID ]
			if !IsObject( parentSEID )
				parentSEID := parentSEID ? [ parentSEID ] : []
			parentSEID.Push( This.getID() )
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return results
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( childSEID, element.getID() ) )
					results.push( element )
				else if ( hasClass( element, SyntaxTree.ContainerElement ) && !hasValue( parentSEID, element.getID() ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}
		
		getChildBySEID( childSEID, parentSEID := "" )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			if !IsObject( childSEID )
				childSEID := [ childSEID ]
			if !IsObject( parentSEID )
				parentSEID := parentSEID ? [ parentSEID ] : []
			parentSEID.Push( This.getID() )
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return 
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( childSEID, This.getID() ) )
					return element
				else if ( hasClass( element, SyntaxTree.ContainerElement ) && !hasValue( element.getID(), parentSEID ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}
		
	}
	
	class ValueElement extends SyntaxTree.ValidElement
	{	
		
		;__New( value )
		
		match( mString )
		{
			pString := subStr( mString, This.getStart(), strLen( This.parseData.1 ) )
			if ( This.getCaseSensitive() ? pString == This.parseData.1 : pString = This.parseData.1 )
			{
				This.end     := This.getStart() + strLen( This.parseData.1 )
				This.content := pString
			}
			else
				This.pushError( "Value doesn't match" )
		}
		
		setCaseSensitive( value := 0 )
		{
			This.caseSensitive := value
		}
		
		getCaseSensitive()
		{
			return This.caseSensitive
		}
		
	}
	
	class notValueElement extends SyntaxTree.ValueElement
	{
		
		;__New( value )
		
		match( mString )
		{
			pString := subStr( mString, This.getStart(), strLen( This.parseData.1 ) )
			if ( !( This.getCaseSensitive() ? pString == This.parseData.1 : pString = This.parseData.1 ) )
			{
				This.end     := This.getStart() + strLen( char := Chr( Ord( SubStr( pString, 1, 2 ) ) ) )
				This.content := char
			}
			else
				This.pushError( "Value doesn't match" )
		}
	}
	
	class RangeElement extends SyntaxTree.ValidElement
	{
		
		;__New( "0-9a-zA-Z_" ) similar to RegExMatchs []
		
		static groups := { "\r": [ "`r`n", "`r", "`n" ], "\s": [" ", "`t"] }
		static caseSensitive := 1
		
		
		between( min, max, mString, start )
		{
			val := Ord( SubStr( mString, start, 2 ) ) ;potential multi code unit encoding
			return ( ( val >= min ) && ( val <= max ) )
		}
		
		inGroup( grp, mString, start )
		{
			val := SubStr( mString, start, 1 )
			if ( This.getCaseSensitive() )
			{
				for each, grpVal in grp
				{
					if ( 1 = len := strLen( grpVal ) )
					{
						if ( val == grpVal )
							return 1
					}
					else
						if ( subStr( mString, start, len ) == grpVal )
							return 1
				}
			}
			else
				for each, grpVal in grp
				{
					if ( 1 = len := strLen( grpVal ) )
					{
						if ( val = grpVal )
							return 1
					}
					else
						if ( subStr( mString, start, len ) = grpVal )
							return 1
				}
			return 0
		}
		
		match( mString )
		{
			pStr := This.parseData.1
			pos  := 1
			singleCharGrp := []
			While ( pos <= strLen( pStr ) )
			{
				pos += strLen( char := Chr( Ord( SubStr( pStr, pos, 2 ) ) ) )
				if ( char = "\" )
				{
					pos += strLen( char2 := Chr( Ord( SubStr( pStr, pos, 2 ) ) ) )
					if ( isObject( grp := This.groups[ char . char2 ] ) )
					{
						if ( This.inGroup( grp, mString, This.getStart() ) )
							return This.foundMatch( mString )
						continue
					}
					else
						char := char2
				}
				if ( subStr( pStr, pos, 1 ) = "-" )
				{
					pos += 1
					if ( subStr( pStr, pos, 1 ) = "\" )
						pos += 1
					pos += strLen( Chr( ord2 := Ord( SubStr( pStr, pos, 2 ) ) ) )
					if ( This.between( ord( char ), ord2, mString, This.getStart() ) )
						return This.foundMatch( mString )
					continue
				}
				singleCharGrp.Push( char )
			}
			if ( This.inGroup( singleCharGrp, mString, This.getStart() ) )
				return This.foundMatch( mString )
			This.noMatchFound( mString )
		}
		
		foundMatch( mString )
		{
			This.end := This.getStart() + StrLen( This.content := Chr( Ord( subStr( mString, This.getStart(), 2 ) ) ) )
		}
		
		noMatchFound( mString )
		{
			This.pushError( "Value out of range" )
		}
		
		setCaseSensitive( value := 1 )
		{
			This.caseSensitive := value
		}
		
		getCaseSensitive()
		{
			return This.caseSensitive
		}
		
	}
	
	class notRangeElement extends SyntaxTree.RangeElement
	{
		
		;__New( "0-9a-zA-Z_" ) similar to RegExMatchs [^]
		
		static noMatchFound := SyntaxTree.RangeElement.foundMatch
		static foundMatch   := SyntaxTree.RangeElement.noMatchFound
		
	}
	
	
	class RoomElement extends SyntaxTree.ContainerElement
	{
		
		;__New( body, [seperator, padding, leftBorder, rightBorder )]
		
		static min := 1
		
		match( mString )
		{
			if ( isObject( This.parseData.4 ) && !isClass( This.parseData.4, SyntaxTree.ValidElement ) )
				if ( !This.tryPush( This.parseData.4, mString ) )
				{
					This.pushError( "Missing left Border" )
					return
				}
			contentCount := 0
			if ( isObject( This.parseData.2 ) && !isClass( This.parseData.2, SyntaxTree.ValidElement ) )
			{
				This.pushPadding( mString )
				if This.tryPush( This.parseData.1, mString )
				{
					contentCount++
					While ( This.pushPadding( mString ) && This.tryPush( This.parseData.2, mString ) )
					{
						if !( This.pushPadding( mString ) && This.tryPush( This.parseData.1, mString ) )
						{
							This.pushError( "Sperator without following Content" )
							return
						}
						else
							contentCount++						
					}
				}
			}
			else
				While ( This.pushPadding( mString ) && This.tryPush( This.parseData.1, mString ) )
					contentCount++
			This.pushPadding( mString )
			if isObject( This.parseData.5 )
				if ( !This.tryPush( This.parseData.5, mString ) )
				{
					This.pushError( "Missing right Border" )
					return
				}
			if ( This.getMin() && contentCount < This.getMin() )
				This.pushError( "Room too small" )
			else if ( This.getMax() && contentCount > This.getMax() )
				This.pushError( "Room too large" )
		}
		
		pushPadding( mString )
		{
			if ( isObject( This.parseData.3 ) && !isClass( This.parseData.3, SyntaxTree.ValidElement ) )
			{
				res := This.tryPush( This.parseData.3, mString ) 
				;Msgbox % """" subStr( mString, This.getEnd(), 1 ) """" . "`n" . res . "`n" . disp( This.parseData.3 )
			}
			return 1
		}
		
		setMin( min := "" )
		{
			This.min := min
		}
		
		setMax( max := "" )
		{
			This.max := max
		}
		
		getMin()
		{
			return This.min
		}
		
		getMax()
		{
			return This.max
		}
		
	}
	
	class AlternativeElement extends SyntaxTree.ContainerElement
	{
		;__New( alternatives* )
		
		match( mString )
		{
			for each, alternative in This.parseData
				if This.tryPush( alternative, mString )
					return
			This.pushError( "No match" )
		}
		
	}
	
	class ConsecutiveElement extends SyntaxTree.ContainerElement
	{
		;__New( consecutiveElements* )
		
		match( mString )
		{
			for each, follower in This.parseData
				if !This.tryPush( follower, mString )
					This.pushError( "Missing Element" )
		}
		
	}
	
	class OptionalElement extends SyntaxTree.ConsecutiveElement
	{
		
		;__New( consecutiveElements* )
		
		static min := 0
		
		match( mString )
		{
			for each, follower in This.parseData
				if !This.tryPush( follower, mString )
				{
					if ( each <= This.getMin() )
						This.pushError( "Missing Element" )
					else
						return
				}
		}
		
		getMin()
		{
			return This.min
		}
		
		setMin( min )
		{
			This.min := min
		}
		
	}
}