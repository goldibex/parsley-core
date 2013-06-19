#include "src/symbols.fst"
#include "src/phonology.fst"

ALPHABET = [#character#] [#symbol#]

.* <ire_vb> ( <conj4>:<> |\
              <ivperf>:<> |\
              {i\_t<pp4>}:<> )
