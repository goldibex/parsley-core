package parsley

import (
  "testing"
  "flag"
  "strings"
  "os"
  "io"
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


func TestNewTransducer(t *testing.T) {
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

  transducer := NewTransducer(r, false)
  if transducer == nil {
    t.Errorf("Transducer creation failure, when it should have succeeded.")
  }
}
