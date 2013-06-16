package main

import (
  "fmt"
  "encoding/binary"
  "bytes"
)

type thingy struct {
  name string
  vals []int32
}

func main() {
  data := thingy{"hello", []int32{1,2,3,65547}}
  data2 := thingy{}

  b := new(bytes.Buffer)
  fmt.Println(data)
  err := binary.Write(b, binary.LittleEndian, &data); if err != nil {
    panic(err)
  }
  fmt.Println(b.Bytes())
  b2 := bytes.NewBuffer(b.Bytes())
  err = binary.Read(b2, binary.LittleEndian, &data2); if err != nil {
    panic(err)
  }
  fmt.Println(data2)
}
