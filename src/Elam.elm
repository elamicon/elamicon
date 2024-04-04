module Elam exposing (elam)

import Dict
import List
import Regex
import Set
import String

import Script exposing (..)
import Specialchars exposing (..)
import Token exposing (..)
import WritingDirections exposing (..)

-- List of letters found in Linear-Elam writings
--
-- Many letters are present in variations that only differ in small details.
-- Most of these variations are likely style differences as the writing
-- developed over the centuries. The differences may also be ornamental or
-- idiosyncratic. There are not enough samples to decide, maybe there never will
-- be.
--
-- We were very conservative when it came to lumping glyphs into letters and
-- many variants are preserved to allow alternative interpretations.
--
-- Note that the letters are encoded in the Unicode private-use area and will
-- not show their intended form unless you use the specially crafted "elamicon"
-- font. They are listed here in codepoint order.
rawTokens = Token.toList <| String.trim """

"""

-- These characters are assumed to be seperators
seperatorChars = ""

ignoreChars = Set.union guessMarkers <| Set.fromList [ wildcardChar, fractureMarker ]
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens
tokenSet = Set.fromList tokens

-- We don't have the token names in the db. So the name of the token
-- is the token itself.
tokenList = Token.selfNamed tokens

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedTokens = Set.fromList ([ '', 'X' ] ++ tokens)
indexed char = Set.member char indexedTokens

searchExamples =
    [ ("?[]", "Search variants of  (in-šu-uš or in-šu-ši with optional NAP)")
    , ("[]", "Search  and allow placeholder instead of NAP")
    , ("([^])\\1", "Look for sign repetitions (geminates) like ")
    , ("([^]).\\1", "Sign repetitions with an arbitrary sign in-between ()")
    , ("[^]+", "Look for \"words\", assuming the vertical bar separates words")
    , ("[]", "Show sequences, with  or ")
    ]

-- The syllable mapping is short as of now and will likely never become
-- comprehensive. All of this is guesswork.
syllables = Dict.fromList
    [ ( '', [ "na" ] )
    , ( '', [ "uk ?" ] )
    , ( '', [ "NAP"] )
    , ( '', [ "NAP"] )
    , ( '', [ "en ?", "im ?"] )
    , ( '', [ "šu" ] )
    , ( '', [ "ša ?" ] )
    , ( '', [ "in" ] )
    , ( '', [ "ki" ] )
    , ( '', [ "iš ?", "uš ?" ] )
    , ( '', [ "tu ?" ] )
    , ( '', [ "hu ?"] )
    , ( '', [ "me ?" ] )
    , ( '', [ "me ?" ] )
    , ( '', [ "ši" ] )
    , ( '', [ "še ?", "si ?" ] )
    , ( '', [ "ak", "ik"] )
    , ( '', [ "hal ?" ] )
    , ( '', [ "ú" ] )
    , ( '', [ "ni ?" ] )
    , ( '', [ "piš ?" ] )
    ]


-- Syllabary definitions
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Each line has these fields, separated by whitespace:
--   - sound value: how the letter is pronounced or transliterated
--   - letter variants: the letters that are presumed to be the same sound
--   - source: where the sound value comes from.
--             This is just for reference and has no effect on the syllabary.

