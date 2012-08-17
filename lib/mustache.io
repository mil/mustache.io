#!/usr/bin/env io
Sequence charAt := method(pos, thisContext at(pos) asCharacter)
Sequence fromToEnd := method(i, 
  return (if (i < self size and i > 0,  self exclusiveSlice(i, self size), nil) ))

/* Takes in switch statement in form of:
  Sequence switcher((=="matchA", someCode), (=="matchB", someCode), defaultCode) */
Object switcher := method( call message arguments foreach(index, case, 
  if (index != call message arguments size - 1) then (
    result := self doMessage(case arguments at(0))
    if(result, return doMessage(case arguments at(1), call sender) call)
  ) else ( return doMessage(case, call sender) call /* Default case */)
))

Mustache := Object clone do(
  delimiters := list("{{", "}}"); delSize := delimiters at(0) size 
  clone := method(self) /* Singleton */

  escapeHtml := method(string,
    string := string asMutable replaceMap(Map clone do(
      atPut("<" , "&lt;"  )
      atPut(">" , "&gt;"  )
      atPut("\"", "&quot;")
      atPut("'" , "&#39;" )
      atPut("/" , "&#x2F;")
      atPut("&" , "&amp;" )
    ))
  )
  
  /* Change the delimiters used for render */
  setDelimiters := method(openDelimiter, closeDelimiter,
    ( openDelimiter containsSeq(" ") == false and
      openDelimiter containsSeq("=") == false and
      closeDelimiter containsSeq(" ") == false and
      closeDelimiter containsSeq("=") == false
    ) ifTrue ( 
      delimiters = list(openDelimiter, closeDelimiter)
      delSize    = delimiters at(0) size
    )
  )

  /* Attemps to get the given variable stored in passed object */
  getVariable := method(variable, objectOrMap,
    returnValue := nil
    if (objectOrMap type == "Map") then (  
      returnValue = objectOrMap at(variable)
    ) elseif (objectOrMap type == "Object") then (
      returnValue = objectOrMap getSlot(variable)
    )

    return (if (returnValue,
      returnValue (if(returnValue type == "Block", call, nil)), nil
    ))
  )

  getMustache := method(start, string,
    start = start + delSize + 1
    string exclusiveSlice(start, string findSeq(delimiters at(1), start)) strip
  )

  renderSection := method(sectionName, startPosition, parentObject, partials, string,
    replacementString := ""

    /* Start of iterating Section */
    iteratingSection := getVariable(sectionName removeAt(0), parentObject)
    f := string findSeq(delimiters at (0), startPosition)
    while( f != nil,
      mustacheEndMatch := getMustache(f, string)

      /* Found the matching end musetache */
      if (mustacheEndMatch fromToEnd(1) == sectionName fromToEnd(1)) then (
        section := string exclusiveSlice(startPosition + delSize + 1, f)
        if (iteratingSection type == "Object" or
            iteratingSection type == "Map") then ( iteratingSection = list(iteratingSection) )
        if(iteratingSection type == "List")    then ( iteratingSection foreach(iteration,
            replacementString = replacementString .. Mustache render(section, iteration, partials)
        ))
        startPosition = f + sectionName size + delSize /* Move end at this will be chopped */
      )
      f = string findSeq(delimiters at (0), f + delSize)
    ) 

    return list(replacementString, startPosition)
  )


  render := method(string, object, partials,
    string := string asMutable  
    position := 0; sliceStart := nil
    replacementString := "" asMutable 
    /* Loop until we cant find another opening {{ */
    while ((sliceStart := string findSeq(delimiters at(0), position)),
      sliceStart   := sliceStart + delSize
      sliceEnd     := string findSeq(delimiters at(1), sliceStart) - 1
      mustacheCapture := string inclusiveSlice(sliceStart, sliceEnd)  \
                                asMutable strip

      /* Determine the replacement String */
      mustacheCapture charAt(0) switcher(
        (=="!", block( replacementString = "")), 
        (=="#", block( 
          ret := renderSection(mustacheCapture, sliceEnd, object, partials, string) 
          replacementString = ret at(0)
          sliceEnd = ret at(1)
        )),

        (==".", block( if (mustacheCapture size == 1) then (replacementString = escapeHtml(object)))), 
        (=="/", block( replacementString = "")),
        (=="^", block( 
          (
            list(nil, list()) contains( 
            getVariable(mustacheCapture removeAt(0), object)) 
          ) ifFalse (
            nextMustacheOpen := string findSeq(delimiters at(0), sliceEnd)
            while (nextMustacheOpen,
              (getMustache(nextMustacheOpen, string) fromToEnd(1) == 
               mustacheCapture fromToEnd(1)) ifTrue (
                sliceEnd = nextMustacheOpen + mustacheCapture size + delSize;
                break;
              )
              nextMustacheOpen = string findSeq(delimiters at(0), nextMustacheOpen + delSize)
            )
          )
        )),
        (==">", block( 
          if (partials) then (
            replacementString = getVariable(mustacheCapture removeAt(0), partials) asString
          ) 
        )),
        (=="&", block(
          replacementString = getVariable(mustacheCapture removeAt(0), object) asString
          
        
        )),

        block( /* Default -- Variable */
          replacementString = escapeHtml(getVariable(mustacheCapture, object) asString)
        )
      )

      /* Remove the old mustache and pop in new replacement String */
      string = string atInsertSeq(sliceEnd + delSize + 1, replacementString) \
                      removeSlice(sliceStart - delSize, sliceEnd + delSize)
      /* Advance the position */
      position = position + replacementString size; replacementString = ""
    )
    string /* Return */
  )
)
