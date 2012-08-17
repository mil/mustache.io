mustache.io - {{mustache }} logicless templating for Io
=======================================================
Mustache is a logic-less templating system for HTML, config files, anything. Basically Mustache provides a way to cleanly render logic-free templates in a framework agnostic manner. 

**mustache.io** is a port of the Mustache templating to the Io language. mustache.io can be used either with Io Objects or Maps. See `tests/tests.io` for all the ways in which Maps and Objects can be used. **mustache.io** is capable of handling nesting and also Maps within Hashes and visa-versa.

You may load the `mustache.io` file with doFile("/path/to/mustache.io"). Once loaded, the Mustache singleton object is available to you. The Mustache object may 

Usage
-----
### Mustache **render** ***(template, objectOrMap, optionalPartialsObjectOrMap)***
Renders the given template with the provided objectOrMap. If the provided may be either a String or a File.

```
Mustache render("Hey {{man}}", Object clone do( man := "John"))
==> Hey John
```

```
Mustache render("Hey {{man}}", Map clone do( atPut("man", "John")))
==> Hey John
```
### Mustache **setDelimiters** ***(openDelimiter, closeDelimiter)***
Changes the delimiters from the default {{ }} mustaches. The provided delimiters must not contains whitespaces or the = character.

```
Mustache setDelimiters("[[", "]]")
```


Supported Tags
--------------
### Variables

**Template**:
```
"I am {{ name }}, age: {{ age }}"
```

**Object**:
```
Object clone do(
  name := "Miles"
  age  := 20 
)
```

Mustache **render**:
```
I am Miles and I am 20
```

### Sections

**Template**:
```
I am {{ name }} and I like: {{ #likes }}{{.}}, {{ /likes }}
```

**Object**:
```
Object clone do(
  name  := Miles
  likes := list("coffee", "granola", "beer")
)
```

Mustache **render**:
```
I am Miles and I like: coffee, granola, beer
```

### Inverted Sections

**Template**:
```
My interests include: {{#interests}}.{{/interests}}{{^interests}}Absolutely Nothing!!!!{{/interests}}
```

**Object**:
```
Object clone do(
  interests := list()
)
```

Mustache **render**:
```
My interests include: Absolutely Nothing!!!!
```

### Partials

**Template**:
```
{{#people}}
I am {{name}} and I {{>action}}...
{{/people}}
```

**Object**:
```
Object clone do(
  people := list(
    Object clone do(
      name := "Miles"; drink := "coffee"
    ),
    Object clone do(
      name := "Wiggles"; drink := "whiskey and gin"
    )
  )
)
```

**Partials Object**:
```
Object clone do(
  action := "drink {{ drink }}"  
)
```

Mustache **render**:
```
I am Miles and I drink coffee...
I am Wiggles and I drink whiskey and gin...
```

