INIConfig
=========

This is a native Ruby package for reading and writing INI-like configuration
files.


Example
-------

    require 'INIConfig'
    config = INIConfig.new()
    config.add_section(:Input)
    config.add_section(:Output)
    config.add_option(:Input, :dir, '/home/foo')
    config.add_option(:Input, :files, '/home/toto/list')
    config.add_option(:Output, :dir, '/home/bar')
    config.save('baz.ini')

    # Will produce a file that contains:
    # [Input]
    # dir=/home/foo
    # files=/home/toto/list
    # [Output]
    # dir=/home/bar

Description
-----------

The INI format was introduced by Microsoft with Windows 1.0 in 1985. The use
of this file format spread among softwares running on this operating system and
later on software running on other operating systems, such as Unix-like.
It is used to store configuration data in a form less complex and more readable
(but also less powerful) than XML files.

More information about INI files can be found on the [Wikipedia Page](http://en.wikipedia.org/wiki/INI_file).


Features
--------

- Save/Load file in any encoding supported by Ruby.
- No restriction in the choice of the option/value delimiter.
- Permissive parser.


Implementation
--------------

The format of INI files is not well defined. Several assumptions are made by
the **INIConfig** gem when parsing INI files.

### Global Properties

Right now, global properties are not supported. All options should remain
inside a section.

### Duplicate Options

Duplicate options are forbidden. An INIError exception is raised if you try to
create an already existing option or if you read a file that contains duplicate
options.

### Duplicate Sections

Duplicate sections are forbidden. An INIError exception is raised if you try to
create an already existing section or if you read a file that contains duplicate
sections.

### Comments

The comment character can be either a semicolon *;* or a number sign *#*. The
comment character can appear anywhere on a line including at the end of a
option/value pair declaration. If you wish to use a comment character in your
value then you will need to use quotation signs (simple or double).

    [Default]
    var1 = foo  # a comment
    var2 = bar# a comment
    var3 = "not a #comment"
    var4 = 'not a #comment'

### Multi-Line Values

Values can be continued onto multiple lines in two separate ways. Putting a
slash at the end of a line will continue the value declaration to the next
line. When parsing, the trailing slash will be consumed and **will not**
appear in the resulting value. Comments can appear to the right of the
trailing slash.

    var1 = this is a \  # these comments will
      multiline value   # be ignored by the parser

In the above example the resulting value for `var1` will be `this is a
multiline value`. If you want to preserve newline characters or leading space in
the value then quotations should be used.

    var2 = "this is a
    multiline value"

The resulting value for `var2` will be `this is a\nmultiline value`.

### Escape Characters

Some escape characters are supported within the **value** for an option.
These escape sequences will be applied only to quoted values.

* \" -- double quote
* \' -- simple quote
* \\\\ -- backslash character


Install
-------

    gem install INIConfig


Testing
-------

To run the tests:

    $ rake