syllableMap = String.trim """
_	
a				Desset et al. 2022; Mäder et al. 2018:62
e				Mäder et al. 2018:66; Desset 2018:132
h 			Mäder et al. 2018:Tab. 21
h2				Desset et al. 2022
ha				Mäder et al. 2018:Tab. 21; Desset 2018:138
hi				Vallat 2011:188
hi₂				Desset et al. 2022
hu				Desset et al. 2022
hu₂				Frank 1912
i			Bork 1924; Desset et al. 2022
k				Bork 1905:327
k2				Bork 1905:327
ka 				Mäder et al. 2018:84; Desset et al. 2022;
ki				Desset et al. 2022
ki₂				Desset et al. 2022
ku				Desset et al. 2022
ko				Desset et al. 2022
l				Desset 2018:132
la				Desset et al. 2022
li				Desset et al. 2022
li₂				Desset et al. 2022
li₃				Desset et al. 2022
lu				Desset et al. 2022
m			Desset et al. 2022
me			Desset et al. 2022
mi			Desset et al. 2022
mo				Desset et al. 2022
mu				Desset et al. 2022
n		Bork 1905:327; Frank 1912
na				Bork 1905:327
ne				Desset et al. 2022
ni				Bork 1905:327; Desset et al. 2022
nu				Desset et al. 2022
p				Desset et al. 2022
p₂				Desset et al. 2022
pa				Desset et al. 2022
pe				Desset et al. 2022
pi	 		Mäder et al. 2018:62
pi₂ 				Desset 2018:138
pu				Meriggi 1971:206
po				Desset et al. 2022
r				Meriggi 1971:205
ra/maš				Desset et al. 2022; Mäder 2019:422
ri			Hinz 1962; Desset 2018:133
ri₂/KI				Desset et al. 2022; Mäder 2019:422
ru				Hinz 1962
ru₂				Desset et al. 2022
s				Mäder et al. 2018:62
sa				Desset et al. 2022
si				Desset et al. 2022
su				Bork 1905:327
so				Desset et al. 2022
š				Meriggi 1971:207
ša				Desset 2018:138; Mäder 2022:28
še				Bork 1905:327
ši				Bork 1905:327
šu				Desset et al. 2022
t				Desset et al. 2022
ta				Desset et al. 2022
te				Desset et al. 2022
ti				Desset 2018:132
tu				Desset et al. 2022
o				Mäder et al. 2018:66; Desset 2018:138
u				Desset et al. 2022
wa			Corsini 1986
we				Desset et al. 2022
z				Desset et al. 2022
za/HAL				Desset et al. 2022; Mäder 2019:422
ze			Desset et al. 2022
zu				Meriggi 1971:206
zo				Desset et al. 2022
"""

initialSyllabary =
  syllableMap
    |> String.lines
    |> List.filterMap keepSecondField
    |> String.join "\n"
keepSecondField line =
  case String.words line of
      _ :: second :: _ ->
          Just second

      _ ->
          Nothing




syllabaries : List SyllabaryDef
syllabaries =
    [ { id = "current", name = "Current state of decipherment"
      , syllabary = initialSyllabary }
    , { id = "splitting", name = "Each sign separately"
      , syllabary = String.join "\n" (List.map String.fromChar tokens)
      }
    ]

-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups =
    [ { id = "Susa-Inter"
      , name = "Group 1 (Western Elamite; 23rd century BC ante quem): Susa Intermediate state (Early Linear Elamite) (Susa-InterJ, K, L, M, N, O, R, T)"
      , extra = "(Stève 2000:75; Mäder 2022:4; Desset et al. 2022; stratigraphical Dates by Mirko Surdi, Gent University)"
      }
    , { id = "Susa-Puzur"
      , name = "Group 2 (Western Elamite; 22nd century BC): Susian Texts authored by Puzur-Inšušinak (Susa-PuzurA, B, C, D, E, F, G, H, I, P )"
      , extra = ""
      }
    , { id = "Pers"
      , name = "Group 3 (Central Elamite; 21st century BC): Marv Dasht Vessel"
      , extra = ""
      }
    , { id = "KamFirouz"
      , name = "Group 4 (Central Elamite; 19th century BC): Kam Firouz Texts authored by Itatu I (MahZ), Temti-Agun & Pala-Išan (SchøF’, MahI’, MahK’ MahL’), Eparti & Šilhaha (MahX, MahJ’, MahH’), others (MahY, MahP’, MahQ’, MahR’,)"
      , extra = ""
      }
    , { id = "ShaJir"
      , name = "Group 5 (Eastern Elamite; 23rd–19th century BC): Name Inscriptions from Shahdad (ShaS) and Jiroft (JirB’ – E’)"
      , extra = ""
      }
    , { id = "Kerman"
      , name = "Group 6 (Eastern Elamite; 23rd–19th century BC): Metal Vessels from private collections, probably Kerman) (PhoeW, PhoeA’, KermanN’, KermanO’)"
      , extra = ""
      }
    , { id = "Bactrian"
      , name = "Group 7 (Eastern Elamite; 23rd–19th century BC): Bactrian Seals & Sherds (LigaV, ChrisG’, GonurP’)"
      , extra = ""
      }
    ]


