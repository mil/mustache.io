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
	delimiters := list("{{{", "}}}")

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

		/* Loop until we cant find another opening {{ */
		while ((mustacheStart := string findSeq(delimiters at(0), position)) != nil,
			mustacheStart   := mustacheStart + delSize
			mustacheEnd     := string findSeq(delimiters at(1), mustacheStart) - 1
			mustacheCapture := string inclusiveSlice(mustacheStart, mustacheEnd)  \
				                        asMutable strip

			/* Determine the replacement String */
			replacementString := "" asMutable
			mustacheCapture charAt(0) switcher(
				(=="!", "Commented section" println)
				(=="#", "Iterating section" println),
				(=="^", "Inverting section" println),
				(==">", "Partial section" println),
				(=="&", "Unescaped variable" println),
				( replacementString = getVariable(mustacheCapture, object))
			)

			/* Remove the old mustache and pop in new replacement String */
			string := string removeSlice(mustacheStart - delSize, mustacheEnd + delSize) \
											 atInsertSeq(mustacheStart - delSize, replacementString)

			position = position + replacementString size 
		)
		string
	)
)



tmpl := "I am the master template\n
Here's Slot A:<{{slotA}}>\n
And Slot B<{{slotB}}>\n
And slot C<{{slotC}}>"

obj := Object clone do(
	slotA := "Yo I am the dope slot A"
	slotB := "Man, I'm slot B"
	slotC := "I'm C, better than all you slots"
)
