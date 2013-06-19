package parsley

import (
  "testing"
  "strings"
  "fmt"
)

var (
  stemmerSrc string = "0 1 helloes hello<sal>::es<pl>\n1"
  lemmatizerSrc string = "0 1 hello<sal> hello!\n0 1 es<pl> ese\n1\n"
  grammarSrc map[string][]string = map[string][]string {
    "type": []string{"sal"},
    "number": []string{"sg", "pl"},
  }
  grammarOrder []string = []string{"number", "type"}
  testQuery string = "helloes"
  testLemma string = "hello!"
  testForm string = "helloes"
  stemmer *Transducer
  lemmatizer *Transducer
  grammar *Grammar
  p *Parser
  err error
)

func init() {
  stemmer, err = LoadTransducerSource(strings.NewReader(stemmerSrc), false)
  if err != nil {
    panic(fmt.Sprintf("Error %s while creating test stemmer transducer", err))
  }
  lemmatizer, err = LoadTransducerSource(strings.NewReader(lemmatizerSrc), false)
  if err != nil {
    panic(fmt.Sprintf("Error %s while creating test lemma transducer", err))
  }
  grammar, err = NewGrammar(grammarSrc); if err != nil {
    panic(fmt.Sprintf("Error %s while creating grammar", err))
  }
  grammar.Order = grammarOrder
}

func TestParse(t *testing.T) {
  p = NewParser(stemmer, lemmatizer, grammar)
  result, err := p.Parse(testQuery); if err != nil {
    t.Errorf("Error %s while running p.Parse(\"%s\")", err, testQuery)
  }
  if result.Query != testQuery {
    t.Errorf("Returned result had query %s, should be %s", result.Query, testQuery)
  }
  if len(result.Analyses) != 1 {
    t.Errorf("Result had %d analyses, should be 1", len(result.Analyses))
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
}
