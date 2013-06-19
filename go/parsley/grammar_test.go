package parsley

import (
  "testing"
)

var (
  goodGrammar map[string][]string = map[string][]string{
    "case": []string{"nom", "acc", "gen"},
    "number": []string{"sg", "pl"},
    "gender": []string{"masc", "fem", "neut"},
    "stemtype": []string{"us_a_um"},
  }
  goodGrammarOrder []string = []string{"gender", "case", "number", "stemtype"}
  badGrammar map[string][]string = map[string][]string{
    "case": []string{"nom", "acc", "gen"},
    "number": []string{"sg", "pl"},
    "gender": []string{"masc", "fem", "nom"},
  }

  testFstOut string = "mal<us_a_um>::us<masc><nom><sg><us_a_um>"
  testFstSummary string = "masc nom sg us_a_um"
  testFstBadOut string = "mal<fem><us_a_um>::us<masc><nom><sg><us_a_um>"
)

func TestNewGrammar(t *testing.T) {
  g, err := NewGrammar(badGrammar); if g != nil || err == nil {
    t.Errorf("NewGrammar accepted a bad grammar")
  }

  g, err = NewGrammar(goodGrammar); if err != nil {
    t.Fatalf("NewGrammar rejected a good grammar with error %s", err)
  }
}

func TestInterpret(t *testing.T) {
  g, _ := NewGrammar(goodGrammar)
  g.Order = goodGrammarOrder
  parse, err := g.Interpret(testFstOut); if err != nil {
    t.Errorf("Unexpected error %s returned interpreting a known good output", testFstOut)
  } else if len(parse.Parts) != 2 {
    t.Errorf("There's %d parse components, should be 2", len(parse.Parts))
  } else if parse.Summary != testFstSummary {
    t.Errorf("Expected parse.Summary to be %s, got %s", testFstSummary, parse.Summary)
  }

  parse, err = g.Interpret(testFstBadOut); if err != ParseGrammarError {
    t.Errorf("g.Interpret failed to return ParseGrammarError on known bad input")
  }
}
