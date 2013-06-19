#include "src/symbols.fst"
#include "src/phonology.fst"

ALPHABET = [#character#] [#symbol#]

.* <are_vb> ( <conj1>:<> |\
              <avperf>:<> |\
              {a\_t<pp4>}:<> )
