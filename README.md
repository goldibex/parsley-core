Parsley Core
------------

This is the new Parsley morphological parser for Latin. It's based on the
Stuttgart FST library and the Morpheus morphological data for Latin.

TODO
----

- Separate into two parsers, stemmatic and lemmatic
  - Stemmatic: malo -> "mal<parsebits>" "o<parsebits>"
  - Lemmatic: mal<parsebits> -> malo#1
