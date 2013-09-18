package parsley

type DictionaryInfo struct {
	Name      string `json:"name"`
	ShortName string `json:"short_name"`
}

type DictionaryEntry struct {
	Headword string `json:"headword"`
	Text     string `json:"text"`
}

type Dictionary interface {
	Info() *DictionaryInfo
	LemmaIs(lemma string) <-chan DictionaryEntry
	LemmaStartsWith(lemmaFragment string) <-chan DictionaryEntry
}