-- Linear Elam body as read by us. The majority of the fragments is written RTL.
-- There is speculation that at least one of the fragemnts is written in
-- boustrophedon meaning alternating writing direction per line.
-- The writing direction is only a guess for many fragments.
fragments : List FragmentDef
fragments = List.map (\f -> { f | text = String.trim f.text, link = Nothing })
    [ { id = "A", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/a.jpg", link = Nothing, text =
        """

​



        """
      }
    , { id = "B", group = "Susa-Puzur", source = "Susa-Puzur", dir = LTR, plate = Just "plates/linear-elam/b.jpg", link = Nothing, text =
        """

​

        """
      }
    , { id = "C", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/c.jpg", link = Nothing, text =
        """
​
​
​
​


        """
      }
    , { id = "D", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/d.jpg", link = Nothing, text =
        """




        """
      }
    , { id = "E", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/e.jpg", link = Nothing, text =
        """




        """
      }
    , { id = "F", group = "Susa-Puzur", source = "Susa-Puzur", dir = LTR, plate = Just "plates/linear-elam/f.jpg", link = Nothing, text =
        """




        """
      }
    , { id = "G", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/g.jpg", link = Nothing, text =
        """



        """
      }
    , { id = "H", group = "Susa-Puzur", source = "Susa-Puzur", dir = LTR, plate = Just "plates/linear-elam/h.jpg", link = Nothing, text =
        """




        """
      }
    , { id = "I", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/i.jpg", link = Nothing, text =
        """




        """
      }
    , { id = "J", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/j.jpg", link = Nothing, text =
        """


        """
      }
    , { id = "K", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/k.jpg", link = Nothing, text =
        """






        """
      }
    , { id = "L", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/l.jpg", link = Nothing, text =
        """




        """
      }
    , { id = "M", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/m.jpg", link = Nothing, text =
        """





        """
      }
    , { id = "N", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/n.jpg", link = Nothing, text =
        """






        """
      }
    , { id = "O", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/o.jpg", link = Nothing, text =
        """








        """
      }
    , { id = "Or", group = "Susa-inter", source = "Susa-Inter", dir = RTL, plate = Nothing, link = Nothing, text =
        """

        """
      }
    , { id = "P", group = "Susa-Puzur", source = "Susa-Puzur", dir = LTR, plate = Just "plates/linear-elam/p.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "Q", group = "Pers", source = "Pers", dir = RTL, plate = Just "plates/linear-elam/q.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "R", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/r.jpg", link = Nothing, text =
        """



        """
      }
    , { id = "Rr", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Nothing, link = Nothing, text =
        """

        """
      }
    , { id = "S", group = "ShaJir", source = "Sha", dir = RTL, plate = Just "plates/linear-elam/s.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "T", group = "Susa-Inter", source = "Susa-Inter", dir = RTL, plate = Just "plates/linear-elam/t.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "U", group = "Susa-Puzur", source = "Susa-Puzur", dir = RTL, plate = Just "plates/linear-elam/u.jpg", link = Nothing, text =
        """


        """
      }
    , { id = "V", group = "Bactrian", source = "Liga", dir = RTL, plate = Just "plates/linear-elam/v.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "W", group = "Kerman", source = "Phoe", dir = RTL, plate = Just "plates/linear-elam/w.jpg", link = Nothing, text =
        """
            
            
            
            
            
            
            
            
        """
      }
     , { id = "X", group = "KamFirouz", source = "Mah", dir= RTL, plate = Just "plates/linear-elam/x.jpg", link = Nothing, text =
        """
            
            
            
        """
      }
    , { id = "Y", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/y.jpg", link = Nothing, text =
        """
            
                 
                  
        """
      }
    , { id = "Yb", group = "KamFirouz", source = "Mah", dir = LTR, plate = Just "plates/linear-elam/y.jpg", link = Nothing, text =
        """
        
        """
      }
    , { id = "Z", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/z.jpg", link = Nothing, text =
        """
            ​
            ​​
            ​​
            ​​ 
             ​
            ​ 
             
            ​
            
        """
      }
    , { id = "A′", group = "Kerman", source = "Phoe", dir = RTL, plate = Just "plates/linear-elam/aprim.jpg", link = Nothing, text =
        """
            
            
            
            
            
        """
      }
    , { id = "B′", group = "ShaJir", source = "Jir", dir = LTR, plate = Just "plates/linear-elam/bprim.jpg", link = Nothing, text =
        """





        """
      }
    , { id = "B′r", group = "ShaJir", source = "Jir", dir = LTR, plate = Just "plates/linear-elam/bprim.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "C′", group = "ShaJir", source = "Jir", dir = LTR, plate = Just "plates/linear-elam/cprim.jpg", link = Nothing, text =
        """






        """
      }
    , { id = "C′r", group = "ShaJir", source = "Jir", dir = LTR, plate = Just "plates/linear-elam/cprim.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "D′", group = "ShaJir", source = "Jir", dir = BoustroR, plate = Just "plates/linear-elam/dprim.jpg", link = Nothing, text =
        """





        """
      }
    , { id = "E′", group = "ShaJir", source = "Jir", dir = RTL, plate = Just "plates/linear-elam/eprim.jpg", link = Nothing, text =
        """


        """
      }
    , { id = "F′", group = "KamFirouz", source="Schø", dir = RTL, plate = Just "plates/linear-elam/fprim.jpg", link = Nothing, text =
        """


        """
      }
    , { id = "G'", group = "Bactrian", source = "Chris", dir = LTR, plate = Just "plates/linear-elam/gprim.jpg", link = Nothing, text =
        """


        """
      }
    , { id = "H′a", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/hprim_a.jpg", link = Nothing, text =
        """
            
            
            
            
        """
      }
    , { id = "H′b", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/hprim_b.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "I′a", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/iprim.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "I′b", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/iprim.jpg", link = Nothing, text =
        """

​​

        """
      }
    , { id = "I′c", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/iprim.jpg", link = Nothing, text =
        """



        """
      }
    , { id = "J′", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/jprim.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "K′a", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/kprim.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "K′b", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/kprim.jpg", link = Nothing, text =
        """
            
            ​​
            
        """
      }
    , { id = "K′c", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/kprim.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "K′d", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/kprim.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "L′a", group = "KamFirouz", source = "Mah",dir = RTL, plate = Just "plates/linear-elam/lprim.jpg", link = Nothing, text =
        """
            
        """
      }
    , { id = "L′b", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/lprim.jpg", link = Nothing, text =
        """
            
        """
      }
    , { id = "L′c", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/lprim.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "L′d", group = "KamFirouz", source = "Mah", dir = RTL, plate = Just "plates/linear-elam/lprim.jpg", link = Nothing, text =
        """
            
            
        """
      }
    , { id = "N'", group = "Kerman", source = "Kerman", dir = LTR, plate = Just "plates/linear-elam/nprim.jpg", link = Nothing, text =
        """





     
     
        """
      }
    , { id = "O'", group = "Kerman", source = "Kerman", dir = RTL, plate = Just "plates/linear-elam/oprim.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "P'", group = "Bactrian", source = "Gonur", dir = RTL, plate = Just "plates/linear-elam/pprim.jpg", link = Nothing, text =
        """

        """
      }
    ]

