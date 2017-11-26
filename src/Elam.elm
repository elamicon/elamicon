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

"""

-- List of "special" characters
--
-- Most of the artifacts did not make it through time in mint condition. The
-- "special" characters can be used to mark glyphs that are unreadable or
--  are guesses.
specialChars =
    [ { displayChar = "", char = "", description = "Platzhalter für unbekannte Zeichen" }
    , { displayChar = "", char = "", description = "Kann angefügt werden, um ein anderes Zeichen als schlecht lesbar zu markieren" }
    , { displayChar = "", char = "", description = "Markiert Bruchstellen" }
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
    { id = "lumping", name = "Breit zusammenfassen für die Suche"
      , syllabary = String.trim
            """
          
    
        
      
                    
          
           
            """
      }

syllabaries : List SyllabaryDef
syllabaries =
    [ initialSyllabary
    , { id = "realistic", name = "Nach aktuellem Kenntnisstand gruppiert"
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
    , { id = "splitting", name = "Jedes Zeichen einzeln"
      , syllabary = String.join " " tokens
      }
    ]

-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups =
    [ { short = "Susa", name = "Susa", recorded = True }
    , { short = "Sha", name = "Shahdad", recorded = True }
    , { short = "Mahb", name = "Mahboubian", recorded = False }
    , { short = "Pers", name = "Persepolis", recorded = False }
    , { short = "Liga", name = "Ligabue", recorded = False }
    , { short = "Schø", name = "Schøyen", recorded = False }
    , { short = "Phoe1", name = "Phoenix 1", recorded = False }
    , { short = "Phoe2", name = "Phoenix 2", recorded = False }
    , { short = "Jir", name = "Jiroft (Konar Sandal)", recorded = False }
    , { short = "Div", name = "Divers", recorded = False }
    ]


-- Linear Elam body as read by us. The majority of the fragments is written RTL.
-- There is speculation that at least one of the fragemnts is written in
-- boustrophedon meaning alternating writing direction per line.
-- The writing direction is only a guess for many fragments.
fragments : List FragmentDef
fragments = List.map (\f -> { f | text = String.trim f.text })
    [ { id = "A", group = "Susa", dir = RTL, text =
        """

​



        """
      }
    , { id = "B", group = "Susa", dir = LTR, text =
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
     , { id = "X", group = "Mahb", dir = RTL, text =
        """
            
            
            
        """
      }
    , { id = "Y", group = "Mahb", dir = RTL, text =
        """
            
                 
                  
        """
      }
    , { id = "Yb", group = "Mahb", dir = LTR, text =
        """
        
        """
      }
    , { id = "Z", group = "Mahb", dir = RTL, text =
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
    , { id = "H′a", group = "Mahb", dir = RTL, text =
        """
            
            
            
            
        """
      }
    , { id = "H′b", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "I′a", group = "Mahb", dir = RTL, text =
        """

        """
      }
    , { id = "I′b", group = "Mahb", dir = RTL, text =
        """

​​

        """
      }
    , { id = "I′c", group = "Mahb", dir = RTL, text =
        """



        """
      }
    , { id = "J′", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′a", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′b", group = "Mahb", dir = RTL, text =
        """
            
            ​​
            
        """
      }
    , { id = "K′c", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′d", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "L′a", group = "Mahb", dir = RTL, text =
        """
            
        """
      }
    , { id = "L′b", group = "Mahb", dir = RTL, text =
        """
            
        """
      }
    , { id = "L′c", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "L′d", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    ]

elam : Script
elam =
    { id = "elam"
    , name = "Elamische Strichschrift"
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
    }
