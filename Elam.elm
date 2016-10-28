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
allChars = String.toList (String.trim "

")
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


-- Syllabary definition
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letter are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
syllabaryPreset = "
                                                                                                                                                                                                                                                                       
            
     
"

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
completeSyllabary syllabary =
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
        dedupedSyllabary
        ++ " "
        ++ String.join " " (List.map String.fromChar (Set.toList missingLetters))


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
type Dir = Original | LTR | RTL


-- Linear Elam body as read by us. The writing direction is only a guess for most fragments.
fragments =
    [ { id = "A", dir = RTL, text =
        """

​



        """
      }
    , { id = "B", dir = LTR, text =
        """

​

        """
      }
    , { id = "C", dir = RTL, text =
        """
​
​
​
​


        """
      }
    , { id = "D", dir = RTL, text =
        """



k
        """
      }
    , { id = "E", dir = RTL, text =
        """




        """
      }
    , { id = "F", dir = RTL, text =
        """




        """
      }
    , { id = "G", dir = RTL, text =
        """



        """
      }
    , { id = "H", dir = RTL, text =
        """


k

        """
      }
    , { id = "I", dir = RTL, text =
        """




        """
      }
    , { id = "J", dir = RTL, text =
        """


        """
      }
    , { id = "K", dir = RTL, text =
        """




k

        """
      }
    , { id = "L", dir = RTL, text =
        """




        """
      }
    , { id = "M", dir = RTL, text =
        """





        """
      }
    , { id = "N", dir = RTL, text =
        """






        """
      }
    , { id = "O", dir = RTL, text =
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
    , { id = "O.rs", dir = RTL, text =
        """

        """
      }
    , { id = "P", dir = LTR, text =
        """

        """
      }
    , { id = "Q", dir = RTL, text =
        """
​k​​​
        """
      }
    , { id = "R", dir = RTL, text =
        """



        """
      }
    , { id = "R.rs", dir = RTL, text =
        """

        """
      }
    , { id = "S", dir = RTL, text =
        """

        """
      }
    , { id = "T", dir = RTL, text =
        """

        """
      }
    , { id = "U", dir = RTL, text =
        """


        """
      }
    , { id = "V", dir = RTL, text =
        """

        """
      }
    , { id = "F'", dir = RTL, text =
        """


        """
      }
    , { id = "D'", dir = LTR, text =
        """





        """
      }
    , { id = "B'", dir = LTR, text =
        """





        """
      }
    , { id = "B'", dir = LTR, text =
        """

        """
      }
    , { id = "C'", dir = LTR, text =
        """






        """
      }
    , { id = "C'r", dir = LTR, text =
        """

        """
      }
    , { id = "E'", dir = RTL, text =
        """


        """
      }
    , { id = "Z", dir = RTL, text =
        """
            ​
            ​​
            ​​
            ​​k 
             ​
            ​ 
             
            ​
            
        """
      }
     , { id = "X", dir = RTL, text =
        """
            kkk
            
            
        """
      }
    , { id = "Y", dir = RTL, text =
        """
            
                    
                       
        """
      }
    , { id = "Y.2", dir = LTR, text =
        """
        
        """
      }
    , { id = "A'", dir = RTL, text =
        """
            
            
            
            
            
        """
      }
    , { id = "W", dir = RTL, text =
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
    , { id = "H'a", dir = RTL, text =
        """
            
            
            
            
        """
      }
    , { id = "H'b", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "J'", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K'", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K'.b", dir = RTL, text =
        """
            
            
            
        """
      }
    , { id = "K'.c", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "K'.d", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "L'.a", dir = RTL, text =
        """
            
        """
      }
    , { id = "L'.b", dir = RTL, text =
        """
            
        """
      }
    , { id = "L'.c", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "L'.d", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuK.a", dir = LTR, text =
        """
            
        """
      }
    , { id = "neuK.b", dir = LTR, text =
        """
            
            ​
            
        """
      }
    , { id = "neuK.c", dir = LTR, text =
        """
            
            
            

        """
      }
    ]
