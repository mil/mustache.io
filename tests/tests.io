#!/usr/bin/env io
test := method(name, evaluation, expect,
	result := "[31mFAILED[0m"
	if (evaluation == expect, result = "[32mPASS  [0m")
	"#{result} [ #{name} ]" asMutable interpolateInPlace println
	if (result == "[31mFAILED[0m", 
		"\tExpected : #{expect}\n\tEvaluated: #{evaluation}" \
			asMutable interpolateInPlace println
	)
)

runTests := method(	
	doRelativeFile("../lib/mustache.io")
	test("Object: One Variable",
		Mustache render("A single {{var}}", Object clone do(var := "substitution")),
		"A single substitution"
	)
  test("Map: One Variable",
		Mustache render("A single {{var}}", Map clone do(atPut("var","substitution"))),
		"A single substitution"
	)
	
	test("Object: Two Variables",
		Mustache render("Another {{var}} {{var2}}", Object clone do(
			var := "substitution"
			var2 := "sub2"
		)),
		"Another substitution sub2"
	)
	
	test("Map: Two Variables",
		Mustache render("Another {{var}} {{var2}}", Map clone do(
			atPut("var", "substitution")
			atPut("var2", "sub2")
		)),
		"Another substitution sub2"
	)


	
	test("Object: Variable and a Comment",
		Mustache render("Some good ol {{var}}{{!and a comment}}", Object clone do(
			var := "substitution"
		)),
		"Some good ol substitution"
	)

	
	test("Map: Variable and a Comment",
		Mustache render("Some good ol {{var}}{{!and a comment}}", Map clone do(
			atPut("var", "substitution")
		)),
		"Some good ol substitution"
	)

	test("Object: Non-False Values",
		Mustache render("{{#person}}Hi {{name}}!{{/person}}",
			Object clone do(person := Object clone do( name := "Jon"))), 
		"Hi Jon!"
	)


	test("Map: Non-False Values",
		Mustache render("{{#person}}Hi {{name}}!{{/person}}",
			Map clone do(atPut("person", Map clone do( atPut("name", "Jon"))))), 
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

	test("Escaped HTML",
		Mustache render(
      "I am going to escape this {{variable}}",
			Object clone do( variable := "<, >, \", ', /, &")
    ),
    "I am going to escape this &lt;, &gt;, &quot;, &#39;, &#x2F;, &amp;"  
	)

	test("Un-Escaped HTML",
		Mustache render(
      "I am not going to escape this {{&variable}}",
			Object clone do( variable := "<, >, \, ', /, &")
    ),
    "I am not going to escape this <, >, \, ', /, &"
	)

	test("Simple Partials",
		Mustache render(
      "I am a {{ >thing }}",
			Object clone do(
        what := "lamp"
      ),
      Object clone do( thing := "bright {{ what }}" )
    ),
    "I am a bright lamp"  
	)


	test("Iterated Partials",
		Mustache render(
      "{{#people}}I am {{name}} and I {{>action}}... {{/people}}",
			Object clone do(
        people := list(
          Object clone do( name := "Miles"; drink := "coffee" ),
          Object clone do( name := "Wiggles"; drink := "whiskey and gin" )
        )
      ),
      Object clone do( action := "drink {{ drink }}" )
    ),
    "I am Miles and I drink coffee... I am Wiggles and I drink whiskey and gin... "  
	)

	true
)
