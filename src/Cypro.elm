module Cypro exposing (cypro)

import Dict
import String
import List
import Set

import AstralString

import WritingDirections exposing (..)
import ScriptDefs exposing (..)

-- Glyphs courtesy Douros
rawTokens = AstralString.toList <| String.trim """
󱀀󱀁󱀂󱀃󱀄󱀅󱀆󱀇󱀈󱀉󱀊󱀋󱀌󱀍󱀎󱀏󱀐󱀑󱀒󱀓󱀔󱀕󱀖󱀗󱀘󱀙󱀚󱀛󱀜󱀝󱀞󱀟󱀠󱀡󱀢󱀣󱀤󱀥󱀦󱀧󱀨󱀩󱀪󱀫󱀬󱀭󱀮󱀯󱀰󱀱󱀲󱀳󱀴󱀵󱀶󱀷󱀸󱀹󱀺󱀻󱀼󱀽󱀾󱀿󱁀󱁁󱁂󱁃󱁄󱁅󱁆󱁇󱁈󱁉󱁊󱁋󱁌󱁍󱁎󱁏󱁐󱁑󱁒󱁓󱁕󱁖󱁗󱁘󱁙󱁚󱁛󱁜󱁝󱁞󱁟󱁠󱁡󱁢󱁣󱁤󱁥󱁦󱁧󱁨󱁩󱁪󱁫󱁬󱁭󱁮󱁯󱁰󱁱󱁲󱁳󱁴󱁵󱁶󱁷󱁸󱁹󱁺󱁻󱁼󱁽󱁾󱁿󱂀󱂁󱂂󱂃󱂄󱂅󱂆󱂇󱂈󱂉󱂊󱂋󱂌󱂍󱂎󱂏󱂐󱂑󱂒󱂓󱂔󱂕󱂖󱂗󱂘󱂙󱂚󱂛󱂜󱂝󱂞󱂟󱂠󱂡󱂢󱂣󱂤󱂦󱂧󱂨󱂩󱂪󱂫󱂬󱂭󱂮󱂯󱂰󱂱󱂲󱂳󱂴󱂵󱂶󱂷󱂸󱂹󱂺󱂻󱂼󱂽󱂾󱂿󱃀󱃁󱃂󱃃󱃄󱃅󱃆󱃇󱃈󱃉󱃊󱃋󱃌󱃍󱃎󱃏󱃐󱃑󱃒󱃓󱃔󱃕󱃖󱃗󱃘󱃙󱃚󱃛󱃜󱃝󱃞󱃟󱃠󱃡󱃢󱃣󱃤󱃥󱃦󱃧󱃨󱃩󱃫󱃬󱃭󱃮󱃯󱃰󱃱󱃲󱃳󱃴󱃵󱃶󱃷󱃸󱃹󱃺󱃻󱃼󱃽󱃾󱃿󱄀󱄁󱄂󱄃󱄄󱄅󱄆󱄇󱄈󱄉󱄊󱄋󱄌󱄍󱄎󱄏󱄐󱄑󱄒󱄓󱄔󱄕󱄖󱄗󱄘󱄙󱄚󱄛󱄜󱄝󱄞󱄟󱄠󱄡󱄢󱄣󱄤󱄥󱄦󱄧󱄨󱄩󱄪󱄫󱄬󱄭󱄮󱄯󱄰󱄱󱄲󱄳󱄴󱄵󱄶󱄷󱄸󱄹󱄺󱄻󱄼󱄽󱄾󱄿󱅀󱅁󱅂󱅃󱅄󱅅󱅆󱅇󱅈󱅍󱅎󱅏󱅐󱅑󱅒󱅓󱅔󱅕󱅖󱅗󱅘󱅙󱅚󱅛󱅜󱅝󱅞󱅟󱅠󱅡󱅢󱅣󱅤󱅥󱅦󱅧󱅨󱅩󱅪󱅫󱅬󱅭󱅮󱅯󱅰󱅱󱅲󱅳󱅴󱅵󱅶󱅷󱅸󱅹󱅺󱅻󱅼󱅽󱅾󱅿󱆀󱆁󱆂󱆃󱆄󱆅󱆆󱆇󱆈󱆉󱆊󱆋󱆌󱆍󱆎󱆏󱆐󱆑󱆒󱆓󱆔󱆕󱆖󱆗󱆘󱆙󱆚󱆛󱆜󱆝󱆞󱆟󱆠󱆡󱆢󱆣󱆤󱆥󱆦󱆧󱆨󱆩󱆪󱆫󱆬󱆭󱆮󱆯󱆰󱆱󱆲󱆳󱆴󱆵󱆶󱆷󱆸󱆹󱆺󱆻󱆼󱆽󱆾󱆿󱇀󱇁󱇂󱇃󱇄󱇅󱇆󱇇󱇈󱇉󱇊󱇋󱇌󱇍󱇎󱇏󱇐󱇑󱇒󱇓󱇔󱇕󱇖󱇗󱇘󱇙󱇚󱇛󱇜󱇝󱇞󱇟󱇠󱇡󱇢󱇣󱇤󱇥󱇦󱇧󱇨󱇩󱇪󱇫󱇬󱇭󱇮󱇯󱇰󱇱󱇲󱇳󱇴󱇶󱇷󱇸󱇺󱇻󱇼󱇽󱇾󱇿󱈀󱈁󱈂󱈃󱈄󱈅󱈆󱈇󱈈󱈉󱈊󱈋󱈌󱈍󱈎󱈏󱈐󱈑󱈒󱈓󱈔󱈕󱈖󱈗󱈘󱈙󱈚󱈛󱈜󱈝󱈞󱈟󱈠󱈡󱈢󱈣󱈤󱈥󱈦󱈧󱈨󱈩󱈪󱈫󱈬󱈭󱈮󱈯󱈰󱈱󱈲󱈳󱈴󱈵󱈶󱈷󱈸󱈹󱈺󱈻󱈼󱈽󱈾󱈿󱉀󱉁󱉂󱉃󱉄󱉅󱉆󱉇󱉈󱉉󱉊󱉋󱉌󱉍󱉎󱉏󱉐󱉑󱉒󱉓󱉔󱉕󱉖󱉗󱉘󱉙󱉚󱉛󱉜󱉝󱉞󱉟󱉠󱉡󱉢󱉣󱉤󱉥󱉦󱉧󱉩󱉪󱉫󱉬󱉭󱉮󿊀
"""

-- List of "special" characters
--
-- Most of the artefacts did not make it through time in mint condition. The
-- "special" characters can be used to mark glyphs that are unreadable or
--  are guesses.
specialChars = [ { displayChar = "󿊀", char = "󿊀", description = "Platzhalter für unbekannte Zeichen" }]

ignoreChars = Set.fromList <| List.map .char specialChars
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens
tokenSet = Set.fromList tokens

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedTokens = Set.fromList ([ "X" ] ++ tokens)
indexed char = Set.member char indexedTokens


-- The syllable mapping is short as of now and will likely never become
-- comprehensive. All of this is guesswork.
syllables : Dict.Dict String (List String)
syllables = Dict.fromList []

-- This is our best guess at the syllable mapping for letters where it makes sense
-- to try.
syllableMap = String.trim """
"""

