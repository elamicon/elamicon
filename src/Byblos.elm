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


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
           
      
         
         
         
          
          
                  
     
      
      
   
    
              
        
     
     
         
 
  
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
    , sources = """
- **Albright, William F. (1939):** "A Hebrew Letter from the Twelfth Century B.C." Bulletin of the American Schools of Oriental Research 73, 9-13.
- **Albright, William F. (1949):** "The so-called enigmatic inscription from Byblus." Bulletin of the American Schools of Oriental Research 116, 12-14.
- **Carlson, Deborah & Casaban, Jose Luis (2016):** Introduction to Nautical Archaeology (Anthropology 316). Texas Agricultural & Mechanical University. Online unter http://nautarch.tamu.edu/class/316/uluburun/.
- **Cazelles, Henri (1966):** "Nouvelle écriture sur tablettes d'argile trouvées à Deir Alla (Jordanie)". Comptes rendus du Groupe Linguistique d'Études Chamito-Sémitiques 10, 66-78.
- **Colless, Brian E. (1997):** "The Syllabic Inscriptions of Byblos: Miscellaneous Texts." In: Abr-Nahrain 34, 42-57.
- **Colless, Brian E. (1998):** "The Canaanite Syllabary" In: Abr-Nahrain 35, 28-46.
- **Colless, Brian E. (2019):** Cryptcracker. https://cryptcracker.blogspot.com/2010/03/inscribed-west-semitic-stone-seal-this.html
- **Dothan, Moshe & Ben-Shlomo, David (2005):** Ashdod VI: The Excavations of Areas H and K (1968-1969). Jerusalem: Israel Antiquities Authority.
- **Dunand, Maurice (1935):** "Une nouvelle inscritpion énigmatique découverte à Byblos". Mélanges Maspero 1/2, 567-571.
- **Dunand, Maurice (1938):** "Spatule de bronze avec épigraphe phénicienne du XIIIe siècle." In: Bulletin du Musée de Beyrouth 2, 99-107.
- **Dunand, Maurice (1945):** Byblia Grammata: Documents et recherches sur le développement de l’écriture en Phénicie, Beirut: République Libanaise, Ministère de l’Éducation National des Beaux-Arts.
- **Dunand, Maurice (1978):** "Nouvelles inscriptions pseudo-hiéroglyphiques découvertes à Byblos", Bulletin du Musée de Beyrouth 30, 51-59.
- **Dothan, Moshe & Ben-Shlomo, David (2005):** Ashdod VI: The Excavations of Areas H and K (1968-1969). Jerusalem: Israel Antiquities Authority.
- **Franken, Hendricus J. (1964):** "Clay Tablets from Deir 'Alla, Jordan." Vetus Testamentum 14, 377-379.
- **Franken, Hendricus J. (1964a):** "Excavations at Deir 'Alla, Season 1964." Preliminary Report. Vetus Testamentum 14, 417-422.
- **Franken, Hendricus J. (1965):** "A note on how the Deir ʿAlla tablets were written." Vetus Testamentum 15, 150-152.
- **Garbini, Giovanni (1985):** "Scrittura fenicia nell'età del bronzo dell'Italia centrale", in Parola del Passato 225, 446-451.
- **Garbini, Giovanni (2006):** Introduzione all'epigrafia semítica. Brescia.
- **Garbini, Giovanni; Maria Michela Luiselli & Guido Devoto (2004):** "Sigillo di età amarniana da Biblo con iscrizione." Rendiconti dell'Accademia Nazionale dei Lincei 9/15, 377-390.
- **Gnesotto, Fausto (1973):** "Una Tavoletta con segni grafici ignoti dal Carso Triestino." Kadmos 12, 83-87.
- **Goedicke, Hans (2006):** "A Bama of the First Cataract." In: Timelines: Studies in Honour of Manfred Bietak. Vol. 2, Leuven. 119-127.
- **Grimme, Hubert (1936):** "Ein neuer Inschriftenfund aus Byblos" Le Muséon – revue d'études orientales 49, 85-98.
- **Horsfield, George & Vincent, Louis-Hugues (1932):** Une stèle égypto-moabitique au Balou'a. Revue Biblique 41, 417-444.
- **Knauf, Ernst A. (1987):** The Tell Deir ʿAlla Tablets. Newsletter of the Institute of Archaeology and Anthropology of Yarmouk University 1, 14-16.
- **Luiselli, Maria M. (2004):** "Le scene figurate". In: Garbini, Giovanni; Maria M Luiselli & Guido Devoto: "Sigillo di età amarniana da Biblo con iscrizione." Rendiconti dell'Accademia Nazionale dei Lincei 9/15, 377-390.
- **Mansfeld, Günter (1970):** "Scherben mit altkanaanäischer Schrift vom Tell Kāmid el-Lōz", in: Kamid el-Loz – Kumidi, Bonn. 29-41.
- **Martin, Malachi (1961):** "A Preliminary Report after Re-Examination of the Byblian Inscriptions." Orientalia 30, 46-78.
- **McCarter, P. Kyle & Coote, Robert B. (1973):** "The Spatula Inscription from Byblos." Bulletin of the American School of Oriental Research 212, 16-22.
- **Moortgat-Correns, Ursula (1978):** "Tell Chuēra". Archif für Orientforschung 26, 196-204.
- **Payton, Robert (1991):** "The Ulu Burun writing-board set." Anatolian Studies 41, 99-105.
- **Petrie, William M. F. (1912):** The formation of the alphabet. London.
- **Quenet, Philippe (2005):** "The diffusion of the cuneiform writing system in northern Mesopotamia: The earliest archaeological evidence." Iraq 67/2, 31-40.
- **Saleh, Mohamed & Sourouzian, Hourig (1986):** Die Hauptwerke im Aegyptischen Museum Kairo. Antikendienst Arabische Republik Aegypten, Kairo.
- **Santoni, Anna (2019):** Mnamon – Ancient writing systems in the Mediterranean: A critical guide to electronic resources. http://mnamon.sns.it/index.php?page=Scrittura&id=3&lang=en
- **Sass, Benjamin (1988):** The Genesis of the Alphabet and its Development in the Second Millennium B.C. Wiesbaden.
- **Seger, Joe D. (1977):** "Tel Halif (Lahav) 1976". Israel Exploration Journal 27, 45-47.
- **Settgast, Jürgen; Karig, Joachim Selim & Brashear, William (1981):** Ägyptisches Museum Berlin – Staatliche Museen Preussischer Kulturbesitz. Braunschweig.
- **Singer, Itamar (2009):** A Fragmentary Text from Tel Aphek with Unknown Script. In Schloen, J.D. (Hrsg.): Exploring the longue durée. Essays in Honor of Lawrence E. Stager. Winona Lake.
- **Ussishkin, David (1983):** Excavations at Tel Lachish 1978-1983. Tel Aviv 10, 154-156.
- **Van den Branden, Albartus (1965):** Essai de déchiffrement des inscriptions de Deir ʿAlla. Vetus Testamentum 15, 129-152.
- **Weippert, Manfred (1966):** Tell dēr ʿallā: Tontafeln mit einer bisher unbekannten Linearschrift (Archäologischer Jahresbericht). Zeitschrift des Deutschen Palästina-Vereins 82/3, 299-310.
    """
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
