package parsley

import (
  "testing"
  "bytes"
  "strings"
)

var (
  sourceData string = "0\t\t1\t\ta\t\tb\n" +
                      "0\t\t1\t\tb\t\tc\n" +
                      "1\n" +
                      "1\t\t2\t\to\t\tu\n" +
                      "1\t\t2\t\tepsout\t\t<>\n" +
                      "1\t\t2\t\t<>\t\tepsin\n" +
                      "2\n"
)


func TestEdge(t *testing.T) {
  var e Edge
  e.In = []byte("h")

  if !e.Test([]byte("h")) {
    t.Errorf("e.Test(\"h\") should have tested true")
  }
  if e.Test([]byte("w")) {
    t.Errorf("e.Test(\"w\") should have tested false")
  }
  if !e.Test([]byte("hh")) {
    t.Errorf("e.Test(\"hh\") should have tested true")
  }

  e.In = []byte("hh")
  if e.Test([]byte("h")) {
    t.Errorf("e.Test(\"h\") should have tested false")
  }
  if e.Test([]byte("hw")) {
    t.Errorf("e.Test(\"hw\") should have tested false")
  }
  if !e.Test([]byte("hh")) {
    t.Errorf("e.Test(\"hh\") should have tested true")
  }

  e.In = nil
  if !e.Test([]byte("h")) {
     t.Errorf("e.Test(\"h\") should have tested true")  
  }
  if !e.Test([]byte("hh")) {
     t.Errorf("e.Test(\"h\") should have tested true")  
  }
  if !e.Test(nil) {
     t.Errorf("e.Test(\"h\") should have tested true")  
  }

}

func TestLoadTransducerSource(t *testing.T) {
  r := strings.NewReader(sourceData)
  transducer, err := LoadTransducerSource(r, false); if err != nil {
    t.Errorf("LoadTransducerSource got error %s", err)
  }
  t.Logf("%+v", transducer)
  if rowCount := len(transducer.Table); rowCount != 2 {
    t.Errorf("Transducer table has %d entries, should be 2.", rowCount)
  }
  if edgeCount := len(transducer.Table[0]); edgeCount != 2 {
    t.Errorf("Transducer row 0 has %d edges, should be 2.", edgeCount)
  }
  if edge := transducer.Table[0][0]; bytes.Compare(edge.In, []byte("a")) != 0 && bytes.Compare(edge.In, []byte("b")) != 0 {
      t.Errorf("First edge has input tape %v, should be %s or %s", edge.In, "a", "b")
  }
  // TODO: test epsilon inputs and outputs
  if finalStateCount := len(transducer.FinalStates); finalStateCount != 2 {
    t.Errorf("Transducer has %d final states, should be 2.", finalStateCount)
  }
  transducer.Print()
}

func TestTransducerPrepare(t *testing.T) {
  r := strings.NewReader(sourceData)
  transducer, _ := LoadTransducerSource(r, false)   

  s := transducer.Prepare([]byte("a"))
  s.Run()
  for x := range s.Results {
    if string(x) != "b" && string(x) != "bepsin" {
      t.Errorf("Transducer output '%s', expected 'b' or 'bepsin'", x)
    }
  }
}
