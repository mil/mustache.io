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


	test("Iteration List",
		Mustache render("{{#children}}One of my children is {{.}}\n{{/children}}",
			Object clone do(
				name := "wiggles"
				children := list("wiggleface", "wiggler", "wighton")
			)), 
		"wigglefacewigglerwighton"
	)

	test("Iteration Nest",
		Mustache render("{{#children}}{{name}}{{/children}}",
			Object clone do(
				name := "wiggles"
				children := list("wiggleface", "wiggler", "wighton")
			)), 
		"wigglefacewigglerwighton"
	)





	true
)
