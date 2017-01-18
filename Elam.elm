module Elam exposing (..)

import Dict
import String
import List
import Set


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
allChars = String.toList <| String.trim """

"""

ignoreChars = Set.fromList <| String.toList ""
letters = List.filter (\c -> not (Set.member c ignoreChars)) allChars
elamLetters = Set.fromList letters

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedLetters = Set.fromList ([ '', 'X' ] ++ letters)
indexed char = Set.member char indexedLetters


-- The syllable mapping is short as of now and will likely never become
-- comprehensive. All of this is guesswork.
syllables : Dict.Dict Char (List String)
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
    
syllableMap = String.trim """
in 
šu 
ši 
na 
ak 
uš 
"""

sylDict strMap = 
    let
        lines = String.lines strMap
        addRepl : String -> Char -> (Dict.Dict Char String) -> (Dict.Dict Char String)
        addRepl target source state =
            Dict.insert source target state
        addLine line state =
            let
                sylls = String.words line 
                target = Maybe.withDefault "" (List.head sylls)
                sources = List.concat <| List.map String.toList (Maybe.withDefault [] (List.tail sylls)) 
            in
                if List.isEmpty sylls
                then state
                else List.foldr 
                    (addRepl target)
                    state
                    sources
    in
        List.foldl addLine Dict.empty lines


syllabizer strMap =
    let
        map = sylDict strMap
        replacer char = Maybe.withDefault (String.fromChar char) (Dict.get char map)
    in String.foldr (replacer >> (++)) ""


-- List of "special" characters
--
-- Most of the artifacts did not make it through time in mint condition. The
-- "special" characters can be used to mark glyphs that are unreadable or
--  are guesses.
specialChars =
    [ { displayChar = "", char = '', description = "Platzhalter für unbekannte Zeichen" }
    , { displayChar = "", char = '', description = "Kann angefügt werden, um ein anderes Zeichen als schlecht lesbar zu markieren" }
    , { displayChar = "", char = '', description = "Markiert Bruchstellen" }
    ]


-- Syllabary definitions
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letter are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
syllabaries = Dict.fromList <| List.map (\s -> (s.id, s))
    [ { id = "lumping", name = "Breit zusammenfassen für die Suche"
      , syllabary = String.trim
            """
           
    
        
      
                      
          
           
            """
      }
    , { id = "realistic", name = "Nach akutellem Kenntnisstand gruppiert"
      , syllabary = String.trim
            """

   





 





 

 
 













 


 



 





 














 
 









           
            """
      }
    , { id = "splitting", name = "Jedes Zeichen einzeln"
      , syllabary = String.join " " <| List.map String.fromChar letters
      }
    ]


-- List of letter groupings made from a syllabary string.
syllabaryList : String -> List (Char, List Char)
syllabaryList syllabary =
    let
        letterGroup letterString =
            case (String.toList letterString) of
                main :: ext -> (main, ext)
                _ -> ('?', []) -- should not be reachable?
    in
        List.map letterGroup (String.words syllabary)

-- Sanitize the syllabary string to include all Elam letters but no duplicates
dedupe : String -> (String, String)
dedupe syllabary =
    let
        dedup letter (seen, dedupSyllabary) =
            if Set.member letter seen
            then
                (seen, dedupSyllabary)
            else
                if Set.member letter indexedLetters
                then
                    (Set.insert letter seen, dedupSyllabary ++ String.fromChar letter)
                else
                    (seen, dedupSyllabary ++ String.fromChar letter)

        (presentLetters, dedupedSyllabary) = List.foldl dedup (Set.empty, "") (String.toList syllabary)
        missingLetters = Set.diff elamLetters presentLetters
    in
        (dedupedSyllabary, String.join " " (List.map String.fromChar (Set.toList missingLetters)))


