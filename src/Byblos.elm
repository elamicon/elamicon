module Byblos exposing (byblos)

import Dict
import String
import List
import Set
import Regex

import AstralString

import WritingDirections exposing (..)
import ScriptDefs exposing (..)

-- Glyphs courtesy Douros
rawTokens = AstralString.toList <| String.trim """

"""
specialChars =
    [ { displayChar = "", char = "", description = "Wildcard for unreadable signs" }
    , { displayChar = "", char = "", description = "Marks signs that are hard to read" }
    , { displayChar = "", char = "", description = "Marks a fracture point (line is assumed to be incomplete)" }
    ]

guessMarkerL = ""
guessMarkerR = ""
guessMarkers = guessMarkerL ++ guessMarkerR

guessMarkDir dir = 
    let
        guessMarkerMatch = Regex.regex ("["++guessMarkers++"]")
        replacement = case dir of
                        LTR -> guessMarkerL
                        _ -> guessMarkerR
    in
        Regex.replace Regex.All guessMarkerMatch (\_ -> replacement)

ignoreChars = Set.fromList <| List.map .char specialChars ++ [ guessMarkerL, guessMarkerR ]
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens
tokenSet = Set.fromList tokens

-- These letters are counted as character positions
-- Letter 'x' is used in places where the character has not been mapped yet.
indexedTokens = Set.fromList ([ "x" ] ++ tokens)
indexed char = Set.member char indexedTokens

searchExamples =
    [ ("[]", "Search occurrences of  followed by either  or ")
    , ("(.)\\1", "Look for sign repetitions (geminates) like ")
    , ("([^])\\1", "Look for sign repetitions (geminates) excluding placeholder ")
    , ("(.).\\1", "Sign repetitions with an arbitrary sign in-between ()")
    , ("[]", "Show all occurrences of  and ")
    ]

syllables : Dict.Dict String (List String)
syllables = Dict.fromList []

syllableMap = String.trim """
"""


initialSyllabary : SyllabaryDef
initialSyllabary =
    { id = "search"
    , name = "Ordered and grouped by looks"
    , syllabary = String.trim
        """
   
           
     
           
          
          
        
         
              
     
      
     
   
    
              
      
        
      
  
 
  
  
        """
    }

syllabaries : List SyllabaryDef
syllabaries =
    [ initialSyllabary
    ,   { id = "splitting"
        , name = "Codepoint order"
        , syllabary = String.join " " tokens
        }
    ]


-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups = List.map (\f -> { short = f, name = f, recorded = True}) <| Set.toList (Set.fromList (List.map .group fragments))

-- Tags:
--
-- lisible: inscription is reasonably readable from imagery available to us
-- posdet: there is evidence to determine top and bottom
-- posdet-pal: there is paleographic evidence to determine top and bottom
-- rev: revised signs from the Douros corpus

-- Signs:
-- _ preceding a sign signifies difficult to read
-- = preceding a sign signifies hardly readable
-- % signifies a fracture

-- In the source material "s" is a guessmark and "a" marks a fracture
replaceGuessmark = \s -> String.split "s" s |> String.join ""
replaceFracture = \s -> String.split "a" s |> String.join ""

fragments : List FragmentDef
fragments = List.map  (\f -> { f | text = String.trim f.text |> replaceGuessmark |> replaceFracture })
    [ { id = "a", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
z(Kranich bi)xa
sa
szsssa
zzzsxsssa
sxxxxzszszsszs
szsszsszzsz
zzzs
()xzzx
xz(?)zzx
z
        """
      }
    , { id = "b", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
s


sx



        """
      }
    , { id = "c", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
sx
x
s






xxx

sx
x
sxxxxxx
xxa   a
        """
      }
    , { id = "d", group = "Byblos", dir = RTL, plate = Nothing, text =
        """


ss



x
xs
xss
xsx
xssss
s




x
s
xx
xs
xx
xss


xs
xs
xxxs
s

x



x

x

xxxx
xx


        """
      }
    , { id = "e", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
a


        """
      }
    , { id = "f", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
xxx
sss
sxss
sxs
s
zxxxx
zs
        """
      }
    , { id = "g", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
xzsa
assza
asssa
asza
asza
        """
      }
    , { id = "h", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
axs
ax
ax
        """
      }
    , { id = "i", group = "Byblos", dir = RTL, plate = Nothing, text =
        """
sssssxx
sxs
ss
xsssx
ss
ssss
sss
xsxxx
ssss
        """
      }
    ]

byblos : Script
byblos =
    { id = "byblos"
    , name = "Byblos"
    , headline = "Online Corpus of Byblos Inscriptions OCBI"
    , title = "Byblicon"
    , description = """
Work in progress. Check back soon!
"""
    , sources = ""
    , tokens = tokens
    , specialChars = specialChars
    , guessMarkers = guessMarkers
    , guessMarkDir = guessMarkDir
    , seperatorChars = ""
    , indexed = indexed
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = initialSyllabary
    , groups = groups
    , fragments = fragments
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , settings = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
