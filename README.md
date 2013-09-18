Parsley Core
------------

This is the new Parsley morphological parser for Latin. It's written
in SFST-PL, the Stuttgart FST generation format. The morphological
data itself is almost entirely the work of Morpheus from
the Perseus Project.

The tools provided here generate two separate morphological parsers,
in AT&T format. The first is a _stemmer_, which takes an inflected Latin
word and tags it by part-of-speech. _All_ possible parses are returned.

The second FST is a _lemmatizer_, which takes the stem component of the
stemmer's output and converts it into a lemma (or headword).

A sample run of the transducer using the SFST-PL tools:
```
$ rake
$ fst-mor out/morphology.a
reading transducer...
finished.
analyze> filio
fi_l<masc><ius_i>::io_<dat><sg><ius_i>
fi_l<masc><ius_i>::io_<abl><sg><ius_i>
^C
$ fst-mor out/lemmas.a
reading transducer...
finished.
analyze> fi_l<masc><ius_i>
filius<ius_i>
```


Building Parsley
----------------
To build the Latin parser, you'll first need to install the following
prerequisites:
- The Stuttgart SFST library (available [here](http://www.cis.uni-muenchen.de/~schmid/tools/SFST/).)
- A reasonably modern version of Rake (the versions included in some
releases of Mac OS X are not acceptable)

## Linux
There's a Debian package for SFST, so all Debian Linuxes (including
Ubuntu) are in luck:
```
apt-get install sfst
```

## Mac OS X
For now you have to build SFST from [the sources](http://www.cis.uni-muenchen.de/~schmid/tools/SFST/). This in turn will require XCode.

I'm working on a Homebrew recipe for SFST to make your life a bit easier.

## All together now

```
git checkout https://github.com/goldibex/parsley-core
cd parsley-core
cd latin
rake
```


FST Libraries
-------------

Also included in this repository are lightweight FST implementations
in two different languages:

- C/Objective-C
- Go

You're on your own elsewhere. I have an unpublished Ruby FST reader, but
obnoxious things like lack of tail call optimization in the Ruby
interpreter hinder its performance.

There's a good C++ FST reader included in SFST-PL, as well as the excellent
C++ [OpenFST](http://www.openfst.org/twiki/bin/view/FST/WebHome).

If you happen to know of interpreters in other languages, let me know
and I'll list them here.

## Go
There's no included binary (you can just use ```fst-mor``` for that), but
the library does have good test coverage:

```
go get github.com/goldibex/parsley-core/go/parsley
go test github.com/goldibex/parsley-core/go/parsley
```

## C/Objective-C

You'll need XCode to run the tests, which are written using SenTestingKit.
Open the xcodeproj in XCode and compile away!
