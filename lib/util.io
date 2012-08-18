#!/usr/bin/env io
Sequence charAt := method(pos, thisContext at(pos) asCharacter)
Sequence fromToEnd := method(i, 
  return (if (i < self size and i > 0,  self exclusiveSlice(i, self size), nil) ))

/* Swaps the keys in the map for the values
Unlike replaceMap() -- does not any replace values of the map itself */
Sequence swapMap := method(map,
  newString := self asMutable
  swapList := list()
  map foreach(key, value, 
    nextSeq := 0; endPosition := 0
    while (nextSeq = findSeq(key, endPosition),
      endPosition = nextSeq + key size
      swapList push(list(nextSeq, key, value))
    )
  )

  swapList = swapList sort
  position := 0
  swapList foreach(replacement,
    position = newString findSeq(replacement at(1), position)
    newString replaceFirstSeq(replacement at(1), replacement at(2), position)
    position = position + replacement at(2) size
  )

  self = newString
)

/* Takes in switch statement in form of:
  Sequence switcher((=="matchA", someCode), (=="matchB", someCode), defaultCode) */
Object switcher := method( call message arguments foreach(index, case, 
  if (index != call message arguments size - 1) then (
    result := self doMessage(case arguments at(0))
    if(result, return doMessage(case arguments at(1), call sender) call)
  ) else ( return doMessage(case, call sender) call /* Default case */)
))