description = """
This is a tool for computer-assisted analysis of Linear Elamite, an undeciphered syllabic writing system used in the late 3rd millennium BC. It sports a Unicode version of all the sign variants and allows for a statistical analysis of the texts.


#### Text Corpus and Concordances

Currently, 50 Linear Elamite inscriptions and fragments are known (41 when collating the fragments of a single artefact). For the current state see the [text corpus with concordance list](https://center-for-decipherment.ch/pubs/Corpus_Statistics_and_Concordance_List_OCLEI.pdf). For detailed photographs see the plate attached to every inscription below in the Folder "Inscriptions".


#### Dynamic Syllabary
As it is unclear whether a sign is to be considered a separate sign type representing a certain sound value, or only a graphic variant of a sign type, we established a so-called dynamic syllabary, which can constantly get modified during the research process. As our working hypothesis ([Plachtzik et al. 2017]), we propose a syllabary with 99 different sign types (see settings).

#### Sequence analysis
We’ve used this tool for regex-based sequence analysis ([Mäder et al. 2018]). The method detects identical or partly identical sign sequences, considered to be morphemes or morpheme groups. It allows to distinguish them by their syntactical role: There are indispensable morphemes (head words), facultative morphemes (attributive elements) and morphemes with a paradigmatic distribution (prefixes or suffixes). Paradigmatically distributed morphemes at the end of a word, i.e. before a word divider or at the end of an inscription, are particularly interesting, because they are most likely suffixes. As an example, there are 21 cases at the ends of words, in which a stem morpheme, e.g. , is followed by either  or , but never by another sign – a pattern expected for verbal or nominal suffixes (op. cit.: Tab. 15). Looking at the proposed sound values from former decipherment attempts, most of them based on the divine name  In-šu-ši-na-k /  In-šu-(u)š-na-k known form the akkadian-elamite bilingual inscription SusaA, we find that  has the proposed sound value (u)š. This is revealing, because -(u)š is the verbal ending (3. pers. sg. perf.) known from Elamite cuneiform texts. As a consequence,  must be a further verbal ending, and  a verbal stem. In the same way, and by calculating the word-end probability for the most frequent signs, a number of nominal suffixes could be identified and related to sound values independently proposed by other scholars, the most frequent of which is  -me (op. cit.: chapter 7). Also, the sentence-initial interjection  e ('oh!') and the two determinatives I for persons () and d for gods () could be detected. This lead us to believe that the inscription  (<sup>Mah</sup>Yb) – a caption written next to a ruler's portrait on a silver bowl of the Mahboubian collection – should be read I-d and thus depicting the typical cuneiform Elamite royal name formula found in IKutir-dNahhunte and many others. Correspondences to cuneiform Elamite are also found on a grammatical level: When  is -me, a suffix for abstract nouns, then we would expect  to be optional, because in cuneiform Elamite, -me is optional (see kušik-me u-me vs. kušik u-me 'my construction' or sunki‑me u-me vs. sunki u-me 'my kingdom'). Indeed, sequence analysis shows that this is the case in   vs.   and many others (op. cit.: Tab. 12-14). All these and other reflections corroborate the suspicion that Linear Elamite is depicting the Elamite language or an idiom closely related to it.

#### Doubtful Provenience / Suspected Forgeries
Regarding the fact that the authenticity had been doubtful for a good part of the 38 texts, the corpus has been divided into subgroups according to their provenience (see settings). Sequence analysis brought some light into the authenticity question encircling the inscriptions of doubtful provenience, see Mäder et al. 2018: chapter 9. For some of them – namely most of the Mahboubian artefacts and the recently discovered inscription <sup>Phoe</sup>A' – authenticity can be confirmed: An alleged forger would only have been able to produce the present statistical patterns, if he had proceeded the same sequence analysis on his own – an improbable assumption (op. cit.: chapter 9). On the other hand, those inscriptions which do not exhibit such typical Elamite syntactical patterns, namely <sup>Phoe</sup>W and the famous Jiroft tablets, are to be excluded from the corpus and are likely to be fakes, because they lack all the statistical features expected for a text depicting natural human language.


[Plachtzik et al. 2017]: https://center-for-decipherment.ch/pubs/plachtzik-et-al-2017__das-syllabar-der-elamischen-strichschrift/
[Mäder et al. 2018]: https://center-for-decipherment.ch/pubs/maeder-et-al-2018__sequenzanalysen-zur-elamischen-strichschrift/
"""

