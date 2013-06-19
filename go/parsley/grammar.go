package parsley

import (
  "errors"
  "strings"
  "fmt"
)

const (
  ParseComponentSeparator = "::"
)

var (
  GrammarError error = errors.New("Invalid grammar dictionary specified")
  ParseGrammarError error = errors.New("Parse has invalid grammar")
)

type Grammar struct {
  Dictionary map[string][]string
  Order []string
  tokenLookup map[string]string
}

func NewGrammar(dictionary map[string][]string) (*Grammar, error) {
  tokenLookup := make(map[string]string, len(dictionary) * 4)
  for key, values := range dictionary {
    for _, value := range values {
      if _, ok := tokenLookup[value]; ok {
        return nil, GrammarError
      }
      tokenLookup[value] = key
    }
  }
  return &Grammar{Dictionary: dictionary, tokenLookup: tokenLookup}, nil
}

type Result struct {
  Query string
  Analyses []Analysis
}

type Analysis struct {
  Word string
  Lemma string
  Parses []Parse
}

type Parse struct {
  Parts []ParsePart
  Summary string
}

type ParsePart struct {
  Component string
  Tokens []string
}

func (g *Grammar) Interpret(fstOut string) (*Parse, error) {

  parseFragments := strings.Split(fstOut, ParseComponentSeparator)
  p := new(Parse)
  p.Parts = make([]ParsePart, 0, len(parseFragments))

  tokenForType := make(map[string]string, 8)

  for _, fragment := range parseFragments {
    var pp ParsePart
    pp.Tokens = make([]string, 8)
    tokens := strings.Split(fragment, "<")
    for _, token := range tokens {
      if strings.HasSuffix(token, ">") {
        token = strings.Trim(token, ">")
        tokenType, ok := g.tokenLookup[token]; if !ok {
          panic(fmt.Sprintf("Token %s not found in dictionary", token))
        }
        if oldToken, ok := tokenForType[tokenType]; ok && oldToken != token {
          return nil, ParseGrammarError 
        }
        tokenForType[tokenType] = token
        pp.Tokens = append(pp.Tokens, token)
      } else {
        pp.Component = token
      }
    }
    p.Parts = append(p.Parts, pp)
  }


  summaryBits := make([]string, 0, 8)
  // now generate the summary
  if g.Order != nil {
    for _, k := range g.Order {
      summaryBits = append(summaryBits, tokenForType[k])
    }
  } else {
    for _, v := range tokenForType {
      summaryBits = append(summaryBits, v)
    }
  }

  p.Summary = strings.Join(summaryBits, " ")
  return p, nil
}

/*
{
  "word": "malo",
  "lemma": "malus",
  "analysis": [
    {
      "summary": "dat sg masc",
      "stem": {
        "grammar": {
          "stemtype": "us_a_um"
        }
      },
      "ending": {
        "component": "o",
        "grammar": {
          "case": "dat",
          "number": "sg",
          "gender": "masc",
          "stemtype": "us_a_um"
        }
      },
    },
    {
      "summary": "abl sg masc",
      "parts": ...
    }
  ]
}...
*/
