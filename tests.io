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

	test("Non-False Values",
		Mustache render("{{#person}}Hi {{name}}!{{/person}}",
			Object clone do(person := Object clone do( name := "Jon"))), 
		"Hi Jon!"
	)

	test("Iteration List",
		Mustache render("I am {{name}} and here are my children:\n{{#children}}Mr.{{.}}!!!\n{{/children}}",
			Object clone do(
				name := "Wiggles"
				children := list("Wiggleface", "Wiggler", "Wighton")
			)), 
		"I am Wiggles and here are my children:\nMr.Wiggleface!!!\nMr.Wiggler!!!\nMr.Wighton!!!\n"
	)

	test("Iteration List with Object Nest",
		Mustache render("I am {{name}} and here are my children:\n{{#children}}I'm Mr.{{surname}}, {{age}}!\n{{/children}}",
			Object clone do(
				name := "Wiggles"
				children := list(
					Object clone do(
						surname := "Wiggleface"
						age := 14	
					), 
					Object clone do(
						surname := "Wiggler"
						age := 24
					),
					Object clone do(
						surname := "Wighton"
						age := 18
					)
				)
			)), 
		"I am Wiggles and here are my children:\nI'm Mr.Wiggleface, 14!\nI'm Mr.Wiggler, 24!\nI'm Mr.Wighton, 18!\n"
	)


	test("Inverted Section - Nil Reference",
		Mustache render("Is this section {{^section}}empty?{{/section}}",
			Object clone do()), 
		"Is this section empty?"
	)


	test("Inverted Section - List Unpopulated",
		Mustache render("Is this section {{^section}}empty?{{/section}}",
			Object clone do(section := list())), 
		"Is this section empty?"
	)

	test("Inverted Section - List Populated",
		Mustache render("Is this section {{^section}}empty?{{/section}}",
			Object clone do(section := list("a", "b", "c"))), 
		"Is this section "
	)





	true
)
