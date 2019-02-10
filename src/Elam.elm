module Elam exposing (elam)

import Dict
import String
import List
import Set

import AstralString

import WritingDirections exposing (..)
import ScriptDefs exposing (..)

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
rawTokens = AstralString.toList <| String.trim """

"""

-- List of "special" characters
--
-- Most of the artifacts did not make it through time in mint condition. The
-- "special" characters can be used to mark glyphs that are unreadable or
--  are guesses.
specialChars =
    [ { displayChar = "", char = "", description = "Wildcard for unreadable signs" }
    , { displayChar = "", char = "", description = "Marks signs that ar hard to read" }
    , { displayChar = "", char = "", description = "Marks a fracture point (line is assumed to be incomplete)" }
    ]

-- Characters that are hard to read on the originals are marked with "guessmarkers".
-- Guessmarkers are zero-width and overlap the previous charachter. There are two
-- markers because there are two writing directions.
guessMarkers = ""

-- Unreadable signs are represented by this special character
missingChar = ""

-- To mark places where we assume the writing continues but is missing, we use
-- the fracture mark.
fractureMarker = ""

ignoreChars = Set.fromList <| AstralString.toList (guessMarkers ++ missingChar ++ fractureMarker)
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens
tokenSet = Set.fromList tokens

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedTokens = Set.fromList ([ "", "X" ] ++ tokens)
indexed char = Set.member char indexedTokens


-- The syllable mapping is short as of now and will likely never become
-- comprehensive. All of this is guesswork.
syllables : Dict.Dict String (List String)
syllables = Dict.fromList
    [ ( "", [ "na" ] )
    , ( "", [ "uk ?" ] )
    , ( "", [ "NAP"] )
    , ( "", [ "NAP"] )
    , ( "", [ "en ?", "im ?"] )
    , ( "", [ "šu" ] )
    , ( "", [ "ša ?" ] )
    , ( "", [ "in" ] )
    , ( "", [ "ki" ] )
    , ( "", [ "iš ?", "uš ?" ] )
    , ( "", [ "tu ?" ] )
    , ( "", [ "hu ?"] )
    , ( "", [ "me ?" ] )
    , ( "", [ "me ?" ] )
    , ( "", [ "ši" ] )
    , ( "", [ "še ?", "si ?" ] )
    , ( "", [ "ak", "ik"] )
    , ( "", [ "hal ?" ] )
    , ( "", [ "ú" ] )
    , ( "", [ "ni ?" ] )
    , ( "", [ "piš ?" ] )
    ]

-- This is our best guess at the syllable mapping for letters where it makes sense
-- to try.
syllableMap = String.trim """
in 
šu 
ši 
na 
ak 
uš 
"""

-- Syllabary definitions
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letter are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
initialSyllabary =
    { id = "lumping", name = "Broad groups ideal for searching"
      , syllabary = String.trim
            """
          
    
        
      
                    
          
           
            """
      }

syllabaries : List SyllabaryDef
syllabaries =
    [ initialSyllabary
    , { id = "realistic", name = "Realistic according to latest research (working hypothesis)"
      , syllabary = String.trim
            """






























 






 


 
 




 

 









  
  


 
 
 












 




 

 



 

 






 
 
 

 









 

            """
      }
    , { id = "splitting", name = "Each sign separately"
      , syllabary = String.join " " tokens
      }
    ]

-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups =
    [ { short = "Susa", name = "Susa", recorded = True }
    , { short = "Sha", name = "Shahdad", recorded = True }
    , { short = "Mah", name = "Mahboubian", recorded = False }
    , { short = "Pers", name = "Persepolis", recorded = False }
    , { short = "Liga", name = "Ligabue", recorded = False }
    , { short = "Schø", name = "Schøyen", recorded = False }
    , { short = "Phoe1", name = "Phoenix 1", recorded = False }
    , { short = "Phoe2", name = "Phoenix 2", recorded = False }
    , { short = "Jir", name = "Jiroft (Konar Sandal)", recorded = False }
    , { short = "Chris", name = "Christie's Catalogue", recorded = False }
    , { short = "Time", name = "Timelineauctions Catalogue", recorded = False }
    , { short = "Gonur", name = "Gonur Tepe", recorded = True }
    , { short = "Div", name = "Divers", recorded = False }
    ]


