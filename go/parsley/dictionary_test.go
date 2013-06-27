package parsley

import (
  "testing"
  "strings"
)

type testDictionary struct {
  name string
  shortName string
  entries map[string]string
}

var (
  dictionaryEntries map[string]string = map[string]string {
    "foo": "bar",
    "bar": "baz",
  }
  dict testDictionary = testDictionary{
    name: "TestDictionary",
    shortName: "It's a test dictionary.",
    entries: dictionaryEntries,
  }
)

func (t testDictionary) Info() *DictionaryInfo {
  return &DictionaryInfo{Name: t.name, ShortName: t.shortName}
}

func (t testDictionary) LemmaIs(lemma string) <-chan DictionaryEntry {
  outCh := make(chan DictionaryEntry, 1)
  
  go func() {
    for k, v := range t.entries {
      if k == lemma {
        outCh <- DictionaryEntry{Headword:k, Text:v}
      }
    }
    close(outCh)
  }()

  return (<-chan DictionaryEntry)(outCh)
}

func (t testDictionary) LemmaStartsWith(lemmaFragment string) <-chan DictionaryEntry {
  outCh := make(chan DictionaryEntry, 1)

  go func() {
    for k, v := range t.entries {
      if strings.HasPrefix(k, lemmaFragment) {
        outCh <- DictionaryEntry{Headword:k, Text:v}
      }
    }
    close(outCh)
  }()

  return (<-chan DictionaryEntry)(outCh)
}

func TestSanity(t *testing.T) {

}
