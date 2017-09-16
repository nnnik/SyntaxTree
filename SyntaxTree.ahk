#Include OOPFunctions.ahk

class SyntaxTree
{
	
	static debug := 0
	
	class ValidElement
	{
		
		__New( parseData* )
		{
			This.parseData := parseData
			This.__New := This.matchStart
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
		
		matchStart( mString, startPos := 1 )
		{
			This.end     := This.start := startPos
			This.match( mString )
			This.errors := []
		}
		
		pushError( AdditionalInfo )
		{
			If ( !SyntaxTree.debug )
				Throw exception( "Parsing Error", This.__Class, "Error at Position:" . This.getEnd() . " " . AdditionalInfo )
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
	}
	
	class ContainerElement extends SyntaxTree.ValidElement
	{
		
		matchStart( mString, startPos := 1 )
		{
			This.end     := This.start := startPos
			This.errors := []
			This.content := []
			This.match( mString )
		}
		
		tryPush( element, mString )
		{
			try 
			{
				em := new element( mString, This.getEnd() )
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
			if ( SyntaxTree.debug || removed := !isClass( element, SyntaxTree.validElement ) ) 
			{
				This.content.push( element )
				This.end := element.getEnd()
			}
			if ( removed && element.getEnd() > This.getEnd() )
				This.end := element.getEnd()
		}
	}
	
	class WordElement extends SyntaxTree.ValidElement
	{	
		
		;__New( RegEx )
		
		match( mString )
		{
			if ( RegExMatch( mString, "O)" . This.parseData.1, matchObject, This.getStart() ) = This.getStart() )
			{
				This.start   := This.getStart()
				This.end     := This.getStart() + matchObject.Len( 0 )
				This.content := matchObject[ 0 ]
			}
			else
				This.pushError( "Unmatching RegEx" )
		}
	}
	
	class RoomElement extends SyntaxTree.ContainerElement
	{
		
		;__New( body, seperator, leftBorder, rightBorder )
		
		match( mString )
		{
			if isObject( This.parseData.3 )
				if ( !This.tryPush( This.parseData.3, mString ) )
					This.pushError( "Missing left Border" )
			if isObject( This.parseData.2 )
			{
				if This.tryPush( This.parseData.1, mString )
					While This.tryPush( This.parseData.2, mString )
						if !This.tryPush( This.parseData.1, mString )
							This.pushError( "Sperator without following Content" )
			}
			else
				While ( This.tryPush( This.parseData.1, mString ) )
					continue
			if isObject( This.parseData.4 )
				if ( !This.tryPush( This.parseData.4, mString ) )
					This.pushError( "Missing right Border" )
			if This.isEmpty()
				This.pushError( "Empty Room" )
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
		
		addAlternative( element )
		{
			This.parseData.push( element )
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
}