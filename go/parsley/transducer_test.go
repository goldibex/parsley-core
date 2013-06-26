package parsley

import (
  "testing"
  "flag"
  "bytes"
  "strings"
  "os"
  "io"
  "fmt"
)

var (
  sampleData string = "0\t\t1\t\ta\t\tb\n" +
                      "0\t\t1\t\tb\t\tc\n" +
                      "1\n" +
                      "1\t\t2\t\to\t\tu\n" +
                      "1\t\t2\t\tepsout\t\t<>\n" +
                      "1\t\t2\t\t<>\t\tepsin\n" +
                      "2"
  testTransducerPath *string = flag.String("transducer", "", "Path to the transducer to test against.")
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
  var r io.Reader
  var f *os.File
  var err error

  if *testTransducerPath != "" {
    f, err = os.Open(*testTransducerPath); if err != nil {
      panic(err)
    }
    r = f
  } else {
    r = strings.NewReader(sampleData)
  }

  transducer, err := LoadTransducerSource(r, false); if err != nil {
    t.Errorf("LoadTransducerSource got error %s", err)
  }
  // now rewind the original source data and check each case
  if f != nil {
    f.Seek(0,0)
    r = f
  } else {
    r = strings.NewReader(sampleData)
  }

  var in, out string
  var fromState, toState int

  for {
    count, err := fmt.Fscanln(r, &fromState, &toState, &in, &out)
    if count == 0 && err == io.EOF {
      break
    } else if count != 1 && count != 4 {
      t.Errorf("Got an unexpected number of items on a line: should be 1 or 4, got %d, also got error %s", count, err)
    }

    // check for final state completeness
    if count == 1 && !transducer.FinalStates[fromState] {
      t.Errorf("According to the source file, %d should be a final state, but it isn't", fromState)
    }
    if count == 4 {
      if in == "<>" {
        in = ""
      }
      if out == "<>" {
        out = ""
      }

      hasMatchingEdge := false
      for i := 0; i < len(transducer.Table[fromState]); i++ {
        if transducer.Table[fromState][i].To == toState &&
        bytes.Compare([]byte(in), transducer.Table[fromState][i].In) == 0 &&
        bytes.Compare([]byte(out), transducer.Table[fromState][i].Out) == 0 {
          hasMatchingEdge = true
          break
        }
      }
      if !hasMatchingEdge {
        t.Errorf("No edge in the transducer matches %d -> %d (%s -> %s)", fromState, toState, string(in), string(out))
      }
    }
    if err == io.EOF { 
      break
    }
  }
}
