mustache.io - {{mustache }} logicless templating for Io
=======================================================
Mustache is a logic-less templating system for HTML, config files, anything. Basically Mustache provides a way to cleanly render logic-free templates in a framework agnostic manner. This is a port of Mustache to the Io language.

Usage
-----
**mustache.io** can be used either with Io Objects or Maps.

```
Mustache render("Hey {{man}}", Object := clone do( man := "John"))
==> Hey John
```

The Mustache Object
-------------------
Mustache
- **render(template, objectOrMap)**: Renders the given template
- **setDelimiters(openDelimiter, closeDelimiter)**: Changes the delimiters

Supported Tags
--------------
### Variables

```template := "I am {{ name }}, age: {{ age }}"
==> I am {{ name }} age: {{ age }}
object := Object clone do( name := "Miles"; age := 20 )
==> Object_0x18bb830
  age  = 20
	name = "Miles"
Mustache render(template, object)
==> I am Miles and I am 20
```
### Sections

