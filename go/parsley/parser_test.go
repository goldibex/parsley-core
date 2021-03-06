package parsley

import (
	"fmt"
	"strings"
	"testing"
)

var (
	stemmerSrc    string              = `0 1 helloes hello<sal>::es<pl>
  1`
	lemmatizerSrc string              = `0 1 hello<sal> hello!<sal>
  0 1 es<pl> ese<pl>
  1`
	grammarSrcJSON string = `{
    "dictionary": {
      "type": ["sal"],
      "number": ["sg", "pl"]
    },
    "order": ["number", "type"]
  }`
	testQuery    string   = "helloes"
	testLemma    string   = "hello!"
	testForm     string   = "helloes"
	stemmer      *Transducer
	lemmatizer   *Transducer
	grammar      *Grammar
	p            *Parser
	err          error
)

func init() {
	stemmer = NewTransducer(strings.NewReader(stemmerSrc), false)
	lemmatizer = NewTransducer(strings.NewReader(lemmatizerSrc), false)
	grammar = new(Grammar)
  err := grammar.UnmarshalJSON([]byte(grammarSrcJSON))
	if err != nil {
		panic(fmt.Sprintf("Error %s while creating grammar", err))
	}
}

func TestParse(t *testing.T) {
	p = NewParser(stemmer, lemmatizer, grammar)
	result, err := p.Parse(testQuery)
	if err != nil {
		t.Errorf("Error %s while running p.Parse(\"%s\")", err, testQuery)
	}
	if result.Query != testQuery {
		t.Errorf("Returned result had query %s, should be %s", result.Query, testQuery)
	}
	if len(result.Analyses) != 1 {
		t.Fatalf("Result had %d analyses, should be 1", len(result.Analyses))
	}
	analysis := result.Analyses[0]
	if analysis.Lemma != "hello!" {
		t.Errorf("Analysis had lemma %s, should be %s", analysis.Lemma, testQuery)
	}
	if len(analysis.Parses) != 1 {
		t.Errorf("Analysis had %d parses, should be 1", len(analysis.Parses))
	}

	parse := analysis.Parses[0]
	if parse.Form != testForm {
		t.Errorf("Parse had form %s, should be %s", parse.Form, testForm)
	}
	if len(parse.Parts[0].Tokens) != 1 {
		t.Errorf("Parse part 0 had %d tokens, should be 1", len(parse.Parts[0].Tokens))
	}
	t.Logf("%+v", result)
}
