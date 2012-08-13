#!/usr/bin/env io
test := method(name, evaluation, expect,
	result := "FAILED"
	if (evaluation == expect, result = "PASS")
	"#{result} [Test: #{name}]" asMutable interpolateInPlace println
	if (result == "FAILED", 
		"\tExpected : #{expect}\n\tEvaluated: #{evaluation}" \
			asMutable interpolateInPlace println
	)
)

runTests := method(	
	doFile("mustache.io")
	test("One Variable",
		Mustache render("A single {{var}}", Object clone do(var := "substitution")),
		"A single substitution"
	)

	
	test("Two Variables",
		Mustache render("Another {{var}} {{var2}}", Object clone do(
			var := "substitution"
			var2 := "sub2"
		)),
		"Another substitution sub2"
	)

	
	test("Variable and a Comment",
		Mustache render("Some good ol {{var}}{{!and a comment}}", Object clone do(
			var := "substitution"
		)),
		"Some good ol substitution"
	)




	test("Iteration List",
		Mustache render("I am {{name}} and here are my children:\n{{#children}}Mr.{{.}}!!!\n{{/children}}",
			Object clone do(
				name := "Wiggles"
				children := list("Wiggleface", "Wiggler", "Wighton")
			)), 
		"I am Wiggles and here are my children:\nMr.Wiggleface!!!\nMr.Wiggler!!!\nMr.Wighton!!!\n"
	)

	true
)
