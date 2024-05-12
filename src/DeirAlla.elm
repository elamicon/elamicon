module DeirAlla exposing (deiralla)

import Dict
import String
import List
import Set

import WritingDirections exposing (..)
import Script exposing (..)
import Specialchars exposing (..)
import Token
import Generated.DeirAlla

rawTokens = Token.fromNamed Generated.DeirAlla.tokens

ignoreChars = Set.insert fractureMarker guessMarkers
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens

-- These letters are counted as character positions
indexedTokens = Set.fromList (wildcardChar :: tokens)
indexed char = Set.member char indexedTokens

searchExamples =
    [ ("[]", "Search occurrences of  followed by either  or ")
    , ("(.)\\1", "Look for sign repetitions (geminates) like ")
    ]

syllables = Dict.empty

-- Syllabary definitions
--
-- We use [] to indicate space intentionally left empty (i.e. intentional text ends,  for ruptures of the fragment (i.e. unintentional ends),  as a placeholder for invisible single signs, and   to mark badly visible signs.

syllableMap = String.trim """
"""

syllabaries : List SyllabaryDef
syllabaries =
    [ { id = "typegroups"
      , name = "Typegroups"
      , syllabary = Generated.DeirAlla.syllabary
      }
    , { id = "codepoints"
      , name = "Codepoint order"
      , syllabary = String.join "\n" (List.map String.fromChar tokens)
      }
    ]


fragments : List FragmentDef
fragments =
    [ { id = "A(a)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/aa.pdf", link = Nothing, text =
        """


        """
      }
    , { id = "A(b)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/ab.pdf", link = Nothing, text =
        """

        """
      }
    , { id = "B, var. 1", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/b.pdf", link = Nothing, text =
        """
t1

        """
      }
    , { id = " B, var. 2", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/b.pdf", link = Nothing, text =
        """


        """
      }
    , { id = " B, var. 3", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/b.pdf", link = Nothing, text =
        """


        """
      }
    , { id = "C, var. 1", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/c.pdf", link = Nothing, text =
        """
t2t2t2t2t2
        """
      }
    , { id = "D", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/d.pdf", link = Nothing, text =
        """

t2
        """
      }
    , { id = "E(a)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/e.pdf", link = Nothing, text =
        """




        """
      }
    , { id = "E(b)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/e.pdf", link = Nothing, text =
        """

t2
        """
      }
    , { id = "F(a)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/f.pdf", link = Nothing, text =
        """


        """
      }
    , { id = "F(b)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/f.pdf", link = Nothing, text =
        """
t4
[]
        """
      }
    , { id = "F(c)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/f.pdf", link = Nothing, text =
        """
[]

        """
      }
    , { id = "F(d)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/f.pdf", link = Nothing, text =
        """

        """
      }
    , { id = "F(e)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/f.pdf", link = Nothing, text =
        """

        """
      }
    , { id = "G(a)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/g.pdf", link = Nothing, text =
        """
[]
t3
        """
      }
    , { id = "G(b)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/g.pdf", link = Nothing, text =
        """
[]

        """
      }
    , { id = "G(c)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/g.pdf", link = Nothing, text =
        """
t3[]
        """
      }
    , { id = "G(d)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/g.pdf", link = Nothing, text =
        """
[]
        """
      }
    , { id = "H)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/h.pdf", link = Nothing, text =
        """



        """
      }
    , { id = "I)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/i.pdf", link = Nothing, text =
        """

        """
      }
    , { id = "J)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/j.pdf", link = Nothing, text =
        """



        """
      }
    , { id = "K)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/k.pdf", link = Nothing, text =
        """



t3
        """
      }
    , { id = "L)", group = "", source = "", dir = LTR, plate = Just "plates/deiralla/l.pdf", link = Nothing, text =
        """
[= Early Proto-canaanite?]
        """
      }
    ]

groups =
    [ { id = "", name = "All inscriptions", extra = ""}
    ]

description = """
This is a tool for computer-assisted analysis of the Deir Alla Script, an undeciphered proto-alphabetic writing system used in the early 2nd millennium BC. Since in the last years, supplementary fragments have come to light, its relation to Proto-Canaanite, Byblos Script and the early Phoenician alphabets can now be debated on a more solid basis. Please donwload the GEAS TrueType Font (link in the footline of this page) for the use on your computer and in your publications.
"""

sources = """
#### Plate sources and further Literature
- **Baramki, D. (1961):** Preliminary Report on the Excavations at Tell el Ghassil. Bulletin du Musée de Beyrouth XVI, S. 87-102.
- **Cazelles, Henri (1966):** Nouvelle écriture sur tablettes d'argile trouvées à Deir Alla (Jordanie). Comptes rendus du Groupe Linguistique d'Études Chamito-Sémitiques 10, 66-78.
- **Craigie, Peter C. (1983):** The Philistines and their Material Culture by Trude Dothan (review), in: Echos du monde classique: Classical news and views University of Toronto Press Volume 27/2, 264-265.
- **De Vreeze, Michel (2019):** The Late Bronze Deir ‘Alla Tablets: A Renewed Attempt towards their Translation and Interpretation. Maarav 23.2, 443-491.
- **Dothan, Trude (2000):** La première apparition de l'écriture en Philistie. In: Viers, R. (Hrsg.): Des signes pictographiques à l'alphabet – La communication écrite en Méditerranée. Actes du Colloque, 14 et 15 mai 1996, Villa grecque Kérylos, Fondation Théodore Reinach (Beaulieu-sur-Mer). Paris: Karthala. S. 165-171.
- **Feldman, M., Master, D. M., Bianco, R. A., Burri, M., Stockhammer, P. W., Mittnik, A., Aja, A. J., Jeong, C., & Krause, J. (2019):** Ancient DNA sheds light on the genetic origins of early Iron Age Philistines. Science Advances, 5 (7): 1-10.
- **Franken, Hendricus J. (1964):** Clay Tablets from Deir 'Alla, Jordan."Vetus Testamentum 14, 377-379.
- **Franken, Hendricus J. (1964a):** Excavations at Deir 'Alla, Season 1964. Preliminary Report. Vetus Testamentum 14, 417-422.
- **Franken, Hendricus J. (1965):** A note on how the Deir ʿAlla tablets were written. Vetus Testamentum 15, 150-152.
- **Garbini, Giovanni (2006):** Introduzione all'epigrafia semítica. Brescia.
- **Haber , Marc; Joyce Nassar, Mohamed A. Almarri, Tina Saupe, Lehti Saag, Samuel J Griffith, Claude Doumet-Serhal, Julien Chanteau, Muntaha Saghieh-Beydoun, Yali Xue, Christiana L. Scheib, Chris Tyler-Smith (2020):**  A Genetic History of the Near East from an aDNA Time Course Sampling Eight Points in the Past 4,000 Years. The American Journal of Human Genetics 107(1):149-157. doi: 10.1016/j.ajhg.2020.05.008.
- **Horsfield, George & Vincent, Louis-Hugues (1932):** Une stèle égypto-moabitique au Balou'a. Revue Biblique 41, 417-444.
- **Ibrahim, Moawiyah & van der Kooij, Gerrit (1997):**Excavations at Dayr 'Alla; Seasons 1987 and 1994. Annual of the Department of Antiquities of Jordan XLI, 95-114.
- **Kafafi, Zeidan (2009):** The Archaeological Context of the Tell Deir ‘Allā Tablets. In: Kaptijn, E. & Petit, L. (Hrsg.): A Timeless Vale – Archaeological and related essays on the Jordan Valley in honour of Gerrit van der Kooij on the occasion of his sixty-fifth birthday. Leiden, 119-128.
- **Kafafi, Zeidan (2009a):** Sea People in the North of Jordan. In: Gebel, H.-G. et al. (Hrsg.): Modesty and patience: archaeological studies and memories in honour of Nabil Qadi "Abu Salim". Irbid, 50-60.
- **Klasens, A. (1965):** Opgravingen in bijbelse grond – past het of past het niet. (Tentoonstellingscatalogus 8). Rijksmuseum van Oudheden, Leiden.
- **Knauf, Ernst A. (1987):** The Tell Deir ʿAlla Tablets. Newsletter of the Institute of Archaeology and Anthropology of Yarmouk University 1, 14-16.
-**Mansfeld, Günter (1970):** Scherben mit altkanaanäischer Schrift vom Tell Kāmid el-Lōz, in: Kamid el-Loz – Kumidi, Bonn. 29-41.
- **Mazar, Amihai (1985):** The emergence of the Philistine material culture. Israel Exploration Journal 35, 95-107.
- **Mendenhall, George E. (1971):** A New Chapter in the History of the Alphabet. Bulletin du Musée de Beyrouth 24, 13-18.
- **Muhly, J. D. (1983):** Review: The Philistines and Their Material Culture. By Trude Dothan. American Journal of Archaeology 87/4, 559-561.
- **Schwartz, Glenn (2010):** Early Non-Cuneiform Writing? Third-Millennium BC Clay Cylinders from Umm el-Marra." In: Opening the Tablet Box, Leiden. 375-395.
- **Shea, William H. (1989):** The Inscribed Teblets from Tell Deir ʿAlla, Part 1. Andrews University Seminary Studies 27/1, 21-37.
- **Shea, William H. (1989a):** The Inscribed Tablets from Tell Deir ʿAlla, Part II. Andrews University Seminary Studies, Summer 1989, Vol. 27/2, 97-119.
- **Singer, Itamar (2009):** A Fragmentary Text from Tel Aphek with Unknown Script. In Schloen, J.D. (Hrsg.): Exploring the longue durée. Essays in Honor of Lawrence E. Stager. Winona Lake.
- **Steiner, Margreet L. & Wagemakers, Bart (2018):** We graven hier niet de bijbel op! De Nederlandse opgraving op Tell Deir Alla (1960-1967). Leiden: Sidestone.
- **Van den Branden, Albartus (1965):** Essai de déchiffrement des inscriptions de Deir ʿAlla. Vetus Testamentum 15, 129-152.
- **Van der Koij, Gerrit (2014):** Archaeological and Palaeographic Aspects of the Deir ‘Alla Late Bronze Age Clay Tablets . In: Zeidan, K. & Maraqte, M. (Hrsg.): A Pioneer of Arabia. Studies in the Archaeology and Epigraphy of the Levant and the Arabian Peninsula in Honor of Moawiyah Ibrahim. Rome « La Sapienza » Expedition to Palestine & Jordan 10, 157-178.
- **Ward, W.A. & Martin, M.F. (1964):** The Balu‘a Stele: A New Transcription with Palaeographical and Historical Notes. Annual of the Department of Antiquities of Jordan 8 & 9: 5-35, pl. 1-5.
- **Weippert, Manfred (1966):** Tell dēr ʿallā: Tontafeln mit einer bisher unbekannten Linearschrift (Archäologischer Jahresbericht). Zeitschrift des Deutschen Palästina-Vereins 82/3, 299-310.
"""

deiralla : Script
deiralla =
    { id = "deiralla"
    , name = "Deir Alla"
    , group = "Ancient Near Eastern Scripts"
    , headline = "Deir Alla Alphabet"
    , title = "Deir Alla"
    , description = description
    , sources = sources
    , tokens = Generated.DeirAlla.tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchBidirectionalPreset = False
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , groups = groups
    , fragments = fragments
    , inscriptionOverviewLink = Nothing
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , syllabary = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