-- Linear Elam body as read by us. The majority of the fragments is written RTL.
-- There is speculation that at least one of the fragemnts is written in
-- boustrophedon meaning alternating writing direction per line.
-- The writing direction is only a guess for many fragments.
fragments : List FragmentDef
fragments = List.map (\f -> { f | text = String.trim f.text })
    [ { id = "A", group = "Susa", dir = RTL, plate = Just "/plates/linear-elam/a.jpg", text =
        """

​



        """
      }
    , { id = "B", group = "Susa", dir = LTR, plate = Nothing, text =
        """

​

        """
      }
    , { id = "C", group = "Susa", dir = RTL, text =
        """
​
​
​
​


        """
      }
    , { id = "D", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "E", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "F", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "G", group = "Susa", dir = RTL, text =
        """



        """
      }
    , { id = "H", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "I", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "J", group = "Susa", dir = RTL, text =
        """


        """
      }
    , { id = "K", group = "Susa", dir = RTL, text =
        """






        """
      }
    , { id = "L", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "M", group = "Susa", dir = RTL, text =
        """





        """
      }
    , { id = "N", group = "Susa", dir = RTL, text =
        """






        """
      }
    , { id = "O", group = "Div", dir = RTL, text =
        """








        """
      }
    , { id = "Or", group = "Div", dir = RTL, text =
        """

        """
      }
    , { id = "P", group = "Susa", dir = LTR, text =
        """

        """
      }
    , { id = "Q", group = "Pers", dir = RTL, text =
        """
​​​
        """
      }
    , { id = "R", group = "Susa", dir = RTL, text =
        """



        """
      }
    , { id = "Rr", group = "Susa", dir = RTL, text =
        """

        """
      }
    , { id = "S", group = "Sha", dir = RTL, text =
        """

        """
      }
    , { id = "T", group = "Susa", dir = RTL, text =
        """

        """
      }
    , { id = "U", group = "Susa", dir = RTL, text =
        """


        """
      }
    , { id = "V", group = "Liga", dir = RTL, text =
        """

        """
      }
    , { id = "W", group = "Phoe1", dir = RTL, text =
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
     , { id = "X", group = "Mah", dir = RTL, text =
        """
            
            
            
        """
      }
    , { id = "Y", group = "Mah", dir = RTL, text =
        """
            
                 
                  
        """
      }
    , { id = "Yb", group = "Mah", dir = LTR, text =
        """
        
        """
      }
    , { id = "Z", group = "Mah", dir = RTL, text =
        """
            ​
            ​​
            ​​
            ​​ 
             ​
            ​ 
             
            ​
            
        """
      }
    , { id = "A′", group = "Phoe2", dir = RTL, text =
        """
            
            
            
            
            
        """
      }
    , { id = "B′", group = "Jir", dir = LTR, text =
        """





        """
      }
    , { id = "B′r", group = "Jir", dir = LTR, text =
        """

        """
      }
    , { id = "C′", group = "Jir", dir = LTR, text =
        """






        """
      }
    , { id = "C′r", group = "Jir", dir = LTR, text =
        """

        """
      }
    , { id = "D′", group = "Jir", dir = BoustroR, text =
        """





        """
      }
    , { id = "E′", group = "Jir", dir = RTL, text =
        """


        """
      }
    , { id = "F′", group = "Schø", dir = RTL, text =
        """


        """
      }
    , { id = "G'", group = "Chris", dir = LTR, text =
        """


        """
      }
    , { id = "H′a", group = "Mah", dir = RTL, text =
        """
            
            
            
            
        """
      }
    , { id = "H′b", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "I′a", group = "Mah", dir = RTL, text =
        """

        """
      }
    , { id = "I′b", group = "Mah", dir = RTL, text =
        """

​​

        """
      }
    , { id = "I′c", group = "Mah", dir = RTL, text =
        """



        """
      }
    , { id = "J′", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′a", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′b", group = "Mah", dir = RTL, text =
        """
            
            ​​
            
        """
      }
    , { id = "K′c", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′d", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "L′a", group = "Mah", dir = RTL, text =
        """
            
        """
      }
    , { id = "L′b", group = "Mah", dir = RTL, text =
        """
            
        """
      }
    , { id = "L′c", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "L′d", group = "Mah", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "M'", group = "Time", dir = RTL, text =
        """

        """
      }
    , { id = "N'", group = "Mah", dir = LTR, text =
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
    , { id = "O'", group = "Mah", dir = RTL, text =
        """

        """
      }
    , { id = "P'", group = "Gonur", dir = RTL, text =
        """

        """
      }
    ]

description = """
This is a tool for computer-assisted analysis of Linear Elamite, an undeciphered syllabic writing system used in the late 3rd millennium BC. It sports a Unicode version of all the sign variants and allows for a statistical analysis of the texts. 

#### Dynamic Syllabary
As it is unclear whether a sign is to be considered a separate sign type representing a certain sound value, or only a graphic variant of a sign type, we established a so-called dynamic syllabary, which can constantly get modified during the research process. As our working hypothesis ([Plachtzik et al. 2017]), we propose a syllabary with 99 different sign types (see settings).

#### Sequence analysis
We’ve used this tool for regex-based sequence analysis ([Mäder et al. 2018]). The method detects identical or partly identical sign sequences, considered to be morphemes or morpheme groups. It allows to distinguish them by their syntactical role: There are indispensable morphemes (head words), facultative morphemes (attributive elements) and morphemes with a paradigmatic distribution (prefixes or suffixes). Paradigmatically distributed morphemes at the end of a word, i.e. before a word divider or at the end of an inscription, are particularly interesting, because they are most likely suffixes. As an example, there are 21 cases at the ends of words, in which a stem morpheme, e.g. , is followed by either  or , but never by another sign – a pattern expected for verbal or nominal suffixes (op. cit.: Tab. 15). Looking at the proposed sound values from former decipherment attempts, most of them based on the divine name  In-šu-ši-na-k /  In-šu-(u)š-na-k known form the akkadian-elamite bilingual inscription SusaA, we find that  has the proposed sound value (u)š. This is revealing, because -(u)š is the verbal ending (3. pers. sg. perf.) known from Elamite cuneiform texts. As a consequence,  must be a further verbal ending, and  a verbal stem. In the same way, and by calculating the word-end probability for the most frequent signs, a number of nominal suffixes could be identified and related to sound values independently proposed by other scholars, the most frequent of which is  -me (op. cit.: chapter 7). Also, the sentence-initial interjection  e ('oh!') and the two determinatives I for persons () and d for gods () could be detected. This lead us to believe that the inscription  (<sup>Mah</sup>Yb) – a caption written next to a ruler's portrait on a silver bowl of the Mahboubian collection – should be read I-d and thus depicting the typical cuneiform Elamite royal name formula found in IKutir-dNahhunte and many others. Correspondences to cuneiform Elamite are also found on a grammatical level: When  is -me, a suffix for abstract nouns, then we would expect  to be optional, because in cuneiform Elamite, -me is optional (see kušik-me u-me vs. kušik u-me 'my construction' or sunki‑me u-me vs. sunki u-me 'my kingdom'). Indeed, sequence analysis shows that this is the case in   vs.   and many others (op. cit.: Tab. 12-14). All these and other reflections corroborate the suspicion that Linear Elamite is depicting the Elamite language or an idiom closely related to it. 

#### Doubtful Provenance / Suspected Forgeries
Regarding the fact that the authenticity had been doubtful for a good part of the 38 texts, the corpus has been divided into subgroups according to their provenience (see settings). Sequence analysis brought some light into the authenticity question encircling the inscriptions of doubtful provenance, see Mäder et al. 2018: chapter 9. For some of them – namely most of the Mahboubian artefacts and the recently discovered inscription <sup>Phoe</sup>A' – authenticity can be confirmed: An alleged forger would only have been able to produce the present statistical patterns, if he had proceeded the same sequence analysis on his own – an improbable assumption (op. cit.: chapter 9). On the other hand, those inscriptions which do not exhibit such typical Elamite syntactical patterns, namely <sup>Phoe</sup>W and the famous Jiroft tablets, are to be excluded from the corpus and are likely to be fakes, because they lack all the statistical features expected for a text depicting natural human language. 


[Plachtzik et al. 2017]: https://center-for-decipherment.ch/pubs/plachtzik-et-al-2017__das-syllabar-der-elamischen-strichschrift/
[Mäder et al. 2018]: https://center-for-decipherment.ch/pubs/maeder-et-al-2018__sequenzanalysen-zur-elamischen-strichschrift/
"""

elam : Script
elam =
    { id = "elam"
    , name = "Linear Elamite"
    , headline = "Online Corpus of Linear Elamite Inscriptions OCLEI"
    , title = "Elamicon"
    , description = description
    , tokens = tokens
    , specialChars = specialChars
    , guessMarkers = guessMarkers
    , indexed = indexed
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = initialSyllabary
    , groups = groups
    , fragments = fragments
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , settings = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
