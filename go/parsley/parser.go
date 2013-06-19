package parsley

type Analysis struct {
  Form string
  Lemma string
  Parses []Parse
}

type Result struct {
  Query string
  Analyses []Analysis
}

type Parser struct {
  Stemmer *Transducer
  Lemmatizer *Transducer
  Grammar *Grammar
}

func NewParser(stemmer *Transducer, lemmatizer *Transducer, grammar *Grammar) *Parser {
  p := new(Parser)
  p.Stemmer = stemmer
  p.Lemmatizer = lemmatizer
  p.Grammar = grammar

  return p
}

func (p *Parser) Parse(q string) ([]Result, error) {
  // two parts here. the first is to feed the query into the stemmer and lemmatize
  // the first part of each outcome.
  s := p.Stemmer.Prepare([]byte(q))
  s.Run()
  for result := range s.Results {
    _, err := p.Grammar.Interpret(string(result)); if err != nil {
      return nil, err
    }
    
  }
  return nil, nil
}
