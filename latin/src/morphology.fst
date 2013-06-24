#include "src/symbols.fst"
#include "src/phonology.fst"

#all-but-stemtype# = #character# #morph# #other#

ALPHABET = [#character#] [#symbol#]

$mask_symbols_and_case$ = [A-Z]:[a-z]? ($letter$ | [#symbol#]:<>)+ 
$strip_enclitics$ = <>:{que}? | <>:{ne}? | <>:{ve}?

$stems$ = "<out/stems.a>"
$derivstems$ = "<out/derivs.a>" || $stems$

% flatten the derived stems
$flat_derivstems$ = _$derivstems$

$stems$ = ($stems$ | $flat_derivstems$) || $mask_symbols_and_case$
$indecl-stems$ = [#all-but-stemtype#]+ [#indecl#] || $stems$
$ends$ = "<out/endings.a>" || $mask_symbols_and_case$
$morph$ = $stems$ {\:\:}:<> $ends$

% exclude derived types from the total alphabet so they don't get
% scooped up by the Kleene star
ALPHABET = [#character#] [#morph##stemtype##compounding##contraction##syncope##nountype##usage##time##accentuation##reduplication##deponency#]

$deriv_separator$ = .* ([#deriv#] {\:\:}:<>)? .*
$acceptor$ = "<out/acceptor.a>"
(($deriv_separator$ || $acceptor$ || $morph$) | $indecl-stems$) $strip_enclitics$
