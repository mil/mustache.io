#!/usr/bin/env io
Sequence charAt := method(pos, thisContext at(pos) asCharacter)
Sequence isWhiteSpace := method(Sequence whiteSpaceStrings contains(thisContext))
Sequence fromToEnd := method(i, if (i < self size and i > 0, 
	return self exclusiveSlice(i, self size)) nil)

/* Takes in switch statement in form of:
	Sequence switcher((=="matchA", someCode), (=="matchB", someCode), defaultCode) */
Object switcher := method( call message arguments foreach(index, case, 
	if (index != call message arguments size - 1) then (
		result := self doMessage(case arguments at(0))
		if(result, return doMessage(case arguments at(1), call sender) call)
	) else ( return doMessage(case, call sender) call /* Default case */)
))

Mustache := Object clone do(
	delimiters := list("{{", "}}")
	setDelimiters := method(openDelimiter, closeDelimiter,
		( openDelimiter containsSeq(" ") == false and
			openDelimiter containsSeq("=") == false and
			closeDelimiter containsSeq(" ") == false and
			closeDelimiter containsSeq("=") == false
		) ifTrue ( delimiters = list(openDelimiter, closeDelimiter))
	)

	/* Attemps to get the given variable stored in passed object */
	getVariable := method(variable, object,
		slotReturn := object getSlot(variable)
		if (slotReturn != nil, if (slotReturn type == "Block",  "block" , slotReturn ))
	)

	render := method(string, object,
		tokens := List clone
		string := string asMutable	
		position := 0; mustacheStart := nil
		delSize := delimiters at(0) size
		iteratingSection := nil
		iteration := -1

		replacementString := "" asMutable
		/* Loop until we cant find another opening {{ */
		while ((mustacheStart := string findSeq(delimiters at(0), position)) != nil,
			mustacheStart   := mustacheStart + delSize
			mustacheEnd     := string findSeq(delimiters at(1), mustacheStart) - 1
			mustacheCapture := string inclusiveSlice(mustacheStart, mustacheEnd)  \
				                        asMutable strip

			/* Determine the replacement String */
			mustacheCapture charAt(0) switcher(
				(=="!", block( replacementString = "")), 
				(=="#", block(
					/* Start of iterating Section */
					iteratingSection = getVariable(mustacheCapture removeAt(0), object)
					f := string findSeq(delimiters at (0), mustacheEnd)
					while( f != nil,
						capture := string exclusiveSlice( 
							f + delSize + 1, 
							string findSeq(delimiters at(1), f)
						) strip

						/* Found the matching end musetache */
						if (capture fromToEnd(1) == mustacheCapture fromToEnd(1)) then (
							section := string exclusiveSlice(mustacheEnd + delSize + 1, f)
							if (iteratingSection type == "Object") then (
								replacementString = Mustache render(section, iteratingSection)
							) elseif(iteratingSection type == "List") then (
								iteratingSection foreach(iteration,
									replacementString = replacementString .. Mustache render(section, iteration)
								)
							)
							mustacheEnd = f + mustacheCapture size + delSize /* Move end at this will be chopped */
						)
						f = string findSeq(delimiters at (0), f + delSize)
					)	
				)),

				(==".", block( if (mustacheCapture size == 1) then (replacementString = object))), 
				(=="/", block( replacementString = "")),
				(=="^", block( 
					/* Inverted Section */
					invertedSection := getVariable(mustacheCapture removeAt(0), object)
					if (invertedSection == nil or invertedSection == false or invertedSection size == 0) then (
						"This is an inverted section, take no action"
					) else (
						"Inverted section shoudl not be displayed"
						f := string findSeq(delimiters at(0), mustacheEnd)
						while (f != nil,
							capture := string exclusiveSlice( 
								f + delSize + 1, 
								string findSeq(delimiters at(1), f)
							) strip
							if (capture fromToEnd(1) == mustacheCapture fromToEnd(1)) then (
								mustacheEnd = f + mustacheCapture size + delSize
							)

							f = string findSeq(delimiters at(0), f + delSize)
						)
					)	
				)),
				(==">", block( "Partial section" println)),
				(=="&", block( "Unescaped variable" println)),

				block( /* Default -- Variable */
					replacementString = getVariable(mustacheCapture, block(
						if(iteratingSection != nil, iteratingSection, object)) call) asString
				)
			)

			/* Remove the old mustache and pop in new replacement String */
			string := string atInsertSeq(mustacheEnd + delSize + 1, replacementString)
			string := string removeSlice(mustacheStart - delSize, mustacheEnd + delSize)

			position = position + replacementString size 
			replacementString = ""
		)
		string
	)
)
