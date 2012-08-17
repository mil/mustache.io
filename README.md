mustache.io - {{ mustache }} logicless templating for Io
========================================================
Like [Mustache](http://mustache.github.com)? Like [Io](http://iolanguage.com)? How about Mustache in Io? I call it `mustache.io`, although I also think the name mustachio would have also been good. I'm not positive that's a real word though.

`mustache.io` is a port of Mustache Templating to the Io Language. mustache.io can be used to render Mustache templates with either Io `Objects` or `Maps`. See `tests/tests.io` or the supported tags section below for all the ways in which `mustache.io` can be used. `mustache.io` is capable of handling nesting of maps within objects, within maps, and any other combination of object and map nesting you might be able to dream of. Ofcourse, you can use just straight maps within maps or objects within objects too.

You may load the `mustache.io` file with `doFile("/path/to/mustache.io")` within your Io program. Once loaded, the Mustache singleton object is available to you. The `Mustache` object may be used as described below in **Usage**.

Usage
-----
### Mustache **render** ***(template, objectOrMap, partialsMapOrObject)***
Renders the given `template` with the provided `objectOrMap`. Takes an *optional argument* of a `partialsMapOrObject`. The provided `template` may be either a `String` or a `File` (which will be read).

With an `Object`:
```
Mustache render("Hey {{man}}", Object clone do( man := "John"))
==> Hey John
```

Or with a `Map`:
```
Mustache render("Hey {{man}}", Map clone do( atPut("man", "John")))
==> Hey John
```

### Mustache **setDelimiters** ***(openDelimiter, closeDelimiter)***
Changes the delimiters from the default `{{ }}` mustaches. The provided delimiters must not contains whitespaces or the = character. Returns true if the delimiters were successfully set or false if not.

```
Mustache setDelimiters("[[", "]]")
==> true
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

### Comments 

**Template**:
```
I am a Mustache Template {{! With a comment that'll never be rendered }}
```

**Object**:
```
Object clone do()
```

Mustache **render**:
```
I am a Mustache Template 
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

Contributing
------------
Feel free to put in an issue or send me a pull request.
