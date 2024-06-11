module Byblos exposing (byblos)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import Script exposing (..)
import Specialchars exposing (..)
import Token
import Syllabary exposing (sylDict)

rawTokens = Token.toList <| String.trim """

"""

ignoreChars = Set.insert fractureMarker guessMarkers
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens

-- Not currently reading the names for Byblos. So the name of the token
-- is the token itself.
tokenList = Token.selfNamed tokens

-- These letters are counted as character positions
indexedTokens = Set.fromList (wildcardChar :: tokens)
indexed char = Set.member char indexedTokens

searchExamples =
    [ ("[]", "Search occurrences of  followed by either  or ")
    , ("(.)\\1", "Look for sign repetitions (geminates) like ")
    , ("([^])\\1", "Look for sign repetitions (geminates) excluding placeholder ")
    , ("(.).\\1", "Sign repetitions with an arbitrary sign in-between ()")
    , ("[]", "Show all occurrences of  and ")
    ]


syllableMap = String.trim """
me 
pa 
ATON 
AMUN 
i 
o 
ḥ 
m 
b 
ś 
h 
aleph 
"""

initialSyllabary : SyllabaryDef
initialSyllabary =
    { id = "search"
    , name = "Initial Syllabary"
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

































        """
    }


alternateSyllabaries =
    [ { id = "syl1", name = "Syl1", syllabary = String.trim
        """













































        """
      }
    , { id = "syl2", name = "Syl2", syllabary = String.trim
        """







































        """
      }
    , { id = "syl3", name = "Syl3", syllabary = String.trim
        """

































        """
      }
    , { id = "syl4", name = "Syl4", syllabary = String.trim
        """






























        """
      }
    , { id = "syl5", name = "Syl4", syllabary = String.trim
        """






























        """
      }
    , { id = "syl6", name = "Syl6", syllabary = String.trim
        """































        """
      }
    , { id = "syl7", name = "Syl7", syllabary = String.trim
        """


























        """
      }
    , { id = "syl8", name = "Syl8", syllabary = String.trim
        """


























        """
      }
    , { id = "syl9", name = "Syl9", syllabary = String.trim
        """





































































































        """
      }
    ]

codepointSyllabary =
    { id = "splitting"
    , name = "Codepoint order"
    , syllabary = String.join "\n" (List.map String.fromChar tokens)
    }

syllabaries : List SyllabaryDef
syllabaries =  initialSyllabary :: alternateSyllabaries ++ [ codepointSyllabary ]


-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups = List.map (\f -> { id = f, name = f, extra = ""}) <| Set.toList (Set.fromList (List.map .group fragments))

-- In the source material "s" is a guessmark and "a" marks a fracture
-- whereas x is a placeholder for unreadable glyphs.
replaceGuessmark = Token.replace 's' guessMarkerL
replaceFracture = Token.replace 'a' fractureMarker
replaceWildcard = Token.replace 'x' wildcardChar
replaceMarkers = replaceGuessmark >> replaceFracture >> replaceWildcard

fragments : List FragmentDef
fragments = List.map  (\f -> { f | text = String.trim f.text |> replaceMarkers })
    [ { id = "a", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/a.jpg", link = Nothing, text =
        """
xa
sa
ssssa
sxsssa
sxxxxssssss
ssssss
s
xs
x

        """
      }
    , { id = "b", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/b.jpg", link = Nothing, text =
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
    , { id = "c", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/c.jpg", link = Nothing, text =
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
    , { id = "d", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/d.jpg", link = Nothing, text =
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
    , { id = "e", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/e.jpg", link = Nothing, text =
        """
a


        """
      }
    , { id = "f (face a = verso)", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/f.jpg", link = Nothing, text =
        """
xx
ss
x
        """
      }
    , { id = "f (face b = recto)", source = "BYBL", group = "BYBL", dir = LTR, plate = Just "plates/byblos/f.jpg", link = Nothing, text =
        """
sxsx
s
xxxx
s
        """
      }
    , { id = "g", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/g.jpg", link = Nothing, text =
        """
xsa
assa
asssa
asa
asa
        """
      }
    , { id = "h", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/h.jpg", link = Nothing, text =
        """
axs
ax
ax
        """
      }
    , { id = "i", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/i.jpg", link = Nothing, text =
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
    , { id = "j", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/j.jpg", link = Nothing, text =
        """
ax
axxx
a
ax
        """
      }
    , { id = "k", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/k.jpg", link = Nothing, text =
        """




x
        """
      }
    , { id = "l", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/l.jpg", link = Nothing, text =
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
    , { id = "m", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/m.jpg", link = Nothing, text =
        """
aa
axa
aa
        """
      }
    , { id = "n", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/n.jpg", link = Nothing, text =
        """
aa
sssxsa
xxxa
xssa
sxsa
        """
      }
    , { id = "o (recto)", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/o_recto.jpg", link = Nothing, text =
        """
sxxxxxssxsss
xsxxxxxs
xxxxxxxxs
xsxxxxxs
xxxxs
        """
      }
    , { id = "o (verso) Var. 1", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/o_verso.jpg", link = Nothing, text =
        """
xa
x

aa
        """
      }
    , { id = "o (verso) Var. 2", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/o_verso.jpg", link = Nothing, text =
        """
xxx
xsxx
sxx

        """
      }
    , { id = "p", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/p.jpg", link = Nothing, text =
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
    , { id = "q", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/q.jpg", link = Nothing, text =
        """
x

xxxx
        """
      }
    , { id = "ra", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "rb (Var. 1)", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "rb (Var. 2)", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "rb (Var. 3)", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "rc (Var. 1)", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """
s
        """
      }
    , { id = "rc (Var. 2) ", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "rc (Var. 3)", source = "BYBL", group = "BYBL", dir = TDR, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "rd", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/r.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "s", source = "BYBL", group = "BYBL", dir = RTL, plate = Just "plates/byblos/s.jpg", link = Nothing, text =
        """
xa
        """
      }
    , { id = "t", source = "BYBL", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/t.jpg", link = Nothing, text =
        """
xs
        """
      }
    , { id = "u", source = "BYBL", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/u.jpg", link = Nothing, text =
        """
xxxa
xxxa
xxa
        """
      }
    , { id = "v", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/v.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "w", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/w.jpg", link = Nothing, text =
        """
s
        """
      }
    , { id = "x", source = "BYBL?", group = "BYBL?", dir = TDR, plate = Just "plates/byblos/x.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "y", source = "BYBL?", group = "BYBL?", dir = TDR, plate = Just "plates/byblos/y.jpg", link = Nothing, text =
        """


ax
a
ax
a
        """
      }
    , { id = "z", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z.jpg", link = Nothing, text =
        """

        """
      }
    , { id = "a' (Var. 1)", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_a.jpg", link = Nothing, text =
        """
xx
s
xxxs
xxxxx
xs
        """
      }
    , { id = "a' (Var. 2)", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_a.jpg", link = Nothing, text =
        """
xxx
xxxx
xx
xxxxxx
xxxxxxx
        """
      }
    , { id = "b'a", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_b.jpg", link = Nothing, text =
        """
as
        """
      }
    , { id = "b'b", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_b.jpg", link = Nothing, text =
        """
aa
        """
      }
    , { id = "b'c", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_c.jpg", link = Nothing, text =
        """
xa
        """
      }
    , { id = "c'", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_c.jpg", link = Nothing, text =
        """
s
        """
      }
    , { id = "d'", source = "BYBL?", group = "BYBL?", dir = RTL, plate = Just "plates/byblos/z_d.jpg", link = Nothing, text =
        """

        """
      }
    ]

byblos : Script
byblos =
    { id = "byblos"
    , name = "Byblos Script"
    , group = "Ancient Near Eastern Scripts"
    , headline = "Online Corpus of Byblos Inscriptions OCBI"
    , title = "Byblicon"
    , description = """
#### Introduction
The Byblos Syllabary is an undeciphered syllabic writing system with inscriptions found in Lebanon (the major part) and Italy (some single tablets and seals).
Accoring to latest research run by the Byblicon research group (Universität Bern / Rheinische Friedrich-Wilhelms-Universität Bonn), the corpus consists of 18 inscriptions certainly written in Byblos Script (<sup>BYBL</sup>a – <sup>BYBL</sup>s), and 14 inscriptions potentially belonging to the Byblos corpus (<sup>BYBL?</sup>t – <sup>BYBL?</sup>d').

Images and drawings of every inscription can be viewed by enlarging the picture attached to the digitalized texts (tab "Inscriptions").
In the "search" tab, the search box can be used for simple searches or RegEx searches.
Please adjust the settings (tab "settings") for your specified investigation and report possible interesting findings to the Byblicon research team.
If you install the copyleft [GEAS Unicode font](fonts/GEAS-Fonts.zip) you can copy signs from this site into your own documents.

Feel free to contact the Byblicon research team: mailto:m.maeder[ätt]geass.ch.
"""
    , sources = """
#### Sources
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
    , tokens = tokenList
    , seperatorChars = ""
    , indexed = indexed
    , searchBidirectionalPreset = True
    , searchExamples = searchExamples
    , syllables = sylDict syllableMap
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , groups = groups
    , fragments = fragments
    , inscriptionOverviewLink = Nothing
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , syllabary = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