-- Syllabary definitions
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letters are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
initialSyllabary =
    { id = "lumping", name = "Breit zusammenfassen für die Suche"
      , syllabary = String.trim
            """
󱀈󱀉󱂊󱃒󱃓󱃔󱃕󱃖󱃗󱁧󱁨󱁩󱁪󱁫󱁬󱁭󱁮󱁯󱁰󱁱󱈉󱈜󱄚󱁲󱁳󱄒󱄓󱄔󱄕󱄖󱄗󱄘󱆜󱆡󱆢󱆣󱆤󱆥󱆦󱆧󱈚󱈭󱆨󱆪󱆫󱆬󱈽󱆭󱆮󱆽󱇼󱈑󱈒
󱄙󱃘󱅪󱈳
󱅣󱅤󱅥󱅦󱅧󱅨󱅩󱀻󱄃󱀼󱇿󱀸󱀹󱄂󱂺
󱀆󱀇󱀕󱀊󱀜󱀝󱂬󱃴󱄸
󱀋󱀌
󱂇󱂈󱃧󱃦󱃨󱆼󱅠󱅡󱂉󱀅󱈿󱉀󱈅󱂍󱂎󱄦󱇦󱇧󱈔󱄑󱈣󱉆󱈖󱂏󱉪󱉫󱈬󱂑󱂜󱂻󱈥󱉦󱉧󱉩󱃩󱃫󱈠󱈌󱃬󱃭󱈘󱉮󱇾󱈗󱈸󱈼󱈵󱉃󱇌󱉒󱉓󱇱󱈪󱇘󱇐󱈧󱇎󱇢󱃮󱄣󱄤󱄥󱄧󱄨󱈱󱄩󱄪󱈤󱀍󱀖󱄬󱄭󱄮󱄯󱆛󱆾󱆿󱇨󱈍󱇩󱇪󱇫󱇬󱇭󱇮󱇯󱇀󱇁󱇂󱇃󱇤󱇄󱇅󱇇󱇈󱇉󱇊󱁛󱂓󱂔󱂕󱂖󱂗󱂘󱂙󱂚󱂛󱂐󱇜󱇝󱇞󱂞󱉔󱈕󱄆
󱀓󱀚󱀛󱂫󱃳󱈁󱈙
󱂪󱈂󱀗󱂲󱃱󱄾󱇶󱇷󱇸
󱀘󱀙󱇴󱈆
󱀡󱀢󱀬󱀭󱀃󱂭󱂮󱂴󱃸󱃼󱅂󱅏󱈇
󱀞󱀟󱀠󱃵󱃶󱃷󱄹󱄺󱄻󱄼󱄽󱈦
󱀤󱈎󱀥󱂯󱂰󱈢󱂱󱈋󱃹󱃺󱈫󱅄󱉌
󱃋󱃌󱃠󱃡󱃢󱃤󱃥󱅃
󱀳󱀴󱈺
󱀵󱄁󱉈󱅘󱉉󱅛󱅜󱅝󱅞󱅟󱂢󱅢󱈯󱉏󱅫󱅬󱅭󱅮󱅯󱅰󱅱󱅲󱅳󱅼󱅙󱅚󱀶󱂹󱀷󱀺󱈨󱈝󱄄󱀽󱀾󱂼󱀿󱁀󱁁󱁂󱀐󱀒󱀔󱁏󱅻󱁐󱂵󱂶󱂷󱂸󱂽󱂾󱂿󱃾󱃿󱄀󱇣
󱀣󱀫󱈡󱄿󱅀󱅁
󱉊󱉐󱉭
󱁃󱁄󱃲
󱁅󱄅󱁆󱁇󱁉󱄇󱅴󱄈󱁊󱁍󱃀󱃁󱃂󱃃󱄉
󱃆󱃇󱃈󱃉󱃊󱈈󱃏󱈏󱃎󱈮
󱀁󱂒󱄫󱇒󱇓󱇚󱂝
󱇔󱇕󱇖󱇗
󱁋󱁌󱅵󱅶󱅷󱅸󱁚󱁖󱁗󱈓󱁘󱄍󱄎󱄏󱃐󱃑󱁙󱁝󱁞󱁟󱁠󱄐󱇑󱁡󱁢󱁣󱁤󱁥󱁦󱀄󱀑󱆌󱆍󱆎󱆏󱆐󱆑󱆕󱆖󱆗󱆘󱆙󱆚󱆞󱆟󱆩󱆷󱆸󱇲󱆺󱆻
󱁵󱀂󱆲󱆳󱆴󱆹󱆵󱆶󱁷󱁸󱁹󱉂󱈾󱆋󱇙󱆒󱆓󱆔󱁺󱁻󱁼󱁽󱁾󱁿󱂀󱂁󱂂󱂃󱂄󱂅󱈛󱈐󱃣󱂆󱄠󱄡󱈞󱀀󱃍󱈊󱆠󱄝󱄞󱄟
󱆯󱆰󱆱
󱄌
󱃛󱈩
󱃜󱈃󱃝
󱃞󱁴
󱅽󱅾
󱇰󱇱
󱇆󱈹󱈻󱉬
󱄊󱈟
󱉋
󱈄
󱇋
󱇏
󱆝
󱃽
󱄲 󱄳 󱄴
󱇛
󱃟󱄜󱁶󱅗󱇍
󱅹󱅺
󱉍
󱀦󱀧
󱈲󱈶
󱅎󱀨
󱁎
󱀮󱅐󱉤󱉥󱀯
󱄛󱄢
󱀰󱅑
󱅆󱅇󱅈󱅍󱀪
󱀱󱀲󱅒󱅓󱅔󱅕󱅖
󱂋󱂌󱇟󱇠󱇡
󱂟󱂠󱂡󱅅
Punctuation
󱂣󱂤󱂦󱂧󱃯󱄶󱉅󱉖
󱇽󱂩󱀩
󱂳
󱈀
󱀎
󱉁
󱀏󱃄󱄋󱁑󱁒󱉎
󱃅󱁓󱁕󱆅󱆆󱆇󱆈󱆉󱆊󱆁󱈰󱅿󱆀󱆂󱆃󱆄
󱃙󱃚
󱁈
󱉕
󱇥
󱉄󱉑󱉇
(0)
󱉗
(1)
󱂨󱃰󱄵
(2)
󱃻󱇳󱈷󱈴󱇺󱉘󱉚󱉝󱉡
󱉜󱉟
(3)
󱄰󱄱󱉛󱉢
󱁜󱄷󱉠
(4)
󱉣
󱉙
(6)
󱉞
(7)
󱇻
            """
      }

revisionSyllabary = 
  { id = "splitting"
  , name = "Jedes Zeichen einzeln"
  , syllabary =
      """
󱁾󱁿 ##097 I2
󱀥󱈋 ##097 III4
󱂜󱃬 ##097 IV7
󱈲󱈶 ##097 V3
󱈱󱃬 ##097 VIII8
󱃬󱂒 (##097 IV7,XV7,XVI7)
󱀤󱈋 ##097 IX6
󱀤󱈋 ##097 XI11
󱀤󱈋 ##097 XII4
󱈲󱈶 ##097 XIV3
󱁾󱁿 ##097 XV1
󱃬󱂏 (##097 IV7,XIX2)
󱂀󱁿 ##097 XXII6
󱂈󱄤 ##097 XXIV9
󱄤󱂈 ##097 XXVI2
󱂀󱂂 ##097 XXVI3
      """
  }      

