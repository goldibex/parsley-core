package parsley

type Analysis struct {
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

func (p *Parser) Parse(q string) (*Result, error) {
  // two parts here. the first is to feed the query into the stemmer and lemmatize
  // the first part of each outcome.
  lemmaMap := make(map[string][]Parse, 8)

  s := p.Stemmer.Prepare([]byte(q))
  s.Run()
  for result := range s.Results {
    parse, err := p.Grammar.Interpret(string(result)); if err != nil {
      return nil, err
    }
    // lemmatize based on the first stem fragment
    lemmaState := p.Lemmatizer.Prepare([]byte(parse.Parts[0].Fragment))
    lemmaState.Run()
    // always exactly one lemma for each stem fragment, no need to range
    lemma := string(<-lemmaState.Results)

    if _, ok := lemmaMap[lemma]; !ok {
      lemmaMap[lemma] = make([]Parse, 0, 8)
    }
    lemmaMap[lemma] = append(lemmaMap[lemma], *parse)
  }

  analyses := make([]Analysis, 0, 8)
  for lemma, parses := range lemmaMap {
    analyses = append(analyses, Analysis{Lemma: lemma, Parses: parses}) 
  }

  return &Result{Query: q, Analyses: analyses}, nil
}
