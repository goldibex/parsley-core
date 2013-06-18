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
  BadGrammar error = errors.New("Invalid grammar dictionary specified")
)

type Grammar struct {
  Dictionary map[string][]string
  tokenLookup map[string]string
}

func NewGrammar(dictionary map[string][]string) (*Grammar, error) {
  tokenLookup := make(map[string]string, len(dictionary) * 4)
  for key, values := range dictionary {
    for _, value := range values {
      if _, ok := tokenLookup[value]; ok {
        return nil, BadGrammar
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
}

type ParsePart struct {
  Component string
  Tokens map[string]string
}

func (g *Grammar) Interpret(fstOut string) (p *Parse) {

  parseFragments := strings.Split(fstOut, ParseComponentSeparator)
  p.Parts = make([]ParsePart, 0, len(parseFragments))

  for _, fragment := range parseFragments {
    var pp ParsePart
    pp.Tokens = make(map[string]string, 8)
    tokens := strings.Split(fragment, "<")
    for _, token := range tokens {
      if strings.HasSuffix(token, ">") {
        token = strings.Trim(token, ">")
        tokenType, ok := g.tokenLookup[token]; if !ok {
          panic(fmt.Sprintf("Token %s not found in dictionary", token))
        }
        pp.Tokens[tokenType] = token
      } else {
        pp.Component = token
      }
    }
    p.Parts = append(p.Parts, pp)
  }
  return
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
