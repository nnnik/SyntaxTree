hasClass( obj, classObj )
{
	While obj := obj.base
		if ( classObj = obj )
			return 1
}

isClass( obj, classObj )
{
	return ( obj.base = classObj )
}