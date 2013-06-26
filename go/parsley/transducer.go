package parsley

import (
  "io"
  "bufio"
  "bytes"
  "fmt"
  "strings"
  "strconv"
)

type Edge struct {
  From int
  To int
  In []byte
  Out []byte
}

func (e Edge) Test(inTape []byte) bool {
  if len(inTape) < len(e.In) {
    return false
  } else if e.In == nil {
    return true
  }
  return bytes.Compare(inTape[:len(e.In)], e.In) == 0
}

type Transducer struct {
  Table [][]Edge
  FinalStates []bool
}

func LoadTransducerSource(source io.Reader, reverseUpperLower bool) (t *Transducer, err error) {  
  // variables for reading each input line
  var fromState, toState int
  var in, out string

  edges := make([]Edge, 0, 1000)
  workingEdges := make([]Edge, 1000)
  finalStates := make([]bool, 1000)
  edgeCount := 0
  maxFromState := 0

  scanner := bufio.NewScanner(source)

  for scanner.Scan() {
    bits := strings.Fields(scanner.Text())
    count := len(bits)
    fromState, _ = strconv.Atoi(bits[0])
    switch count {
      case 1:
        for fromState > len(finalStates) {
          finalStates = append(finalStates, make([]bool, 1000)...)
        }
        finalStates[fromState] = true
      case 4:
        toState, _ = strconv.Atoi(bits[1])
        if reverseUpperLower {
          in = bits[3]
          out = bits[2]
        } else {
          in = bits[2]
          out = bits[3]
        }
        workingEdges[edgeCount].From = fromState
        workingEdges[edgeCount].To = toState

        if fromState > maxFromState {
          maxFromState = fromState
        }

        if in != "<>" {
          // non-epsilon input
          workingEdges[edgeCount].In = []byte(in)
        }
        if out != "<>" {
          // non-epsilon output
          workingEdges[edgeCount].Out = []byte(out)
        }
        edgeCount++
        if edgeCount % 1000 == 0 {
          edgeCount = 0
          edges = append(edges, workingEdges...)
          workingEdges = make([]Edge, 1000)
        }
      default:
        panic("whoops") // TODO: handle this error better
    }
  }
  edges = append(edges, workingEdges[0:edgeCount]...)
  err = nil
  edgeTable := make([][]Edge, maxFromState + 1)
  prevEdgeIndex := 0

  for i := 1; i < len(edges); i++ {
    if edges[i].From != edges[prevEdgeIndex].From {
      edgeTable[edges[prevEdgeIndex].From] = edges[prevEdgeIndex:i]
      prevEdgeIndex = i
    }
  }
  edgeTable[edges[prevEdgeIndex].From] = edges[prevEdgeIndex:]
  t = new(Transducer)
  t.Table = edgeTable
  t.FinalStates = finalStates

  return
}

type TransducerState struct {
  in []byte
  Results chan []byte
  t *Transducer
  signal chan bool
  ran bool  
}

func (t *Transducer) Prepare(in []byte) (s *TransducerState){
  s = new(TransducerState)
  s.Results = make(chan []byte, 8)
  s.signal = make(chan bool, 8)
  s.in = in
  s.t = t
  return s
}

func (t *Transducer) Print() {
  for i := 0; i < len(t.Table); i++ {
    if t.FinalStates[i] {
      fmt.Printf("%d\n", i)
    }
    for j := 0; j < len(t.Table[i]); j++ {
      var in, out string
      if t.Table[i][j].In == nil {
        in = "<>"
      } else {
        in = string(t.Table[i][j].In)
      }
      if t.Table[i][j].Out == nil {
        out = "<>"
      } else {
        out = string(t.Table[i][j].Out)
      }
      if t.Table[i][j].From != i {
        panic(fmt.Sprintf("edge.From %d doesn't correspond with table row %d\n", t.Table[i][j].From, i))
      }
      fmt.Printf("%d %d %s %s\n", t.Table[i][j].From, t.Table[i][j].To, in, out)
    }
  }
}

func (s *TransducerState) Run() {
  if s.ran {
    panic("Can't run this state, it already went!")
  }
  s.ran = true

  go func() {
    var release, retain int
    for {
      outcome := <-s.signal
      if outcome == true {
        retain++
      } else {
        release++
      }
      if retain > 0 && retain == release {
        close(s.Results)
        return
      }
    }
  }()

  // starting point
  s.signal <- true
  s.do(s.in, []*Edge{&Edge{}})
}

func (s *TransducerState) do(in []byte, path []*Edge) {
  edge := path[len(path) - 1]
  if s.t.FinalStates[edge.To] && len(in) == 0 {
    // match. send result on channel out
    outBuf := bytes.Buffer{}
    for i := 0; i < len(path); i++ {
      outBuf.Write(path[i].Out)
    }
    s.Results <- outBuf.Bytes()
  }

  if edge.To < len(s.t.Table) {
    newEdges := s.t.Table[edge.To]
    for i := 0; i < len(newEdges); i++ {
      if newEdges[i].Test(in) {
        newPath := make([]*Edge, len(path) + 1)
        copy(newPath, path)
        newPath[len(path)] = &newEdges[i]
        advanceLen := len(newEdges[i].In)
        s.signal <- true
        go s.do(in[advanceLen:], newPath)
      }
    }
  }
  s.signal <- false
}
