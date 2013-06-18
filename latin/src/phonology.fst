#include "src/symbols.fst"

#consonant# = BCDFGHJKLMNPQRSTVWXZbcdfghjklmnpqrstvwxz
#vowel# = AEIOUYaeiouy
#lemma-extra# = \#0-9
#letter# = #consonant# #vowel# #lemma-extra#
#macron# = \_
#breve# = \^
#diaeresis# = \+
#parse-separator# = \:
#diacritic# = #macron# #breve# #diaeresis# #parse-separator#
#character# = #letter# #diacritic#

$vowel$ = [#vowel#][#diacritic#]*

$vowel-long$ = [#vowel#][#macron#]:[#macron#<>]
$vowel-short$ = [#vowel#][#breve#]:[#breve#<>]
$vowel$ = ($vowel-long$ | $vowel-short$ | $vowel$)

$vowel-sep$ = $vowel$ $vowel$ [#diaeresis#]:[#diaeresis#<>]
$vowel$ = ($vowel-sep$ | $vowel$)

$letter$ = ([#consonant#] | [#lemma-extra#]  | $vowel$)