syllabaries : List SyllabaryDef
syllabaries =
    [ initialSyllabary
    , { id = "splitting", name = "Jedes Zeichen einzeln"
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


tagsToGroup { id, tags, dir, text } = { id = id, group = Maybe.withDefault "NOGROUP" (List.head tags), dir = dir, text = String.trim text }

-- Using Douros 2014 as base
fragments : List FragmentDef
fragments = List.map tagsToGroup
    [ { id = "##001.A"
      , tags = [ "ENKO", "Atab", "CM0" ]
      , dir = UNKNOWN, text =
        """
󱀀󱀁󱀂󱀃󱀄󱀅󱀆󱀈
󱀊󱀋󱀌󱀍󱀎󱀏󱀐
󱀑󱀒󱀓󱀔󱀕󱀖
        """
      , inline = []
      , notes = ""
      }
    , { id = "##001.B"
      , tags = [ "ENKO", "Atab", "CM0" ]
      , dir = UNKNOWN, text =
        """
󱀇󱀉
        """
      , inline = []
      , notes = ""
      }
    , { id = "##002"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈪󱂎󱆲󱂧󱀱
        """
      , inline = []
      , notes = ""
      }
    , { id = "##003"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆳󱁖󱀤󱇸
        """
      , inline = []
      , notes = ""
      }
    , { id = "##004"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅹󱀾󱀳󱂧󱆌
        """
      , inline = []
      , notes = ""
      }
    , { id = "##005"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁘󱇛󱇉
        """
      , inline = []
      , notes = ""
      }
    , { id = "##006"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂏󱀛󱀬󱁖󱂧󱀹
        """
      , inline = []
      , notes = ""
      }
    , { id = "##007"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁊󱂖󱈫󱅺
        """
      , inline = []
      , notes = ""
      }
    , { id = "##008"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀾󱀹󱂈
        """
      , inline = []
      , notes = ""
      }
    , { id = "##009"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##010"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##011"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈬󱁉󱀡
        """
      , inline = []
      , notes = ""
      }
    , { id = "##012"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇛󿊀󿊀󿊀󱆲󱁟󱀞󱇊
        """
      , inline = []
      , notes = ""
      }
    , { id = "##013"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆬󱅠󱁘󱇸󱇛󱅡󱇸
        """
      , inline = []
      , notes = ""
      }
    , { id = "##014"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁳󱂉󱂧󱄺
        """
      , inline = []
      , notes = ""
      }
    , { id = "##015"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀛󱂄󱁵󱀼󿊀󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##016.A"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇍󱁮󱀛󱇀󱉖󿊀󱇸
        """
      , inline = []
      , notes = ""
      }
    , { id = "##016.B"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂧󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##018.A"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅹󱀾󱀳󱂧󱅒
        """
      , inline = []
      , notes = ""
      }
    , { id = "##018.B"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##020"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁒󱁠󱂊󱂦󱀫󱀚
        """
      , inline = []
      , notes = ""
      }
    , { id = "##021"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇦󱁎󱇾󱂧󱄹󱆣󱇧󱀻󱀜󱂧
        """
      , inline = []
      , notes = ""
      }
    , { id = "##022"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂦󱀻󱀞󱆾
        """
      , inline = []
      , notes = ""
      }
    , { id = "##023"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅣󱇽󱂒
        """
      , inline = []
      , notes = ""
      }
    , { id = "##024"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁮󱀚󱆿󱂛󱁮󱂦󱆼
        """
      , inline = []
      , notes = ""
      }
    , { id = "##025"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅢󱁵󱀣󱇳󱀵󱁭󱅆󱅃󱁭
        """
      , inline = []
      , notes = ""
      }
    , { id = "##026"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆭󱆍󱀤󱇼
        """
      , inline = []
      , notes = ""
      }
    , { id = "##027"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀮󱀰󱄿󱂦󱉤
        """
      , inline = []
      , notes = ""
      }
    , { id = "##028"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱂈󱁃
        """
      , inline = []
      , notes = ""
      }
    , { id = "##029"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀫󱈁󱇁󱂦󱂐
        """
      , inline = []
      , notes = ""
      }
    , { id = "##030"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀯󱀰󱀣󱂧󱁗󱅿󱁃󱂊
        """
      , inline = []
      , notes = ""
      }
    , { id = "##031"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱀸󱂊󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##032"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱅤󱁬󱁽
        """
      , inline = []
      , notes = ""
      }
    , { id = "##033"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁾󱁵󱀷
        """
      , inline = []
      , notes = ""
      }
    , { id = "##034"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱂇󱂀󱉖󱀹
        """
      , inline = []
      , notes = ""
      }
    , { id = "##035"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅄󱆝󱂧󱀛󱂓󱁉󱁘
        """
      , inline = []
      , notes = ""
      }
    , { id = "##036"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆴󱇂󱂦
        """
      , inline = []
      , notes = ""
      }
    , { id = "##037"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇨󱆁󱇃󱂧󱀵󱀯
        """
      , inline = []
      , notes = ""
      }
    , { id = "##038"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆂󱀰󱂦󱁒
        """
      , inline = []
      , notes = ""
      }
    , { id = "##039"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆀󱀯󱁻󱂀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##040"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇩󱆤󱁻
        """
      , inline = []
      , notes = ""
      }
    , { id = "##041"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁶󱂒󱂎󱀵󱂧󱀛
        """
      , inline = []
      , notes = ""
      }
    , { id = "##042"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱁻󱂁󱂞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##043"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱀵󱆡󱁻󱉖󱄸
        """
      , inline = []
      , notes = ""
      }
    , { id = "##044"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇿󱁗󱅇󱉖󱁗
        """
      , inline = []
      , notes = ""
      }
    , { id = "##045"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱂓󱂊󱉖󱂞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##046"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁧󱇜󱀤󱅤󱉖󱂞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##047"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅽󱁟󱇃󱅓󱂛
        """
      , inline = []
      , notes = ""
      }
    , { id = "##048"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁮󱀚󱂌󱉖󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##049"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂔󱁭󱀬󱁥󱂧󱀣
        """
      , inline = []
      , notes = ""
      }
    , { id = "##050"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁄󱈭󱁗
        """
      , inline = []
      , notes = ""
      }
    , { id = "##051"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅾󱈮󱂋󱂧󱀮
        """
      , inline = []
      , notes = ""
      }
    , { id = "##052"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁧󱂛󱁤󱉖󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##053"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇝󱂛󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##054"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱀥󱁵󱁻󱅐
        """
      , inline = []
      , notes = ""
      }
    , { id = "##055"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱂗󱂋󱉖󱁍
        """
      , inline = []
      , notes = ""
      }
    , { id = "##056"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀻󱀬󱁬󱂦󱁵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##057"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱁵󱂌󱂧󱄼
        """
      , inline = []
      , notes = ""
      }
    , { id = "##058"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀞󱀹󱁵󱇄󱂦󱆃
        """
      , inline = []
      , notes = ""
      }
    , { id = "##059"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆯󱂊󱂦󱁖
        """
      , inline = []
      , notes = ""
      }
    , { id = "##060"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱀞󱁤󱂄󱆡
        """
      , inline = []
      , notes = ""
      }
    , { id = "##061"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂧󱀞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##062"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱅍󱂦󱁆
        """
      , inline = []
      , notes = ""
      }
    , { id = "##063"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁾󱂓󱇃
        """
      , inline = []
      , notes = ""
      }
    , { id = "##064"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅥󱆋󱅈󱀝󱂑󱁾󱈩
        """
      , inline = []
      , notes = ""
      }
    , { id = "##065"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱀵󱁝
        """
      , inline = []
      , notes = ""
      }
    , { id = "##066"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆔󱅅󱂦󱆔󱅀󱂃󱂀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##067"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀘󱅗󱆡󱁺󱂦󱁢
        """
      , inline = []
      , notes = ""
      }
    , { id = "##068"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂊󱂦󱅀󱁭󱀚
        """
      , inline = []
      , notes = ""
      }
    , { id = "##069"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱀵󱁭󱁻󱂧󱂞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##070"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁣󱀜󱀶󱂧󱁴󱀣󱀥󱁭
        """
      , inline = []
      , notes = ""
      }
    , { id = "##071"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁸󱁺󱂁󱂦󱁹
        """
      , inline = []
      , notes = ""
      }
    , { id = "##072"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱇙󱂊󱂦󱀻
        """
      , inline = []
      , notes = ""
      }
    , { id = "##073"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##074"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##075"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱁇󱀪󱁩󱂦󱀜
        """
      , inline = []
      , notes = ""
      }
    , { id = "##076"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁢󱀝󱀶󱂧󱁕
        """
      , inline = []
      , notes = ""
      }
    , { id = "##077"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆄󱁬󱅑󱂧󱆥
        """
      , inline = []
      , notes = ""
      }
    , { id = "##078"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈯󱀣
        """
      , inline = []
      , notes = ""
      }
    , { id = "##079"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂏󱀟󱀵󿊀󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##080"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁴󱇅󱂦󱇞󱁍󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##081"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁶󱂐󱁞󱀢󱂦󱀹
        """
      , inline = []
      , notes = ""
      }
    , { id = "##082"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀩󱀶󱇪󱂊󱂦󱂛
        """
      , inline = []
      , notes = ""
      }
    , { id = "##083"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂞󿊀󿊀󱂦󱂞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##084"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈪󱀥󱀞󱀥
        """
      , inline = []
      , notes = ""
      }
    , { id = "##085"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇌󱅃󱁵󱁻󱂦󱂛
        """
      , inline = []
      , notes = ""
      }
    , { id = "##086"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀞󱀞󱀚󱂍󱈰
        """
      , inline = []
      , notes = ""
      }
    , { id = "##087"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁝󱀰󱀤󱁑
        """
      , inline = []
      , notes = ""
      }
    , { id = "##088"
      , tags = [ "HALA", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁾󱂗󱂊󱁵󱀣
        """
      , inline = []
      , notes = ""
      }
    , { id = "##089"
      , tags = [ "HALA", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁣󱀜󱅚󱂧󱁰
        """
      , inline = []
      , notes = ""
      }
    , { id = "##090"
      , tags = [ "KITI", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆵󱀚󱅔󱆷
        """
      , inline = []
      , notes = ""
      }
    , { id = "##091"
      , tags = [ "KITI", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱅁󱂔󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##092"
      , tags = [ "ATHI", "Adis", "CM1", "CGr", "lisible" ]
      , dir = UNKNOWN, text =
        """
󱆕󱅦󱀚󱄻
󱉘󱉙󱉚
        """
      , inline = []
      , notes = ""
      }
    , { id = "##093"
      , tags = [ "ENKO", "Aost", "CM1", "rev", "lisible" ]
      , dir = UNKNOWN, text =
        """
%󱂡󱉖󱉛󱉜
%󱂢󱉝󱉞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##094"
      , tags = [ "ENKO", "Aost", "CM1", "lisible", "posdet" ]
      , dir = LTR, text =
        """
󱇆󱂔_󱀛=󿊀󿊀󿊀%
󱅻󱂦󱆅=󱇰󱂧󱂒󱅴%
󱁭_󱂧󱅧󱅻󱂧󱁒󱀰_1%
%󿊀%
%󿊀󱀜=󱁧2󱂓=%
        """
      , inline =
        [ "Evtl. 󱂒 oder 󱁓"
        , "Evtl. 󱂓 gedreht"
        ]
      , notes = "LTR aufgrund Bündigkeit mit Dreicksöffnung links vgl. Ferrara 2013:51"
      }
    , { id = "##095"
      , tags = [ "ENKO", "Apes", "CM1", "lisible", "rev" ]
      , dir = UNKNOWN, text =
        """
󱂋󱆳󱀧󱂦󱀜󱂘󱆖
        """
      , inline = []
      , notes = ""
      }
    , { id = "##096"
      , tags = [ "ENKO", "Apla", "CM1", "lisible" ]
      , dir = UNKNOWN, text =
        """
%_󱀚󱂧󱂐%
        """
      , inline = []
      , notes = ""
      }
    , { id = "##097"
      , tags = [ "ENKO", "Arou", "CM1", "lisible", "posdet-pal", "rev" ]
      , dir = LTR, text =
        """ 
󱁊󱁿󱂒󱀵󱁩󱀵 󱂨
󱆦󱁵󱂦󱁵󱂉󱂂󱀵󱂩󱂓
󱀠󱂩󱁘󱈋q󱁫󱀪󱀵󱂩󱂛
󱂏=󱁘=󱀚=󱂦󱀻󱅏󱃬󱉩
󱀵󱂩=󱈶=󱂩_󱁵󱁱=󱂍󱂦
󱂓󱀧󱀶󱀞󱀪󱀵󱂩󱀞󱂩
󱀺󱅏󱂩󱂧󱀞󱂩󱁓_󱁘󱀪
󱀵󱂩󱁵󱂩󱀪󱀸󱂦󱃬󱂩
󱁵󱂉󱂂󱀵󱂩󱈋󱁫󱀺
󱁱󱂩󱀛󱂁󱀸󱂦󱁏󱁏
󱉦󱂩󱁊󱈋󱁱󱀠󱀳󱂩󱁊
󱀳󱂩󱂕󱀧󱀶󱂖󱀻_󱁪
󱀵󱂩󱀛󱈋󱂂󱅏󱀠󱀳
󱁑󱀺󱈶q󱆧󱀹󱀵󱀛
󱁿󱀹󱂦󱁑󱁉󱉩󱂒
󱀸󱁱󱂒󱈳󱁩󱀸󱂒
_󱁩󱀛󱁿󱀸󱁍󱀳󱅏󱂦
_󱀳󱀞󱂕󱅘󱁘󱈴󱂓󱂒
󱀸󱂏󱉧󱅏󱂦󱁅󱀳
󱈵󱀵󱂩q󱆦󱉩󱂩󱈶󱀵
󱁩󱀠󱀳󱂩󱁓󱀹󱀛󱀵
󱀻󱀜󱀸󱀛_󱂍=󱂈󱀵
󱀛󱁿󱀸󱂦󱁑_󱁿=󱂊󱀵
󱀹󱀛󱂍󱀠󱂦󱈷󱀞󱁘󱄤
_󱀹󱂒󱁩󱁵󱁱_󱂍󱂦󱀠󱀜
󱁵󱂈󱂂󱀵󱁩󱀺󱁖
󱁩󱀹󱂒󱁩󱁵󱁱_󱂍󱂦
        """
      , inline = []
      , notes = ""
      }
    , { id = "##098"
      , tags = [ "KALA", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂔󱀶󱂃󱂦󱂔󱁭󱁾󱂍󱀵
󱁾󿊀󱁓󱂦󱈸󱈹󱂧󱂔󱂄
󱁁󱂃󱂦󱂐󱁇󱂦󱁍󱁾󱁽
󱁇󱁃󱂦󱆈󱀗󱂦󱂋󱀵󱂃󱀗
󱁍󱁽󱂦󱁇󱁭󱆹󱈺󱂦
󱆈󱀮󱆹󱁃󱁘󱂦󱁮󱆹󱀵
󿊀󱁽󱂦󱀚󱈻󱁵󿊀󿊀󿊀
󱁇󿊀󱀵󱂦󿊀󱁭󱁾󿊀󿊀
󿊀󿊀󱁑󱂦󱁇󱆹󿊀󿊀󿊀
󱆆󱀵󿊀󱁖󱁾󱁽󱂦󱂞
󱅿󱂀󱁬󱂦󱀻󱁽󱀗󱀞
󱁆󱂃󱀵󱁭󱀵󱁵󱁽
󱁮󱀳󱁓󱀸󱁒󱂦󱂔󱀶󱂃
󱈼󱁽󱂃󱂦󱂐󱁃󱁭
󱂜󱁵󱁁󱁬󱂦󱀥󱁍󱁒
󿊀󱈽󱂦󱁖󱀵󱂦󿊀󿊀󿊀
󿊀󱂦󱀶󿊀󱂝󿊀󿊀
󱂔󱀷󱂃󱂦󿊀󱀮󱁃󿊀󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##099"
      , tags = [ "KALA", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󱁞󱀚󱂧󱆰
󱁑󱁁󱅨󿊀
󿊀󿊀󿊀󿊀󿊀󱁒
        """
      , inline = []
      , notes = ""
      }
    , { id = "##100"
      , tags = [ "KALA", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
󱁾
󱇎
󱂍󿊀
󱁆
󱂔󱀶
󱂀󿊀󿊀add brueche
        """
      , inline = []
      , notes = ""
      }
    , { id = "##101"
      , tags = [ "KALA", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂔󱀶󱂃
󱁓󱀸󱈫󱀚
󱂐󱁱󱀵󿊀
󱇻
        """
      , inline = []
      , notes = ""
      }
    , { id = "##102"
      , tags = [ "KALA", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀶󱂃󱂦󱂔󱁭󿊀󿊀
󿊀󱁓󱉀󱁧󱁭
󿊀󱁁󱁢󱇳󱀭󱉩󿊀󱀻
󱂍󱀤󱂦󱀣󱁪󱇴
󱀵󱈾󱁀󱈿󱁭󱂎󱁀󱉀
󱁅󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##103"
      , tags = [ "PSIL", "Asta", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁚󱀙󱀥󱁭
        """
      , inline = []
      , notes = ""
      }
    , { id = "##104"
      , tags = [ "ALAS", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆨󱀵󿊀󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##105"
      , tags = [ "ARPE", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆇󱄻󱂊󱂣󱆎󱂈󱈨
        """
      , inline = []
      , notes = ""
      }
    , { id = "##106"
      , tags = [ "ATHI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅶󱁿󱁿󱀚󱈫󱁩󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##107"
      , tags = [ "ATHI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉁󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##108"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅛󱄽󱅩󱅜󱇈
        """
      , inline = []
      , notes = ""
      }
    , { id = "##109"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁿󱀮󱁵󱂦󱂐󱁮󱀚󱂋󱂦󱂕󱇆
        """
      , inline = []
      , notes = ""
      }
    , { id = "##110"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂦󱅪󱆩󱁢󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##111"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱄽󱀵󱀬󱀵󱂦󱂛
        """
      , inline = []
      , notes = ""
      }
    , { id = "##112"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇏󱁵󱁪󱂁󱇇󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##113"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇐
󱅕
        """
      , inline = []
      , notes = ""
      }
    , { id = "##114"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵
󱄷
        """
      , inline = []
      , notes = ""
      }
    , { id = "##115"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵
󱆶
        """
      , inline = []
      , notes = ""
      }
    , { id = "##116"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁊change
󱀝doubt
        """
      , inline = []
      , notes = ""
      }
    , { id = "##117"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑
󱉂evtl zwei z
        """
      , inline = []
      , notes = ""
      }
    , { id = "##118"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆗󱇳󱆘
        """
      , inline = []
      , notes = ""
      }
    , { id = "##119"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀶
󱅵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##120"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂦󱂛
        """
      , inline = []
      , notes = ""
      }
    , { id = "##121"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱂧󱀵󱂧󱀳
        """
      , inline = []
      , notes = ""
      }
    , { id = "##122"
      , tags = [ "HALA", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅝
󱅞
        """
      , inline = []
      , notes = ""
      }
    , { id = "##123"
      , tags = [ "IDAL", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅼󱅼󱆜
        """
      , inline = []
      , notes = ""
      }
    , { id = "##124"
      , tags = [ "IDAL", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁍󱁢󱁟󱆸
󿊀󿊀󱀵mit oberer z󱂃
        """
      , inline = []
      , notes = ""
      }
    , { id = "##125"
      , tags = [ "KALA", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁋󱀝ligatur
        """
      , inline = []
      , notes = ""
      }
    , { id = "##126"
      , tags = [ "KALA", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆞
󱁵
󱀵mit oberer z
        """
      , inline = []
      , notes = ""
      }
    , { id = "##127"
      , tags = [ "KATY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅷
󱅫
󱈦
        """
      , inline = []
      , notes = ""
      }
    , { id = "##128"
      , tags = [ "KATY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁜󱁙󱁶󱈧
        """
      , inline = []
      , notes = ""
      }
    , { id = "##129"
      , tags = [ "KATY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆺
󱆢
        """
      , inline = []
      , notes = ""
      }
    , { id = "##130"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀝󱁉󱂋󱀵󱆈
        """
      , inline = []
      , notes = ""
      }
    , { id = "##131"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱅟nonver
        """
      , inline = []
      , notes = ""
      }
    , { id = "##132"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅲󱅬
        """
      , inline = []
      , notes = ""
      }
    , { id = "##133"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅭󱅳
        """
      , inline = []
      , notes = ""
      }
    , { id = "##134"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅳󱅮
        """
      , inline = []
      , notes = ""
      }
    , { id = "##135"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱇷󱇣
        """
      , inline = []
      , notes = ""
      }
    , { id = "##136"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵plus ein z
        """
      , inline = []
      , notes = ""
      }
    , { id = "##137"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂦󱇟rhomb buendig
        """
      , inline = []
      , notes = ""
      }
    , { id = "##138"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂧󿊀
        """
      , inline = []
      , notes = ""
      }
    , { id = "##139"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱉬
        """
      , inline = []
      , notes = ""
      }
    , { id = "##140"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅯󱁭
        """
      , inline = []
      , notes = ""
      }
    , { id = "##141"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
irgend
󱀵
󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##142"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      , inline = []
      , notes = ""
      }
    , { id = "##143"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂦󱇠change
        """
      , inline = []
      , notes = ""
      }
    , { id = "##144"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱄾󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##145"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉟󱁋󱉠
        """
      , inline = []
      , notes = ""
      }
    , { id = "##146.A"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀴
        """
      , inline = []
      , notes = ""
      }
    , { id = "##146.B"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      , inline = []
      , notes = ""
      }
    , { id = "##147"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂧󱇡change
        """
      , inline = []
      , notes = ""
      }
    , { id = "##148"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂕change
󱅖
        """
      , inline = []
      , notes = ""
      }
    , { id = "##149"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁡
        """
      , inline = []
      , notes = ""
      }
    , { id = "##150"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛change󱁡
        """
      , inline = []
      , notes = ""
      }
    , { id = "##151"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁡nonver
        """
      , inline = []
      , notes = ""
      }
    , { id = "##152"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁠nonver
        """
      , inline = []
      , notes = ""
      }
    , { id = "##153"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅸
󱆮
        """
      , inline = []
      , notes = ""
      }
    , { id = "##154"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂓󱇈
        """
      , inline = []
      , notes = ""
      }
    , { id = "##155"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      , inline = []
      , notes = ""
      }
    , { id = "##156"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib󱀵
        """
      , inline = []
      , notes = ""
      }
    , { id = "##157"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁋󱆉󱀵󱂦󱁒󱀻󱁧󱀵󱂦
        """
      , inline = []
      , notes = ""
      }
    , { id = "##158"
      , tags = [ "MYRT", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑󱁾change󱀾󱇫
        """
      , inline = []
      , notes = ""
      }
    , { id = "##159"
      , tags = [ "MYRT", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󿊀changed
        """
      , inline = []
      , notes = ""
      }
 , { id = "##160"
      , tags = [ "TOUM", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂧󱅰󿊀
󱇑
󱅍
󱂚󱀰󿊀nonver unless l 1
        """
      , inline = []
      , notes = ""
      }
 , { id = "##161"
      , tags = [ "KITI", "Iins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇢󱂓󱀵
󱁵󱂇󱂂󱂧󱂛󱀵󱁝󱀳󱀵󱂣󱂐
        """
      , inline = []
      , notes = ""
      }
 , { id = "##162"
      , tags = [ "KITI", "Iins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇒󱀛󱁘󱆟
󱀵󱂆󱂌󱂦󱀵plus numeralia
        """
      , inline = []
      , notes = ""
      }
 , { id = "##163.A"
      , tags = [ "KITI", "Ipla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆱󱇬󱇤󱆙󱁭invert
        """
      , inline = []
      , notes = ""
      }
 , { id = "##163.B"
      , tags = [ "KITI", "Ipla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇓󱁺󱂧󱂐󱁮󱀚󱉦󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##164"
      , tags = [ "ENKO", "Mbij", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉃󱉄󱉅󱉆󿊀󱉇󿊀󿊀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##165"
      , tags = [ "KALA", "Mbij", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂈󱇭󱁁󱆏invert poss
        """
      , inline = []
      , notes = ""
      }
 , { id = "##166"
      , tags = [ "KALA", "Mbij", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂈󱂛󱁁󱆐invert poss
        """
      , inline = []
      , notes = ""
      }
    , { id = "##167"
      , tags = [ "KITI", "Mexv", "CM1" ], dir = UNKNOWN, text =
        """
󱀵󱂧󱁷irgend
        """
      , inline = []
      , notes = ""
      }
   , { id = "##168"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀮󱀰󱀵󱂧󱇚󱁭󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##169"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇲󱂦unsicher
󱁟󱁶
        """
      , inline = []
      , notes = "ENKO?"
      }
 , { id = "##170"
      , tags = [ "PPAP", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁢󱀦󱀶󱀚󱀨
        """
      , inline = []
      , notes = ""
      }
 , { id = "##171"
      , tags = [ "PPAP", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      , inline = []
      , notes = ""
      }
 , { id = "##172"
      , tags = [ "PPAP", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈀󱂌nonver keine schrift
        """
      , inline = []
      , notes = ""
      }
 , { id = "##173"
      , tags = [ "PYLA", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱀳eckig nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##174"
      , tags = [ "ENKO", "Mlin", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇔󱂧󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##175"
      , tags = [ "ENKO", "Mlin", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇕󱉈
󱇖󱁈󱀵󱂠󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##176"
      , tags = [ "ENKO", "Mlin", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇗󱉖󱉉
        """
      , inline = []
      , notes = ""
      }
 , { id = "##177"
      , tags = [ "PYLA", "Mlin ", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀬
󱀵
󱀸duktus!
󿊀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##178"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂓󱁭󱆛
        """
      , inline = []
      , notes = ""
      }
 , { id = "##179"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂚󱀚󱅀󱀵󱂧󱀚󱀚󱂋󱂧󱀞󱅇
        """
      , inline = []
      , notes = ""
      }
 , { id = "##180"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀻󱁩󱀥󱂀󱀵󱂧󱉥󱀰letztes
        """
      , inline = []
      , notes = ""
      }
 , { id = "##181"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂆󱄿󱀮󱅙󱂧󱁊
        """
      , inline = []
      , notes = ""
      }
 , { id = "##182"
      , tags = [ "ENKO", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱂚󱆚󱀵󱂧󱉡󱉢zweites
        """
      , inline = []
      , notes = ""
      }
 , { id = "##183"
      , tags = [ "ENKO", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂚󱀚󱄿󱀵󱂦󱇱zweites
        """
      , inline = []
      , notes = ""
      }
 , { id = "##184"
      , tags = [ "MYRT", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁋󱉖󱂔󱉪
        """
      , inline = []
      , notes = ""
      }
 , { id = "##185"
      , tags = [ "MYRT", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁌󱂓󱉫
        """
      , inline = []
      , notes = ""
      }
 , { id = "##186"
      , tags = [ "PPAP", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁷󱀞󱁷󱆻󱀵zweites
        """
      , inline = []
      , notes = ""
      }
 , { id = "##187"
      , tags = [ "ENKO", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅎󱀮󿊀󿊀󿊀󱀻ergaenzen
        """
      , inline = []
      , notes = ""
      }
 , { id = "##188"
      , tags = [ "KITI", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂅󱀿󿊀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##189"
      , tags = [ "PPAP", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂧󱂒change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##190"
      , tags = [ "PPAP", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇥󱉖󱀵check
        """
      , inline = []
      , notes = ""
      }
 , { id = "##191"
      , tags = [ "KALA", "Ppla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉖󱂡
        """
      , inline = []
      , notes = ""
      }
 , { id = "##192"
      , tags = [ "KALA", "Ppla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱆊󱇮zweites
        """
      , inline = []
      , notes = ""
      }
 , { id = "##193"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱀸󱁵󱂧󱁫󱁩󱀵checken
        """
      , inline = []
      , notes = ""
      }
 , { id = "##194"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁧󱀨󱉖󱉊󱉋
        """
      , inline = []
      , notes = ""
      }
 , { id = "##195"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑
󱀚 turn both
        """
      , inline = []
      , notes = ""
      }
 , { id = "##196"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉌󱉍󱁦󱀜check and turn
        """
      , inline = []
      , notes = ""
      }
 , { id = "##197"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇷󱂙󱇋󱀵󱇶
        """
      , inline = []
      , notes = ""
      }
 , { id = "##198"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆠󱉎󱉎mut zur luecke
        """
      , inline = []
      , notes = ""
      }
 , { id = "##199"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆪󱆫
󱅱
        """
      , inline = []
      , notes = ""
      }
 , { id = "##200"
      , tags = [ "ENKO?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀞󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##201"
      , tags = [ "HALA", "Psce ", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁘󱁿󱁁󱁵󿊀checken
        """
      , inline = []
      , notes = ""
      }
 , { id = "##202"
      , tags = [ "KOUR", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉏󱀬󱇯󱂊󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##203"
      , tags = [ "PARA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁑󱀚󱅂󱁩
        """
      , inline = []
      , notes = ""
      }
 , { id = "##204"
      , tags = [ "PYLA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆑󱆽󱁀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##205"
      , tags = [ "SALA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉐󱇯
        """
      , inline = []
      , notes = ""
      }
 , { id = "##206"
      , tags = [ "PPAP", "Vsce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇘󿊀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##207.A.left"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱂷󱂯󱃯
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃒󱃐󱃝󱃯󱂺󱃊
󿊀󿊀󱃙󱃏󱃍󱂸󱃯󱈃󱂪󱃯󱂫󱃆󱂹󱃯󱃃󱂹
󱈄󱂬󱃟󱃯󱂳󱃩󱃯󱃜󱂯󱂲󱃙󱃯󱂺󱈂󱂴󱃯󱂶󱂸
󱃟󱃩󱃇󱃯󱃃󱃚󱃯󱃮󱃏󱃯󱃬󱃔󱃇󱃯󱈂󱈂󱂱󱃇
󱃭󱂲󱃠󱃯󱃃󱃚󱃘󱃯󱈃󱃎󱂭󱂴󱃯󱃮󱃇󱂴󱃯󱃃󱂾󱃇
󱃫󱃙󱂫󱃉󱃯󱃋󱃙󱃩󱂵󱃯󱃏󱂾󱃧󱃏󱃯󱂵󱂯󱃍󱃋󱃙󱃰
󱂶󱂬󱃙󱃯󱃜󱃖󱃯󱂱󱃩󱂵󱃯󱃙󱃠󱃋󱃋󱃯󱃜󱂾󱂾󱂬
󱂻󱂴󱂶󱃯󱂪󱂼󱃭󱃡󱃯󱂾󱃖󱃠󱃯󱃂󱃐󱃉󱃐󱃖
󿊀󱂾󱃮󱃯󱂷󱃇󱃑󱃯󱃫󱂫󱃯󱂸󱂾󱃮󱈅
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃭󱃛󱂬󱈑󱃯󱃏󱃚󱃯󿊀󱂽󱃩󱃇󱂵󱃯󱂶󱃒󱂯
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃠󱈒󱃡󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂭󱃢󱃯󱃝󱂶󱈆
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱂺󱂻󱃢󱃯󱂾󱃎󱃉󱃐󱃔
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱈡󱃙󱃯󱃮󱂽󱂵󱃯󱃏󱂵󱃇󱃎󱃦
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂪󱃯󱂹󱃂󱂻󱃯󱃃󱃟󱃎󱃦
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂺󱃯󱃜󱂪󱃌󱃯󱃅󱂾󱈍󱂯󱃔
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃙󱂽󱃯󱃮󱃟󱂴󱃯󱃊󱂷󱃢󱃙󿊀
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃔󱃯󱂶󱃛󱃩󱂵󱃯󱃉󱃐󱂻󱃡
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂫󱃀󱃔󱃯󱃃󱃮󱂯󱃯󱃏󱃣󱃔
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃫󱃙󱃛󱃯󱃜󱂬󱃎󱃦nonver?
        """
      , inline = []
      , notes = ""
      }
 , { id = "##207.A.right"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀
󱃄
󱃄󱃙󱂯
󱂺󱃦󱃯󱂹
󱂫󱃙󱃯󱃅
󱃭󱃇󱃯󱃠
󱃔󱃖󱃐󱃯󱂳
󱃃󱃟󱃯󱂻󱃇
󱂻󱈇󱃮󿊀󿊀󿊀󱃗
󱃈󱂾󱃯󱈈󱂯󱃅
󱃛󱂬󱃖󱃯󱃟
󱃫󱂻󱃟󱃯󱃜nonver?
        """
      , inline = []
      , notes = ""
      }
 , { id = "##207.B.left"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃬󱂲󱂹󱃯󱂷󱃐󱂻󱃝󱃯󱃫󱃀󱃙󱃟
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂽󱂷󱃤󱃩󱃯󱃫󱂺󱂴󱃯󱃫󱃙󱂻󱃔
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃠󱃙󱃯󱃃󱂵󱂵󱃯󱃭󱂿󱃗󱂻
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃄󱃙󱃯󱃇󱂿󱃅󱃆󱃙
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃜󱃘󱃐󱃙󱃯󱂶󱃔󱂵󱃯󱃏󱃖󱃯󱂯󱃭
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃬󱃠󱃟󱃯󱃅󱂾󱃭󱂯󱃔
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃖󱃯󱂳󱈍󱂻󱃯󱂾󱂵󱂵󱃯󱃟󱂽󱃩󱃯󱃜󱈉󱃐󱃔
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂻󱃡󱃯󱂬󱃮󱂻󱃯󱃂󱃔󱃁󱃯󱂻󱃠󱂻
󱃜󿊀󱃙󱃯󱃫󱂴󱃯󱃅󱃓󱈊󱃯󱃃󱃠󱃠󱃅󱃦󱃯󱃜󱃚󱂪
󱃜󱃖󱂱󱃙󱂯󱃭󱃯󱃭󱂲󱃠󱃯󱂺󱂫󱂯󱃯󱃛󱂺󱂫󱃙󱃰
󱂯󱃝󱃅󱃯󱃂󱃩󱃯󱃫󱃇󱃯󱃜󱂼󱃇󱃯󱂺󱃉󱂾󱈒
󱃜󱂻󱃯󱃠󱃒󱂼󱃭󱃁󱃯󱃫󱃀󱂻󱃯󱂻󱂻󱃯󱂾
󱃛󱃧󱃝󱃯󱂺󱈂󱃟󱃯󱃃󱂳󱃩󱂵󱃯
󱃜󱂯󱃄󱃖󱃯󱃟󱃅󱃇󱃯󱃫󱂴󱃯󱃫
󱂶󱃅󱃖󱃯󱃟󱂽󱃩󱃯󱂭󱂺󱃯
󱂶󱂫󱃛󱃯󱃫󱃀󱃧󱃯󱃫󱃚
󱃜󱂵󱂴

󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃟󱂴󱃚
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃈󱃯󱂬󱃭󱃦󱃯󱂷󱃂
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃈󱃖󱃯󱃫󱂺󱃙󱃯󱈌󱂬
󱃃󱃠󱃠󱂻󱃯󱃃󱃠󱂴󱃯󱃠󱃦󱃙󱃯󱂸󱃔󱂻
󱈋󱃟󱃙󱃯󱂻󱂻󱃯󱂺󱃢󱂭󱃠󱃯󱂻󱂯󱃢󱃯󱃟󱃖
󱃮󱃂󱂶󱂵󱂷󱃯󱃫󱃀󱃠󱃖󱃯󱃬󱃠󱃟󱃯󱂫
󱂻󱂯󱃯󱃭󱂳󱂿󱂺󱃯󱃬󱂯󱃚󱃬󱃖󱂻󱂶󱃯
󱃏󱃙󱂿󱃯󿊀󱃢󱃔󱃯nonver?
        """
      , inline = []
      , notes = ""
      }
 , { id = "##207.B.right"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂫󱂴󱃯
󱃜󱃁
󱃞󱂱󱂳
󱃘󱃅
󱃃󱃧
󱃞󱈒󱃯
󱃅󱃭
󱃮󱃇
󱃬󱈂󱃡󿊀nonver?
        """
      , inline = []
      , notes = ""
      }
 , { id = "##208.A"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃬󱃍󱂿󱃯󱂹󱃖󱃯󱃈󱂾󱂶󱃯󱃊
󱃫󱃙󱃉󱃯󱃫󱂽󱂵󱂵󱃯󱃠󱃢󱃄
󱃜󱃂󱃟󱃩󱃯󱂺󱂯󱃆󱂼󱃦󱃯󱃖󱃒󱃖󱃛
󱃫󱃙󱃯󱂭󱃆󱂿󱃀󱃉󱃯󱂾󱂶󱂬󱃙󱃐󱃯
󱃫󱂼󱃉󱃯󱃃󱂿󱃇󱃯󱃃󱂿󱃯󱂫󱂺󱃇󱂴󱃯󱂵
󿊀󱃘󱃠󱃯󱃬󱂷󱃯󱃜󱃈󱃐󱃙󱃯󱂶󱃀󱃯󱂾󱂶󱃧
󿊀󱂯󱂻󱃔󱃯󱃫󱂫󱃙󱃯󱈏󱂱󱃇󱂴󱃯󱃃󱃩󱃧󿊀
󿊀󿊀󱃯󱃈󱂾󱈏󱂴󱃯󱃃󱂿󱃇󱃯󱂫󱂺󱃯󱈏󱃧󱃔󱃟
󿊀󿊀󱃩󱃩󱃯󱃜󱃊󱃆󱃉󱃯󱂶󱃧󱃔󱃐󱃯󱂷󱃂󱂻
󱃫󱃙󱃯󱂺󱈎󱃆󱂼󱃦󱃯󱃮󱃍󱃯󱂼󱂶󱂵󱃯󱃏󱂬󱃍󱃉
󱃗󱃉󱃯󱃃󱂿󱃇󱃯󱃮󱃛󱂴󱃯󱃫󱃙󱂫󱃯󱃅󱃧󱂻󱃔
󱂷󱃏󱂵󱃯󱃠󱃇󱈎󱃟󱃯󱃊󱂯󱃯󱃫󱃙󱃉󱃯󱂫󱂺󱃘󱃉
󱃠󱃊󱃯󱂺󱃠󱃋󱃡󱃯󱃜󱃊󱃯󱃅󱂵󱃩󱂵󱃯󱂺󱂻󱃔󱈎󱃔
󱂫󱂺󱃘󱃦󱃯󱃟󱃠󱃯󱃮󱃘󱂶󱃯󱃫󱃙󱂫󱃯󱃅󱂿󱃉
󱂾󱃈󱂬󱃯󱃫󱂺󱃙󱃯󱃮󱃚󱃖󱃯󱃒󱂺󱃩󱂵󱃯󱂾󱂭󱂫󱃙
󱃒󱃏󱂯󱃯󱃏󱃐󱃯󱃃󱃚󱃯󱂺󱂭󱃐󱃯󱃫󱃏󱃟
󱃉󱃚󱂿󱃯󱃃󱂹󱃝󱃯󱃫󱃀󱃧󱃯󱂻󱃕󱂵󱃯󱃖󱂻󱂬󱃎󱃦
󱃊󱃧󱃄󱃯󱃫󱃙󱃯󱃮󱃀󱂬󱂵󱃯󱃭󱃙󱃙󱃯󱃫󱃟󱃂󱂬
󱃭󱂾󱃦󱃯󱃭󱂵󱃙󱂴󱃯󱃃󱂿󱃇󱂴󱃯󱂫󱃨󱃯󱂻󱃇
󱃭󱃟󱃟󱃯󱂺󱃢󱃯󱃬󱃊󱂬󱃯󱃠󱃗󱃯󱃄󱃙󱂿󱃰
󿊀󱃢󱂷󱃝󿊀󿊀󿊀󱃯󱃜󱂴󱃯󱂶󱃗󱃨󱃯󱃟󱂯󱃭󱂵
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂿󱃛󱃯󱃫󱃀󱃟
        """
      , inline = []
      , notes = ""
      }
 , { id = "##208.B"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󱃯󱃫󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃉
󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃠󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃏󱃟󱃯󱂷󱂯󱃍󱃋
󿊀󿊀󱃚󱂶󱂵󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂻󱃯󿊀󿊀󿊀󿊀󱃯󱃜󱃦󱃯󱃟󱃠
󿊀󱃅󱂶󱃯󱃫󿊀󿊀󿊀󿊀󿊀󱃉󱃙󱃯󱃭󱃊󱃔󱃯󱃟󱃢󱃯󱃭󿊀
󱂶󱂴󱃯󱃧󱂴󱃯󱃬󱃂󱃟󱂯󱃯󱃮󱃛󱃯󱃠󱂷󱃯󱃜󱃉
󱃫󱂯󱃉󱃗󱂵󱃯󱃫󱃧󱃏󱃯󱂺󱂫󱃙󱃯󱂸󱃢󱂿󱂻
󱃫󱃊󱂿󱂻󱃯󱂲󱂶󱃯󱂫󱃙󱂽󱃯󱃫󱃟󱂴󱃯󱃅󱂻󱃔
󱃃󱃟󱃯󱃈󱂾󱂶󱂴󱃯󱃭󱃍󱃯󱃭󱂲󱃠󱃯󱃫󱃦󱃯
󱂶󱃅󱃖󱃯󱂶󱂯󱃔󱂷󱃯󱃫󱃀󱃧󱃯󱂷󱃍󱂶
󱃮󱂫󱃯󱂻󱂾󱃈󱃯󱂾󱂳󱂵󱃯
󱂹󱂯󱃯󱂶󱈐󱃡󱂵󱃯󱃬
󱃬󱃊󱂴󱃯󱂫󱃙󱃯󱃫
󱃃󱂻󱃯󱂳󱃎󱃏󱃯󱃖
󱂭󱂶󱃯󱃧󱃀󱃯󱂭󱃊󱃯󱃄
󿊀󿊀󱃫󱃉󱃙󱃟󱃯󱃮󱂭
󿊀󿊀󿊀󱃛󱃙󱃙󱃯󱃮󱃏󱃟
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.top"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂺󱂶󱂮󱃯󱂫󱃟󱃯󱂻󱃇󱃯󱃒󱂺󱃧nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.1"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󱃮󱈑󱃯󱂻󿊀
󿊀󿊀󱂿󱃦󿊀󿊀󿊀󿊀
󱃃󱃐󱃯󱃜󱃂󱃭󱃯󱂾󱃄󱂿󱃖nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.2"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃫󱃃󱃦󱃇󱃯󱂫󿊀󿊀󱃯󱂻󱂻
󱃒󱃟󱂼󱃦󱃯󱃃󱃐󱃯󱃜󱃂󱃭
󱂾󱃄󱂿󱃖nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.3"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃫󱃒󱃦󿊀󿊀󿊀󱃧󱃯󱃃󱃒󱃧
󱂾󱃄󱂿󱃖󱃯󱃃󱃐󱃯󱃜󱃂󱃭nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.4"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂷󱂯󱂻󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃬󱃮󱃦
󱃃󱃐󱃯󱃜󱃂󱃭󱃯󱂾󱃄󱂿󱃖nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.5"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃃󱂺󿊀󿊀󱂽󱃐󱃯󱂳󱃥󱃃
󱃒󱃟󱂼󱃦󱃯󱂾󱃄󱂿󱃖󱃯󱃃󱃐
󱃜󱃂󱃭nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.6"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󱃭󱃟󱃯󱃏󱃐󱃯󱃒󱃟󱂼󱃦
󱂾󱃄󱂿󱃖󱃯󱃃󱃐󱃯󱃜󱃂󱃭nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.7"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󱃯󱂯󱃠󱃎󱃯󱃟󱃅󱃖󿊀
󱂾󱃄󱂿󱃖󱃯󱃃󱃐󱃜󱃂󱃭nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.left.8"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂾󱃦󱃯󱃟󱂸󿊀
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃬nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.right.1"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃬󿊀󿊀
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃅󱃦󱃎󿊀
󱃬󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃮󱃛󿊀
󱂾󱃄󱂿󱈑󱃯󱃃󱃐nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.right.2"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃎󱃋󿊀󿊀󿊀󿊀󱃯󱃮󿊀
󿊀󿊀󿊀󿊀󿊀󱃐󱃯󱃒󱃟󱂼󱃦
󱂾󱃄󱂿󱃖󱃯󱃃nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.right.3"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂾󱃭󱃖󱃟󱃯󿊀󱃂
󱈋󱃩󱃯󱂾󱃄󱂿
󱃜󱃂󱃭nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.right.4"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󱃋󱃎󱂹󱃯
󿊀󿊀󿊀󱃂󱃐󱃯󱃃
󱂾󱃄󱂿󱃖nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.A.right.5"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃒󱂯󱃔󱃋
󿊀󿊀󿊀󿊀󿊀󱃖󿊀
󿊀󿊀nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##209.B"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀
󱂭󱂭󱃟󱃯󱂭󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃉󱃯󱃒󱂺
󱂭󱂭󱃟󱃯󱂭󱂯󱂭󱃭󱃯󱃬󱂹󱃯󱃏󱃚󿊀
󱂭󱂭󱃟󱃯󱂭󱂯󱂭󱃭󱃯󱃬󱂹󱃯󱂭󱂭󱃛
󱃫󱃐󱂹󱃯󱃬󱃥󱂯󱃍󱃋
󱃟󱂹󱃔󱃯󱃬󱃤󱂯󱃍󱃋󱃯󱂼󱃮
󱂭󱂭󱃟󱃯󱃜󱂯󱃉󱃭󱃯󱃃󱂹󱃯󱃉󱃋
󱃙󱃚󱃘󱃯󱃅󱃅󱃍󱃋󱃯󱃫󱃖󿊀󿊀
󱃫󱂺󱃙󱃧󱃯󱃡󱂹󱃯󱂾󱃖󱂵󱂷󱃯󱃫
󱂺󱂺󱃯󱃬󱂯󱃢󱃯󱃮󱃛󱂸󱃯󱂭󱂭󱃯󱃭
󱃒󱂺󱃩󱃯󿊀󿊀󿊀󱃉󱂬󱃍󱃢󱃯󱃫󱃟󱃭󱃛
󱃫󱂴󱂴󱃯󱃒󱂺󱃙󱃯󱃟󱂷󱃯󱃫󱃎󱂶󿊀
󱃟󱂺󱃙󱃋󱃯󱃂󱃐󱃇󱃯󱃏󱂶󱂹󱃉
󱃭󱂭󱂭󱃢󱂴󱃯󱃫󱈓󱃝󱃯󱃅󱃖󱃯󱂫
󱃟󱂺󱃙󱃋󱃯󱃃󱂵󱃯󱃃󱂳󱃩󱃯󱃟󱂬󱂹󿊀
󱃫󱃚󱃀󱃯󱃛󱃦󱂿󱃀󱃯󱃃󱂵󱃋
󱃃󱃎󱃄󱃀󱃯󱃃󱂵󱃏󱃯󱃫󱃍󱂻󱃯󱃦
󱃫󱃚󱂽󱂴󱃯󱃒󱂺󱂿󱂺󱃯󱃫󱃠󱃋
󱂺󱂭󱂫󱃯󱃄󱃅󱃦󱃙󱃯󱂫󱃙󱃀󱃯󱃆󱃄
󱂾󱃖󱃐󱃯󱃫󿊀󿊀󿊀󿊀󱂵󱃦󱂬󱂻󱃭
󱂺󱂭󱂫󱃯󱃄󱃅󱃦󱃙󱃯󱂫󱃙󱃀󱃯󱃊󱃅
󱃫󱂫󱃠󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃦󱃯󱂫󱃚󱃉󱃐󱃯󱃉
󱂶󱃛󱃇󱃯󱃄󱃎󱂯󱃯󱂺󱃉󱃅󱃍󱃋󱃯󱃄󱃛nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##210"
      , tags = [ "RASH", "Aéti", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄪󱄁
        """
      , inline = []
      , notes = ""
      }
 , { id = "##211"
      , tags = [ "RASH?", "Aéti", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱉑󱉒󱉓nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##212.A"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄬󱄄󱄡󱄴󱄋󱃲
󱃴󱃵󱄇󱄪󱄴󱄁󱄦
󱄁󱄲󱄬󱄆󱄁󱄲󱃵󱄔
󱄁󱄢󱃾󱄲󱄆󱃼󱃳󱄲
󱄲󱃶󱄂󱄲󱄋󱃵󱈔󱄞󱄲
󱈞󱄋󱄲󱈥check drittletzte zeile
󿊀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##212.B.side"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
 󱄁󱄭󱄥󱃳󱄞
        """
      , inline = []
      , notes = ""
      }
 , { id = "##212.B.face"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱃺󿊀
󱄊󱄲
󱈕󱄊
󱄲󱃵󱃺󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃼
󱄢󱄯󱄞󱄁󱄲󱄞󱃳󱄁
󱄲󱄂󱄋󱄊󱈖
󿊀󿊀󱄗󱃾󱄲󿊀󱄃󱄉change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##213"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󱄲󿊀
󱃷󱉣󱈤󱃳󱄰
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃵
󿊀󿊀󿊀󿊀󿊀󿊀󱄲󱄁
        """
      , inline = []
      , notes = ""
      }
 , { id = "##214"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄱󱄉󱃴󱃿󱈗󱄳󱄧󿊀󿊀󱃷󱄎󱄃󱄚
󿊀󱈤󱈙󱄵󱄚󱄛󱄁󿊀󿊀󿊀󿊀󿊀
󱄱󱉗
󿊀󱄮󿊀󿊀󿊀󿊀󿊀󱃷󿊀󿊀󿊀󿊀󿊀󱃷󱄰󱄳󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱄚etwas󱄅change
󿊀󿊀󿊀󱄁
󿊀󱄀
󱄅

        """
      , inline = []
      , notes = ""
      }
 , { id = "##215.A"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄪󱄂󱄝󱄲󱄍󱄄󱄲󱄏󱈢󱄶
󱄪󱄁󱄍󱄄󱄲󱄪󱄙󱄜󱄍󱄲󱄶
󱄬󱈣󱃵󱃹󱄲󱄶
󱄪󱃲󱄨󱄲󱄏󱄂󱄍󱄊󱄶
󱄪󱈙󱈙󱄤󱄲󱄍󱄄󱄲󱈙󱄕󱄩󱄶
󱈘󱄕󱃵󱄁󱄲󱄍󱄄󱄲󱄉󱄭󱄁󱄑󱄶
󱄍󱄄󱄲󱄉󱄅󱄩󱄲󱄶
󱄫󱄅󱄜󱄍󱄲󱄍󱄄󱄲󱄂󱄍󱃹󱄶
󱄈󱈙󱄨󱄶󱄲󱈘󱃹󱄕󱄨󱄲󱄈󱄕󱄨󱄊󱄶
󱈙󱃸󱄨󱄲󱄍󱄄󱄲󱈘󱃹󱈙󱄏󱄤󱄶
󱄪󱃲󱄕󱄨󱄲󱄍󱄄󱄲󱄠󱄄󱄣󱄨󱄶
        """
      , inline = []
      , notes = ""
      }
 , { id = "##215.B"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱃽󱄝󱈚󱄤󱄲󱄁󱄂󱃵󱄩󱄊󱄶
󱄀󱄜󱄚󱄍󱄶
󱈘󱃹󱄏󱃹󱄓󱄲󱄍󱄄󱄲󱃽󱄞󱄘󱄁󱄶
󱄪󱄂󱈛󱄍󱄲󱄍󱄄󱄲󱄏󱄓󱄶
󱄉󱃱󱈙󱄜󱃹󱄲󱄪󱈜󱄍󱄏󱄜󱄀󱃹󱄶
󱄪󱄙󱈜󱄍󱄲󱈝󱄒󱄲󱄏󱄓󿊀󱃵󱄤󱄈
󱄘󱈞󱄨󱄲󱄍󱄄󱄲󱄏󱄓󱄶
󱄜󱄑󱄏󱃹󱄓󱄲󱈞󱃻󱄤󱄲󱃵󱄶
        """
      , inline = []
      , notes = ""
      }
 , { id = "##216"
      , tags = [ "RASH", "Mvas", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄟󱄲󱈟󱈠
        """
      , inline = []
      , notes = ""
      }
 , { id = "##217"
      , tags = [ "SYRI", "Psce", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄖󱄌󱃴󱄐
        """
      , inline = []
      , notes = ""
      }
 , { id = "##218"
      , tags = [ "PARA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅍󱀵
        """
      , inline = []
      , notes = ""
      }
 , { id = "##219"
      , tags = [ "APLI", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑
        """
      , inline = []
      , notes = ""
      }
 , { id = "##220"
      , tags = [ "CYPR", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱁩󱅍󱄦
        """
      , inline = []
      , notes = ""
      }
 , { id = "##221"
      , tags = [ "DHEN", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀜󱇶󱀜
        """
      , inline = []
      , notes = ""
      }
 , { id = "##222"
      , tags = [ "ENKO", "Apes", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂊nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##223"
      , tags = [ "ENKO", "Apes", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##224"
      , tags = [ "ENKO Pblo", "002", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱇶󱀜󱀡change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##225"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱇆󱀵󱀠erstes change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##226"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##227"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆺󱀿erstes change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##228"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##229"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀛󱀻󱂋change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##230"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂓nonver
        """
      , inline = []
      , notes = ""
      }
 , { id = "##231"
      , tags = [ "KLAV", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉔󱉕
        """
      , inline = []
      , notes = ""
      }
 , { id = "##232"
      , tags = [ "IDAL", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      , inline = []
      , notes = ""
      }
 , { id = "##233"
      , tags = [ "IDAL", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀡󿊀󱀻ergaenz
        """
      , inline = []
      , notes = ""
      }
 , { id = "##234"
      , tags = [ "IDAL", "Pfus", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀜󱀠󱀵nonver source Ferrara 2013:121
        """
      , inline = []
      , notes = ""
      }
 , { id = "##235"
      , tags = [ "KALO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂏󿊀󱇷change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##236"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇷󱀵eliminate
        """
      , inline = []
      , notes = ""
      }
 , { id = "##237"
      , tags = [ "ITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵
󱀞change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##238"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁟󱂏change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##239"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱂃󱀵change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##240"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱀧󿊀󱃅change
        """
      , inline = []
      , notes = ""
      }
 , { id = "##241"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂃󱂅change willkuer
        """
      , inline = []
      , notes = ""
      }
 , { id = "##242"
      , tags = [ "SANI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱁵󱂓change upsidedown
        """
      , inline = []
      , notes = ""
      }
 , { id = "##243"
      , tags = [ "RASH", "Avas", "CM3" ]
      , dir = UNKNOWN, text =
        """
unspecified
        """
      , inline = []
      , notes = ""
      }
 , { id = "##244"
      , tags = [ "TIRY", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅹󱅹󱂊abfolge unklar
        """
      , inline = []
      , notes = ""
      }
 , { id = "##245"
      , tags = [ "TIRY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱁾nonver Source Douros
        """
      , inline = []
      , notes = ""
      }
 , { id = "##246"
      , tags = [ "TIRY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁿󱁖󱀜󱇸nonver Source Brent, Maran & Wirhova 2014
        """
      , inline = []
      , notes = ""
      }
 , { id = "##247"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱇝󱇃󱂦󱀚nonver
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
 , { id = "##248"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑󱄼nonver
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
  , { id = "##249"
    , tags = [ "KOUR", "Avas", "CM1" ]
    , dir = UNKNOWN, text =
        """
󱀜󱁷󱀜nonver
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
    , { id = "##250"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈩󱀸󱀵nonver
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
    , { id = "##251"
      , tags = [ "RASH", "Avas", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄻󱂉nonver
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
    , { id = "##252"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
 󱂐󱁎󱁓nonver
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
    , { id = "##253"
      , tags = [ "PPAP", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁭nonver 
        """
      , inline = []
      , notes = "Source Valerio 2014"
      }
    , { id = "##254"
      , tags = [ "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
noch einfuegen Source Egetmeyer 2016
        """
      , inline = []
      , notes = ""
      }
    , { id = "##255"
      , tags = [ "CM1" ]
      , dir = UNKNOWN, text =
        """
noch einfuegen Source Egetmeyer 2016
        """
      , inline = []
      , notes = ""
      }
    ]


cypro : Script
cypro =
    { id = "cypro"
    , name = "Kypro-Minoisch"
    , tokens = tokens
    , specialChars = specialChars
    , guessMarkers = ""
    , indexed = indexed
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = initialSyllabary
    , groups = groups
    , fragments = fragments
    }