sources = """
#### Plate sources
- **Aitken, G. & Delaloye, L. (2011):** Antiquities including Property from the Collection of Baron Edouard Jean Empain. London: Christie's.
- **André, B. & Salvini, M. (1989):** Réflexions sur Puzur-Inšušinak, Iranica Antiqua 24, 53-72.
- **Caubet, A. (1994):** La cité royale de Suse. Découvertes archéologiques en Iran conservées au musée du Louvre, Paris.
- **De Mecquenem, R. (1949):** Epigraphie proto-élamite. Mémoires de la Mission Archéologie en Iran, 31. Paris.
- **Desset, F. (2018):** "Nine Linear Elamite Texts Inscribed on Silver “Gunagi” Vessels (X, Y, Z, F’, H’, I’, J’, K’and L’): New Data on Linear Elamite Writing and the History of the Sukkalmah Dynasty." Iran 56/2, S. 105-143.
- **Frank, C. (1912):** Zur Entzifferung der altelamischen Inschriften. Abhandlungen der königl.-preuss. Ak. d. Wissenschaften. Berlin.
- **Hakemi, A. (1976):** Ecriture pictographique decouverte dans les fouilles de Shahdad. Reproduction inédite. Paris.
- **Hakemi, A. (1997):** Archaeological Excavations of a Bronze Age Center in Iran. Istituto Italiano per il Medio ed Estremo Oriente, Roma.
- **Hinz, W. (1969):** "Eine neugefundene altelamische Silbervase", in: Altiranische Funde und Forschungen 1, S. 11-44.
- **Hinz, W. (1971):** "Eine altelamische Tonkrug-Aufschrift vom Rande der Lut", Archäologische Mitteilungen aus Iran 4, 21-24.
- **Klochkov, I. S. (1998):** "Signs on a potsherd from Gonur (On the question of the script used in Margiana)." Ancient Civilizations from Scythia to Siberia 5/2. S. 165-175.
- **Mäder, Michael; Balmer, Stephan; Plachtzik, Simon & Rawyler, Nicolai (2018)**: "Sequenzanalysen zur elamischen Strichschrift", in: B. Mofidi-Nasrabadi, D. Prechel, A. Pruß (eds.), Elam and its Neighbors. Recent Research and New Perspectives. Proceedings of the international congress held at Johannes Gutenberg University Mainz, September 21-23, 2016 (Elamica 8). S. 49-104.
- **Madjidzadeh, Y. (2011):** Jiroft Tablets and the Origin of the Linear Elamite Writing System, in: T. Osada/M. Witzel (eds.), Cultural Relations Between the Indus and the Iranian Plateau During the Third Millennium BCE. Harvard.
- **Mahboubian, H. (2004):** Elam – Art and Civilization of Ancient Iran, 3000-2000 BC. Salisbury.
- **[MCEI: Mahboubian Collection of Elamite Inscriptions](https://mahboubiancollection.com/collections/elemite-inscription-3?view=nano)**
- **Meriggi, P. (1972):** La scrittura proto-elamica. Parte Ia: La scrittura e il contenuto dei testi, Roma: Accademia Nazionale dei Lincei.
- **Sarrāf. M. R. (2013):** Mazhab-e qūm-e Īlām 5000-2600 sāl-e pīš (Die Religion Elams vor 5000-2600 Jahren). Sāzemān-e moṭāleʿe wa tadwīn. Tehrān.
- **Scheil, V. (1905):** Documents archaïques en écriture proto-élamite. Mémoires de la Délégation en Perse VI, S. 57-128. Paris.
- **Vallat 2011**: "Textes historiques élamites et achéménides", in: A. George et al. (eds.), Cuneiform Royal Inscriptions and Related Texts in the Schøyen Collection, Bethesda, 187-188.
- **Winkelmann, Sylvia (1999):** "Ein Stempelsiegel mit alt-elamischer Strichschrift", Archäologische Mitteilungen aus Iran 31, 23-32.
- **Winkelmann, Sylvia (2004):** Seals of the Oasis from the Ligabue Collection. With an Introduction by Pierre Amiet. Venezia. S. 25-181.

#### Further literature
- [Mäder et al. 2018](https://center-for-decipherment.ch/pubs/maeder-et-al-2018__sequenzanalysen-zur-elamischen-strichschrift/)
- [Plachtzik et al. 2017](https://center-for-decipherment.ch/pubs/plachtzik-et-al-2017__das-syllabar-der-elamischen-strichschrift/)
"""

elam : Script
elam =
    { id = "elam"
    , name = "Linear Elamite"
    , group = "Ancient Near Eastern Scripts"
    , headline = "Online Corpus of Linear Elamite Inscriptions OCLEI"
    , title = "Elamicon"
    , description = description
    , sources = sources
    , tokens = tokenList
    , seperatorChars = seperatorChars
    , indexed = indexed
    , searchBidirectionalPreset = True
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , groups = groups
    , fragments = fragments
    , inscriptionOverviewLink = Just "https://center-for-decipherment.ch/pubs/Corpus_Statistics_and_Concordance_List_OCLEI.pdf"
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , settings = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
