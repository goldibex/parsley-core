package parsley

import (
	"testing"
)

var (
  goodGrammarJSON string = `{
  "dictionary": {
    "case": ["nom", "acc", "gen"],
    "number": ["sg", "pl"],
    "gender": ["masc", "fem", "neut"],
    "stemtype": ["us_a_um"]
  },
  "order": ["gender", "case", "number"],
  "stem_groups": {
    "us_a_um": {
      "key": "us_a_um",
      "stems": ["us_a_um"]
    }
  }
}`
  badGrammarJSON string = `{
  "dictionary": {
    "case": ["nom", "acc", "gen"],
    "number": ["sg", "pl"],
    "gender": ["masc", "fem", "acc"],
    "stemtype": ["us_a_um"]
  },
  "order": ["gender", "case", "number"]
}`
	testFstOut     string = "mal<us_a_um>::us<masc><nom><sg><us_a_um>"
	testFstSummary string = "masc nom sg"
	testParseForm  string = "malus"
	testFragment   string = "mal<us_a_um>"
	testFstBadOut  string = "mal<fem><us_a_um>::us<masc><nom><sg><us_a_um>"
)

func TestNewGrammar(t *testing.T) {
	g := Grammar{}
  err := g.UnmarshalJSON([]byte(badGrammarJSON))
	if err == nil {
		t.Errorf("NewGrammar accepted a bad grammar")
	}

  err = g.UnmarshalJSON([]byte(goodGrammarJSON))
	if err != nil {
		t.Fatalf("NewGrammar rejected a good grammar with error %s", err)
	}
}

func TestInterpret(t *testing.T) {
  g := Grammar{}
  g.UnmarshalJSON([]byte(goodGrammarJSON))
	parse, err := g.Interpret(testFstOut)
	if err != nil {
		t.Errorf("Unexpected error %s returned interpreting a known good output", testFstOut)
	}
	if len(parse.Parts) != 2 {
		t.Errorf("There's %d parse components, should be 2", len(parse.Parts))
	}
	part := parse.Parts[0]
	if len(part.Tokens) != 1 {
		t.Errorf("First parse part has %d tokens, should be 1", len(part.Tokens))
	}
	if parse.Summary != testFstSummary {
		t.Errorf("Expected parse.Summary to be %s, got %s", testFstSummary, parse.Summary)
	}
	if parse.Parts[0].Fragment != testFragment {
		t.Errorf("Expected parse.Parts[0].Fragment to be %s, got %s", testFragment, parse.Parts[0].Fragment)
	}
	if parse.Form != testParseForm {
		t.Errorf("Expected parse.Form to be %s, got %s", testParseForm, parse.Form)
	}

	parse, err = g.Interpret(testFstBadOut)
	if err != ParseGrammarError {
		t.Errorf("g.Interpret failed to return ParseGrammarError on known bad input")
	}
}
