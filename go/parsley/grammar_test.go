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
  badGrammar map[string][]string = map[string][]string{
    "case": []string{"nom", "acc", "gen"},
    "number": []string{"sg", "pl"},
    "gender": []string{"masc", "fem", "nom"},
  }

  testFstOut string := "malus<no_comp><us_a_um>::us<masc><nom><sg><us_a_um>"
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
  parse := g.Interpret(testFstOut)
  if len(parse) != 2 {
    t.Errorf("There's %d parse components, should be 2", len(parse))
  }
}
