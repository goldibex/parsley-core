package parsley

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"
)

const (
	ParseComponentSeparator = "::"
)

var (
	GrammarError      error = errors.New("Invalid grammar dictionary specified")
	ParseGrammarError error = errors.New("Parse has invalid grammar")
)

type ParsePart struct {
	Fragment  string   `json:"fragment"`
	Component string   `json:"component"`
	Tokens    []string `json:"tokens"`
}

type Parse struct {
	Parts   []ParsePart `json:"parse_parts"`
	Summary string      `json:"summary"`
	Form    string      `json:"form"`
}

type StemGroup struct {
	Key        string   `json:"key"`
	Stems      []string `json:"stems"`
	DerivTypes []string `json:"deriv_types"`
}

type Grammar struct {
	Dictionary map[string][]string  `json:"dictionary"`
	Order      []string             `json:"order"`
	StemGroups map[string]StemGroup `json:"stem_groups"`

	tokenLookup     map[string]string `json:"-"`
	stemGroupLookup map[string]string `json:"-"`
}

func (g *Grammar) UnmarshalJSON(data []byte) error {
	type shadow struct {
		Dictionary map[string][]string  `json:"dictionary"`
		Order      []string             `json:"order"`
		StemGroups map[string]StemGroup `json:"stem_groups"`
	}
	s := shadow{}
	err := json.Unmarshal(data, &s)
	if err != nil {
		return err
	}
	g.Dictionary = s.Dictionary
	g.Order = s.Order
	g.StemGroups = s.StemGroups

	tokenLookup := make(map[string]string, len(g.Dictionary)*4)
	for key, values := range g.Dictionary {
		for _, value := range values {
			if _, ok := tokenLookup[value]; ok {
				return GrammarError
			}
			tokenLookup[value] = key
		}
	}
	g.tokenLookup = tokenLookup

	stemGroupLookup := make(map[string]string, len(g.Dictionary)*4)
	for stemGroupName, stemGroup := range g.StemGroups {
		for _, stem := range stemGroup.Stems {
			stemGroupLookup[stem] = stemGroupName
		}
		for _, derivType := range stemGroup.DerivTypes {
			stemGroupLookup[derivType] = stemGroupName
		}
	}
	g.stemGroupLookup = stemGroupLookup
	return nil
}

func (g *Grammar) Interpret(fstOut string) (*Parse, error) {

	parseFragments := strings.Split(fstOut, ParseComponentSeparator)
	p := new(Parse)
	p.Parts = make([]ParsePart, 0, len(parseFragments))

	tokenForType := make(map[string]string, 8)

	for _, fragment := range parseFragments {
		var pp ParsePart
		pp.Tokens = make([]string, 0, 8)
		pp.Fragment = fragment
		tokens := strings.Split(fragment, "<")
		for _, token := range tokens {
			if strings.HasSuffix(token, ">") {
				token = strings.Trim(token, " \r\n\t>")
				tokenType, ok := g.tokenLookup[token]
				if !ok {
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
		p.Form += pp.Component
	}

	// now generate the summary
	summaryBits := make([]string, 0, 8)

	if g.Order != nil {
		for _, k := range g.Order {
			if typeToken, ok := tokenForType[k]; ok {
				summaryBits = append(summaryBits, typeToken)
			}
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
  "parses": [
    {
      "summary": "dat sg masc",
      "parts": [
        {
          "component": "mal",
          "grammar": {
            "stemtype": "us_a_um"
          }
        },
        {
          "component": "o",
          "grammar": {
            "case": "dat",
            "number": "sg",
            "gender": "masc",
            "stemtype": "us_a_um"
          }
        }
      ]
    },
    {
      "summary": "abl sg masc",
      "parts": ...
    }
  ]
}...
*/
