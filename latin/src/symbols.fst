#include "src/stemtypes.fst"

#person# = <1st><2nd><3rd>
#number# = <sg><pl>
#gender# = <masc><fem><neut>
#case# = <nom><acc><gen><dat><abl><voc><adverbial>
#tense# = <pres><imperf><fut><perf><plup><futperf>
#mood# = <ind><inf><imperat><subj><gerundive><supine><part>
#voice# = <act><pass>
#degree# = <pos><comp><superl><irreg_comp><irreg_superl>
#morph# = #person# #number# #gender# #case# #tense# #mood# #voice# #degree#

#compounding# = <no_comp><comp_only>
#contraction# = <contr><orth>
#syncope# = <syncope>
#nountype# = <ethnic><group><place><river><pers_name>
#usage# = <poetic>
#time# = <archaic><early><old><rare><late>
#accentuation# = <ant_acc>
#reduplication# = <has_redupl>
#deponency# = <dep>

#other# = #deriv# #compounding# #contraction# #syncope# #nountype# #usage# #time# #accentuation# #reduplication# #deponency#

#symbol# = #morph# #other# #stemtype#

$person$ = [#person#]
$number$ = [#number#]
$gender$ = [#gender#]
$case$ = [#case#]
$tense$ = [#tense#]
$mood$ = [#mood#]
$voice$ = [#voice#]
$degree$ = [#degree#]
$other$ = [#other#]
$stemtype$ = [#stemtype#]
$symbol$ = [#symbol#]

$=person$ = [#person#]
$=number$ = [#number#]
$=gender$ = [#gender#]
$=case$ = [#case#]
$=tense$ = [#tense#]
$=mood$ = [#mood#]
$=voice$ = [#voice#]
$=degree$ = [#degree#]
$=stemtype$ = [#stemtype#]

$separator$ = {\:\:}:<>