-- When searching the corpus (and optionally when displaying it) we want to treat all
-- characters in an letter group as the same character. This function builds a
-- dictionary that maps all alternate versions of a letter to the main letter.
normalization : String -> Dict.Dict Char Char
normalization syllabary =
    let allLetters = Set.fromList letters
        ins group dict =
            case (String.toList group) of
                main :: extras -> List.foldl (insLetter main) (Dict.insert main main dict) extras
                _ -> dict
        insLetter main ext dict = Dict.insert ext main dict
    in List.foldl ins Dict.empty (String.words syllabary)


normalizer: Dict.Dict Char Char -> String -> String
normalizer normalization =
    let
        repl: Char -> Char
        repl letter = Maybe.withDefault letter (Dict.get letter normalization)
    in String.map repl


-- Linear Elam texts are written left-to-right (LTR) and right-to-left (RTL).
-- The majority is written RTL. We display them in their original direction, but
-- allow coercing the direction to one of the two for all panels.
-- There is speculation that at least one of the fragemnts is written in
-- boustrophedon meaning alternating writing direction per line.
type Dir
    = Original  -- No choice made yet
    | LTR       -- assumed to be written left-to-right
    | RTL       -- assumed to be written right-to-left
    | BoustroR  -- assumed to be written boustrophedon, first line right-to-left


-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups =
    [ { short = "Susa", name = "Susa", recorded = True }
    , { short = "Sha", name = "Shahdad", recorded = True }
    , { short = "Mahb", name = "Mahboubian", recorded = False }
    , { short = "Pers", name = "Persepolis", recorded = False }
    , { short = "Liga", name = "Ligabue", recorded = False }
    , { short = "Schø", name = "Schøyen", recorded = False }
    , { short = "Phoe", name = "Phoenix", recorded = False }
    , { short = "Jir", name = "Jiroft (Konar Sandal)", recorded = False }
    , { short = "Div", name = "Divers", recorded = False }
    ]


-- Linear Elam body as read by us. The writing direction is only a guess for most fragments.
type alias Fragment = { id : String, group : String, dir : Dir, text : String }
fragments : List Fragment
fragments = List.map (\f -> { f | text = String.trim f.text })
    [ { id = "A", group = "Susa", dir = RTL, text =
        """

​



        """
      }
    , { id = "B", group = "Susa", dir = LTR, text =
        """

​

        """
      }
    , { id = "C", group = "Susa", dir = RTL, text =
        """
​
​
​
​


        """
      }
    , { id = "D", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "E", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "F", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "G", group = "Susa", dir = RTL, text =
        """



        """
      }
    , { id = "H", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "I", group = "Susa", dir = RTL, text =
        """




        """
      }
    , { id = "J", group = "Susa", dir = RTL, text =
        """


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
    , { id = "O", group = "Divers", dir = RTL, text =
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
    , { id = "Or", group = "Divers", dir = RTL, text =
        """

        """
      }
    , { id = "P", group = "Susa", dir = LTR, text =
        """

        """
      }
    , { id = "Q", group = "Pers", dir = RTL, text =
        """
​​​​
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

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

        """
      }
    , { id = "V", group = "Liga", dir = RTL, text =
        """

        """
      }
    , { id = "W", group = "Phoe", dir = RTL, text =
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
                 
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
            ​​ 
             ​
            ​ 
             
            ​
            
        """
      }
    , { id = "A′", group = "Phoe", dir = RTL, text =
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

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


        """
      }
    , { id = "H′a", group = "Mahb", dir = RTL, text =
        """
            
            
            
            
        """
      }
    , { id = "H′b", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "I′a", group = "Mahb", dir = RTL, text =
        """

        """
      }
    , { id = "I′b", group = "Mahb", dir = RTL, text =
        """

​

        """
      }
    , { id = "I′c", group = "Mahb", dir = RTL, text =
        """



        """
      }
    , { id = "J′", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′", group = "Mahb", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K′b", group = "Mahb", dir = RTL, text =
        """
            
            
            
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
            
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

