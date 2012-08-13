#!/usr/bin/env io
Sequence charAt := method(pos, thisContext at(pos) asCharacter)
Sequence isWhiteSpace := method(Sequence whiteSpaceStrings contains(thisContext))

/* Takes in switch statement in form of:
	Sequence switcher((=="matchA", someCode), (=="matchB", someCode), defaultCode) */
Sequence switcher := method( call message arguments foreach(index, msg, 
	if (index != call message arguments size - 1,
		result := thisContext asString doMessage(msg arguments at(0))
		if(result, doMessage(msg arguments at(1), call sender); break)
	, doMessage(msg, call sender))
))


Mustache := Object clone do(
	delimiters := list("{{", "}}")

	/* Attemps to get the given variable stored in passed object */
	getVariable := method(variable, object,
		/* Defaults to just a variable */
		slotReturn := object getSlot(variable)
		if (slotReturn != nil,
			if (slotReturn type == "Block",  "block" , return slotReturn )
		)			
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
				(=="!", replacementString = ""), /* Commented Section */

				(=="#", 
					/* Start of iterating Section */
					call sender iteratingSection = getVariable(mustacheCapture removeAt(0), object)
					replacementString := ""
				),

				(==".", 
					/* Iteration in iterating section */
					if (mustacheCapture size == 1, 
						("Single iteration off of" .. iteratingSection)  println
						iteration = iteration + 1
						replacementString = iteratingSection at(iteration)
					)
				), 
				(=="/", 
					/* End of iterating section */
					call sender iteratingSection := nil
					call sender iteration = -1
				),

				(=="^", 
					/* Start of inverted section */
					"Inverting section" println),

				(==">", 
					/* Partial Section */
					"Partial section" println),

				(=="&", 
					/* Unescaped variable */
					"Unescaped variable" println),

				(
					/* Default -- Variable */
					replacementString = getVariable(mustacheCapture,
						block(if(iteratingSection != nil, iteratingSection, object)) call)
				)
			)

			/* Remove the old mustache and pop in new replacement String */
			string := string atInsertSeq(mustacheEnd + delSize + 1, replacementString)

			if (iteratingSection != nil and 
				(iteration != iteratingSection size -1) and (iteration != -1)) then (
				"Not reseting the position" println
				continue
			)

			string := string removeSlice(mustacheStart - delSize, mustacheEnd + delSize)
			position = position + replacementString size 
		)
		string
	)
)

tmpl := "
I am a Mustache {{guy}}
I am {{age}} years old
And my favorite color is {{color}}
"
obj  := Object clone do( 
	guy := "Man" 
	age := "32"
	color := "Blue"
)

tmpl2 := "Simple iteration: {{#container}}{{.}}{{/container}}"
obj2  := Object clone do( container := list("first", "second", "third") )
