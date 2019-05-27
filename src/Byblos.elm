module Byblos exposing (byblos)

import Dict
import String
import List
import Set
import Regex

import AstralString

import WritingDirections exposing (..)
import ScriptDefs exposing (..)

rawTokens = AstralString.toList <| String.trim """


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
    case dir of
        LTR -> \s -> String.split guessMarkerR s |> String.join guessMarkerL
        _ -> \s -> String.split guessMarkerL s |> String.join guessMarkerR

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
    , name = "Broad grouping for searching"
    , syllabary = String.trim
        """



































  











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
    [ { id = "a", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
xa
sa
ssssa
sxsssa
sxxxxssssss
ssssss
s
xx
xx

        """
      }
    , { id = "b", group = "BYBL", dir = RTL, plate = Nothing, text =
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
    , { id = "c", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
sx
x
s






xxx

sx

sxxxxxx
xxxxxxa   a
        """
      }
    , { id = "d", group = "BYBL", dir = RTL, plate = Nothing, text =
        """


ss



x
xsx
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

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
    , { id = "e", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
a


        """
      }
    , { id = "f (face b = recto)", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
xsxs
s
xxxx
s
        """
      }
    , { id = "f (face a = verso)", group = "BYBL", dir = LTR, plate = Nothing, text =
        """
xxx
xsxsss
sxs
        """
      }
    , { id = "g", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
xsa
assa
asssa
asa
asa
        """
      }
    , { id = "h", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
axs
ax
ax
        """
      }
    , { id = "i", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
sssssxx
sxs
ss
xsssx
xss
ssss
sss
xsxxxx
ssss
        """
      }
    , { id = "j", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
ax
axxx
a
ax
        """
      }
    , { id = "k", group = "BYBL", dir = RTL, plate = Nothing, text =
        """




x
        """
      }
    , { id = "l", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
a
asx
assx
asss
asx
axs
assxxsx
asxx
axxsxss
axxxxxxxxx
xxxxxxxxxxx
sxxxssxsssx
xxssxx
        """
      }
    , { id = "m", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
aa
axa
aa
        """
      }
    , { id = "n", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
aa
sssxsa
xxxa
xssa
sxsa
        """
      }
    , { id = "o (recto)", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
sxxxxxssxsss
xsxxxxxs
xxxxxxxxs
xsxxxxxs
xxxxs
        """
      }
    , { id = "o (verso) Var. 1", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
xa
x

aa
        """
      }
    , { id = "o (verso) Var. 2", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
xxx
xsxx
sxx

        """
      }
    , { id = "p", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
axxxxxxx
axxxxxx
axxxxxxxxx
axxxxxxxxxxx
axxxxxxxx
axxxxxxxxxxxx
axxxxxx
        """
      }
    , { id = "q", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
x

xxxx
        """
      }
    , { id = "ra", group = "BYBL", dir = TDR, plate = Nothing, text =
        """

        """
      }
    , { id = "rb (Var. 1)", group = "BYBL", dir = TDR, plate = Nothing, text =
        """

        """
      }
    , { id = "rb (Var. 2)", group = "BYBL", dir = TDR, plate = Nothing, text =
        """
z
        """
      }
    , { id = "rb (Var. 3)", group = "BYBL", dir = TDR, plate = Nothing, text =
        """

        """
      }
    , { id = "rc (Var. 1)", group = "BYBL", dir = TDR, plate = Nothing, text =
        """
s
        """
      }
    , { id = "rc (Var. 2) ", group = "BYBL", dir = TDR, plate = Nothing, text =
        """

        """
      }
    , { id = "rc (Var. 3)", group = "BYBL", dir = TDR, plate = Nothing, text =
        """

        """
      }
    , { id = "rd", group = "BYBL", dir = RTL, plate = Nothing, text =
        """

        """
      }
    , { id = "s", group = "BYBL", dir = RTL, plate = Nothing, text =
        """
xa
        """
      }
    , { id = "t", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
xs
        """
      }
    , { id = "u", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
xxxa
xxxa
xxa
        """
      }
    , { id = "v", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """

        """
      }
    , { id = "w", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
s
        """
      }
    , { id = "x", group = "BYBL?", dir = TDR, plate = Nothing, text =
        """

        """
      }
    , { id = "y", group = "BYBL?", dir = TDR, plate = Nothing, text =
        """


ax
a
ax
a
        """
      }
    , { id = "z", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """

        """
      }
    , { id = "a' (Var. 1)", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
xx
s
xxxs
xxxxx
xs
        """
      }
    , { id = "a' (Var. 2)", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
xxx
xxxx
xx
xxxxxx
xxxxxxx
        """
      }
    , { id = "b'a", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
as
        """
      }
    , { id = "b'b", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
aa
        """
      }
    , { id = "b'c", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
xa
        """
      }
    , { id = "c'", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """
s
        """
      }
    , { id = "d'", group = "BYBL?", dir = RTL, plate = Nothing, text =
        """

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
