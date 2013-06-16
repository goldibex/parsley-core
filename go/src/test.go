package main

import (
  "strings"
  "bytes"
  "os"
  "parsley"
  "fmt"
)

func main() {
  file, err := os.Open(os.Args[1]); if err != nil {
    panic(err)
  }
  defer file.Close()

  fileStat, _ := file.Stat()
  fileContents := make([]byte, fileStat.Size())
  _, err = file.Read(fileContents); if err != nil {
    panic(err)
  } 
  buf := bytes.NewBuffer(fileContents)

  t, err := parsley.LoadTransducerSource(buf, true); if err != nil {
    panic(err)
  }

  var query string
  for {
    fmt.Printf( "Search term: ")
    fmt.Scanln(&query)
    query = strings.TrimSpace(query)

    s := t.Prepare([]byte(query))
    s.Run()
    count := 0
    for x := range s.Results {
      count++
      fmt.Println(string(x))
    }
    fmt.Println("Matches: ", count)
  }
}
