package main

import (
  "fmt"
  "math/rand"
  "time"
)

func main() {
  signal := make(chan bool, 5)
  mainChan := make(chan int, 5)

  rand.Seed(time.Now().UnixNano())

  signal <- true
  go thingamajig(0, signal, mainChan)
  go func() {
    var goingCount, doneCount int
    for {
      select {
      case test := <-signal:
        fmt.Println("received signal", test)
        if test {
          goingCount++
        } else {
          doneCount++
        }
      }
      if goingCount == doneCount {
        close(mainChan)
        return
      }
    }
  }()
  for datum := range mainChan {
    fmt.Println("Got a", datum)
  }
}

func thingamajig(in int, signal chan bool, mainChan chan int) { 
  <-time.After(100 * time.Millisecond)
  if (in < 10) {
    signal <- true
    fmt.Println("running thingamajig again with", in + 1)
    go thingamajig(in + 1, signal, mainChan)
  }

  mainChan <- in
  signal <- false
}
