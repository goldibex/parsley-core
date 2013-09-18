package parsley

import (
	"bufio"
	"fmt"
	"io"
	"strconv"
	"strings"
)

const (
	terminalNode = 1 << 0
	endOfLine    = 1 << 1

	edgeSize = 1000
	dataSize = 10000
)

type Edge struct {
	To                   int32
	DataOffset           int32
	InLen, OutLen, Flags int16
}

type Transducer struct {
	Edges       []Edge
	NodeOffsets []int32
	Data        []byte
}

func NewTransducer(r io.Reader, reverse bool) *Transducer {
	t := new(Transducer)
	t.Edges = make([]Edge, edgeSize)
	t.NodeOffsets = make([]int32, edgeSize)
	t.Data = make([]byte, 0, dataSize)

	scanner := bufio.NewScanner(r)

	in, out := "", ""
	previousNode, node, nodeOffset := 0, 0, 0
	for scanner.Scan() {
		bits := strings.Fields(string(scanner.Bytes()))
		if len(bits) == 0 {
			break
		}

		previousNode = node
		node, _ = strconv.Atoi(bits[0])

		if node != previousNode && node != 0 {
			t.Edges[nodeOffset-1].Flags |= endOfLine
			t.NodeOffsets[node] = int32(nodeOffset)
		}

		if len(bits) == 1 { // terminal node notice
			t.Edges[nodeOffset].Flags |= (terminalNode | endOfLine)
		} else if len(bits) == 4 { // edge
			destination, _ := strconv.Atoi(bits[1])
			t.Edges[nodeOffset].To = int32(destination)
			if reverse {
				in = bits[3]
				out = bits[2]
			} else {
				in = bits[2]
				out = bits[3]
			}
			if in == "<>" {
				in = ""
			}
			if in == "<>" {
				out = ""
			}
			t.Edges[nodeOffset].DataOffset = int32(len(t.Data))
			t.Edges[nodeOffset].InLen = int16(len(in))
			t.Edges[nodeOffset].OutLen = int16(len(out))
			t.Data = append(t.Data, in...)
			t.Data = append(t.Data, out...)
		}

		nodeOffset++

		for nodeOffset >= len(t.Edges) {
			t.Edges = append(t.Edges, make([]Edge, edgeSize)...)
		}

		for nodeOffset >= len(t.NodeOffsets) {
			t.NodeOffsets = append(t.NodeOffsets, make([]int32, edgeSize)...)
		}
	}
	t.Edges[nodeOffset-1].Flags |= endOfLine
	t.Edges = t.Edges[0:nodeOffset]
	t.NodeOffsets = t.NodeOffsets[0 : node+1]
	return t
}

func (t *Transducer) Print() {
	counter := 0
	in := ""
	out := ""
	for _, edge := range t.Edges {
		if edge.Flags&terminalNode != 0 {
			fmt.Printf("%d\n", counter)
			counter++
			continue
		}

		if edge.InLen > 0 {
			in = string(t.Data[edge.DataOffset : edge.DataOffset+int32(edge.InLen)])
		} else {
			in = "<>"
		}
		if edge.OutLen > 0 {
			out = string(t.Data[edge.DataOffset+int32(edge.InLen) : edge.DataOffset+int32(edge.InLen)+int32(edge.OutLen)])
		} else {
			out = "<>"
		}
		fmt.Printf("%d %d %s %s", counter, edge.To, in, out)
		if edge.Flags&endOfLine != 0 {
			// fmt.Printf("+++")
			counter++
		}
		fmt.Printf("\n")
	}

}

type TransducerState struct {
	in      string
	Results chan string
	t       *Transducer
	signal  chan bool
	ran     bool
}

func (t *Transducer) Prepare(in string) (s *TransducerState) {
	s = new(TransducerState)
	s.Results = make(chan string, 8)
	s.signal = make(chan bool, 8)
	s.in = in
	s.t = t
	return s
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
	s.do(s.in, []int32{}, 0)
}

func (s *TransducerState) do(in string, path []int32, offset int32) {
	for {
		edge := s.t.Edges[offset]
		edgeIn := string(s.t.Data[edge.DataOffset : edge.DataOffset+int32(edge.InLen)])

		if edge.Flags&terminalNode != 0 { // terminal node
			if in == "" { // match!
				// construct and transmit the match
				out := ""
				for _, pathOffset := range path {
					pathEdge := s.t.Edges[pathOffset]
					pathEdgeOut := string(s.t.Data[pathEdge.DataOffset+int32(pathEdge.InLen) : pathEdge.DataOffset+int32(pathEdge.InLen)+int32(pathEdge.OutLen)])
					if pathEdgeOut == "<>" {
						pathEdgeOut = ""
					}
					out += pathEdgeOut
				}
				s.Results <- out
				break
			} else {
				// no way forward here. we're done.
				break
			}
		}

		if len(in) >= len(edgeIn) && in[0:len(edgeIn)] == edgeIn { // matched this edge
			newPath := make([]int32, len(path)+1)
			copy(newPath, path)
			newPath[len(path)] = offset
			s.signal <- true
			go s.do(in[len(edgeIn):], newPath, s.t.NodeOffsets[edge.To])
		}
		if s.t.Edges[offset].Flags&endOfLine != 0 {
			break
		}
		offset++
	}
	s.signal <- false
}
