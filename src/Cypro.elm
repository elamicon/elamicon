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
-- Most of the artifacts did not make it through time in mint condition. The
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
-- Letter are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
initialSyllabary =
    { id = "lumping", name = "Breit zusammenfassen für die Suche"
      , syllabary = String.trim
            """
󱀈󱀉󱂊󱃒󱃓󱃔󱃕󱃖󱃗󱁧󱁨󱁩󱁪󱁫󱁬󱁭󱁮󱁯󱁰󱁱󱈉󱈜󱄚󱁲󱁳󱄒󱄓󱄔󱄕󱄖󱄗󱄘󱆜󱆡󱆢󱆣󱆤󱆥󱆦󱆧󱈚󱈭󱆨󱆪󱆫󱆬󱈽󱆭󱆮󱆽󱇼󱈑󱈒
󱄙󱃘󱅪󱈳
󱅣󱅤󱅥󱅦󱅧󱅨󱅩󱀻󱄃󱀼󱇿󱀸󱀹󱄂󱂺
󱀋󱀌
󱂇󱂈󱃧󱃦󱃨󱆼󱅠󱅡󱂉󱀅󱈿󱉀󱈅󱂍󱂎󱄦󱇦󱇧󱈔󱄑󱈣󱉆󱈖󱂏󱉪󱉫󱈬󱂑󱂜󱂻󱈥󱉦󱉧󱉩󱃩󱃫󱈠󱈌󱃬󱃭󱈘󱉮󱇾󱈗󱈸󱈼󱈵󱉃󱇌󱉒󱉓󱇱󱈪󱇘󱇐󱈧󱇎󱇢󱃮󱄣󱄤󱄥󱄧󱄨󱈱󱄩󱄪󱈤󱀍󱀖󱄬󱄭󱄮󱄯󱆛󱆾󱆿󱇨󱈍󱇩󱇪󱇫󱇬󱇭󱇮󱇯󱇀󱇁󱇂󱇃󱇤󱇄󱇅󱇇󱇈󱇉󱇊󱁛󱂓󱂔󱂕󱂖󱂗󱂘󱂙󱂚󱂛󱂐󱇜󱇝󱇞󱂞󱉔󱈕󱄆
󱀆󱀇󱀕󱀊󱀜󱀝󱂬󱃴󱄸
󱀓󱀚󱀛󱂫󱃳󱈁󱈙
󱂪󱈂󱀗󱂲󱃱󱄾󱇶󱇷󱇸
󱀘󱀙󱇴󱈆
󱀡󱀢󱀬󱀭󱀃󱂭󱂮󱂴󱃸󱃼󱅂󱅏󱈇
󱀞󱀟󱀠󱃵󱃶󱃷󱄹󱄺󱄻󱄼󱄽󱈦
󱀤󱈎󱀥󱂯󱂰󱈢󱂱󱈋󱃹󱃺󱈫󱅄󱉌
󱃋󱃌󱃠󱃡󱃢󱃤󱃥󱅃
󱀳󱀴󱈺
󱀵󱄁󱉈󱅘󱉉󱅛󱅜󱅝󱅞󱅟󱂢󱅢󱈯󱉏󱅫󱅬󱅭󱅮󱅯󱅰󱅱󱅲󱅳󱅼󱅙󱅚󱀶󱂹󱀷󱀺󱈨󱈝󱄄󱀽󱀾󱂼󱀿󱁀󱁁󱁂󱀐󱀒󱀔󱁏󱁐󱂵󱂶󱂷󱂸󱂽󱂾󱂿󱃾󱃿󱄀󱇣
󱉊󱉐󱉭
󱁃󱁄󱃲
󱁅󱄅󱁆󱁇󱁉󱄇󱅴󱄈󱁊󱁍󱃀󱃁󱃂󱃃󱄉
󱃆󱃇󱃈󱃉󱃊󱈈󱃏󱈏󱃎󱈮
󱀁󱂒󱄫󱇒󱇓󱇚󱂝
󱇔󱇕󱇖󱇗
󱁋󱁌󱅵󱅶󱅷󱅸󱁚󱁖󱁗󱈓󱁘󱄍󱄎󱄏󱃐󱃑󱁙󱁝󱁞󱁟󱁠󱄐󱇑󱁡󱁢󱁣󱁤󱁥󱁦󱀄󱀑󱆌󱆍󱆎󱆏󱆐󱆑󱆕󱆖󱆗󱆘󱆙󱆚󱆞󱆟󱆩󱆷󱆸󱇲󱆺󱆻
󱁵󱀂󱆲󱆳󱆴󱆹󱆵󱆶󱁷󱁸󱁹󱉂󱈾󱆋󱇙󱆒󱆓󱆔󱁺󱁻󱁼󱁽󱁾󱁿󱂀󱂁󱂂󱂃󱂄󱂅󱈛󱈐󱃣󱂆󱄠󱄡󱈞󱀀󱃍󱈊󱆠󱄝󱄞󱄟
󱆯󱆰󱆱
󱀣󱀫󱈡󱄿󱅀󱅁
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
󱃙󱃚󱅻
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


-- Linear Elam body as read by us. The majority of the fragments is written RTL.
-- There is speculation that at least one of the fragemnts is written in
-- boustrophedon meaning alternating writing direction per line.
-- The writing direction is only a guess for many fragments.
fragments : List FragmentDef
fragments = List.map (\f -> { f | text = String.trim f.text })
    [ { id = "##001.A"
      , group = [ "ENKO", "Atab", "CM0" ]
      , dir = UNKNOWN, text =
        """
󱀀󱀁󱀂󱀃󱀄󱀅󱀆󱀈
󱀊󱀋󱀌󱀍󱀎󱀏󱀐
󱀑󱀒󱀓󱀔󱀕󱀖
        """
      }
    , { id = "##001.B"
      , tags = [ "ENKO", "Atab", "CM0" ]
      , dir = UNKNOWN, text =
        """
󱀇󱀉
        """
      }
    , { id = "##002"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈪󱂎󱆲󱂧󱀱
        """
      }
    , { id = "##003"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆳󱁖󱀤󱇸
        """
      }
    , { id = "##004"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅹󱀾󱀳󱂧󱆌
        """
      }
    , { id = "##005"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁘󱇛󱇉
        """
      }
    , { id = "##006"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂏󱀛󱀬󱁖󱂧󱀹
        """
      }
    , { id = "##007"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁊󱂖󱈫󱅺
        """
      }
    , { id = "##008"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀾󱀹󱂈
        """
      }
    , { id = "##009"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##010"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##011"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈬󱁉󱀡
        """
      }
    , { id = "##012"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇛󿊀󿊀󿊀󱆲󱁟󱀞󱇊
        """
      }
    , { id = "##013"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆬󱅠󱁘󱇸󱇛󱅡󱇸
        """
      }
    , { id = "##014"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁳󱂉󱂧󱄺
        """
      }
    , { id = "##015"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀛󱂄󱁵󱀼󿊀󿊀
        """
      }
    , { id = "##016.A"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇍󱁮󱀛󱇀󱉖󿊀󱇸
        """
      }
    , { id = "##016.B"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂧󿊀
        """
      }
    , { id = "##018.A"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅹󱀾󱀳󱂧󱅒
        """
      }
    , { id = "##018.B"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##020"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁒󱁠󱂊󱂦󱀫󱀚
        """
      }
    , { id = "##021"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇦󱁎󱇾󱂧󱄹󱆣󱇧󱀻󱀜󱂧
        """
      }
    , { id = "##022"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂦󱀻󱀞󱆾
        """
      }
    , { id = "##023"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅣󱇽󱂒
        """
      }
    , { id = "##024"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁮󱀚󱆿󱂛󱁮󱂦󱆼
        """
      }
    , { id = "##025"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅢󱁵󱀣󱇳󱀵󱁭󱅆󱅃󱁭
        """
      }
    , { id = "##026"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆭󱆍󱀤󱇼
        """
      }
    , { id = "##027"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀮󱀰󱄿󱂦󱉤
        """
      }
    , { id = "##028"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱂈󱁃
        """
      }
    , { id = "##029"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀫󱈁󱇁󱂦󱂐
        """
      }
    , { id = "##030"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀯󱀰󱀣󱂧󱁗󱅿󱁃󱂊
        """
      }
    , { id = "##031"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱀸󱂊󿊀
        """
      }
    , { id = "##032"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱅤󱁬󱁽
        """
      }
    , { id = "##033"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁾󱁵󱀷
        """
      }
    , { id = "##034"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱂇󱂀󱉖󱀹
        """
      }
    , { id = "##035"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅄󱆝󱂧󱀛󱂓󱁉󱁘
        """
      }
    , { id = "##036"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆴󱇂󱂦
        """
      }
    , { id = "##037"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇨󱆁󱇃󱂧󱀵󱀯
        """
      }
    , { id = "##038"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆂󱀰󱂦󱁒
        """
      }
    , { id = "##039"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆀󱀯󱁻󱂀
        """
      }
    , { id = "##040"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇩󱆤󱁻
        """
      }
    , { id = "##041"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁶󱂒󱂎󱀵󱂧󱀛
        """
      }
    , { id = "##042"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱁻󱂁󱂞
        """
      }
    , { id = "##043"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱀵󱆡󱁻󱉖󱄸
        """
      }
    , { id = "##044"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇿󱁗󱅇󱉖󱁗
        """
      }
    , { id = "##045"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱂓󱂊󱉖󱂞
        """
      }
    , { id = "##046"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁧󱇜󱀤󱅤󱉖󱂞
        """
      }
    , { id = "##047"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅽󱁟󱇃󱅓󱂛
        """
      }
    , { id = "##048"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁮󱀚󱂌󱉖󱀵
        """
      }
    , { id = "##049"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂔󱁭󱀬󱁥󱂧󱀣
        """
      }
    , { id = "##050"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁄󱈭󱁗
        """
      }
    , { id = "##051"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅾󱈮󱂋󱂧󱀮
        """
      }
    , { id = "##052"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁧󱂛󱁤󱉖󱀵
        """
      }
    , { id = "##053"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇝󱂛󱀵
        """
      }
    , { id = "##054"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱀥󱁵󱁻󱅐
        """
      }
    , { id = "##055"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱂗󱂋󱉖󱁍
        """
      }
    , { id = "##056"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀻󱀬󱁬󱂦󱁵
        """
      }
    , { id = "##057"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱁵󱂌󱂧󱄼
        """
      }
    , { id = "##058"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀞󱀹󱁵󱇄󱂦󱆃
        """
      }
    , { id = "##059"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆯󱂊󱂦󱁖
        """
      }
    , { id = "##060"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱀞󱁤󱂄󱆡
        """
      }
    , { id = "##061"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂧󱀞
        """
      }
    , { id = "##062"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱅍󱂦󱁆
        """
      }
    , { id = "##063"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁾󱂓󱇃
        """
      }
    , { id = "##064"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅥󱆋󱅈󱀝󱂑󱁾󱈩
        """
      }
    , { id = "##065"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱀵󱁝
        """
      }
    , { id = "##066"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆔󱅅󱂦󱆔󱅀󱂃󱂀
        """
      }
    , { id = "##067"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀘󱅗󱆡󱁺󱂦󱁢
        """
      }
    , { id = "##068"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂊󱂦󱅀󱁭󱀚
        """
      }
    , { id = "##069"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱀵󱁭󱁻󱂧󱂞
        """
      }
    , { id = "##070"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁣󱀜󱀶󱂧󱁴󱀣󱀥󱁭
        """
      }
    , { id = "##071"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁸󱁺󱂁󱂦󱁹
        """
      }
    , { id = "##072"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱇙󱂊󱂦󱀻
        """
      }
    , { id = "##073"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##074"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##075"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱁇󱀪󱁩󱂦󱀜
        """
      }
    , { id = "##076"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁢󱀝󱀶󱂧󱁕
        """
      }
    , { id = "##077"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆄󱁬󱅑󱂧󱆥
        """
      }
    , { id = "##078"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈯󱀣
        """
      }
    , { id = "##079"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂏󱀟󱀵󿊀󿊀
        """
      }
    , { id = "##080"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁴󱇅󱂦󱇞󱁍󿊀
        """
      }
    , { id = "##081"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁶󱂐󱁞󱀢󱂦󱀹
        """
      }
    , { id = "##082"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀩󱀶󱇪󱂊󱂦󱂛
        """
      }
    , { id = "##083"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂞󿊀󿊀󱂦󱂞
        """
      }
    , { id = "##084"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈪󱀥󱀞󱀥
        """
      }
    , { id = "##085"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇌󱅃󱁵󱁻󱂦󱂛
        """
      }
    , { id = "##086"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀞󱀞󱀚󱂍󱈰
        """
      }
    , { id = "##087"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁝󱀰󱀤󱁑
        """
      }
    , { id = "##088"
      , tags = [ "HALA", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁾󱂗󱂊󱁵󱀣
        """
      }
    , { id = "##089"
      , tags = [ "HALA", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁣󱀜󱅚󱂧󱁰
        """
      }
    , { id = "##090"
      , tags = [ "KITI", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆵󱀚󱅔󱆷
        """
      }
    , { id = "##091"
      , tags = [ "KITI", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱅁󱂔󿊀
        """
      }
    , { id = "##092"
      , tags = [ "ATHI", "Adis", "CM1", "lisible" ]
      , dir = UNKNOWN, text =
        """
󱆕󱅦󱀚󱄻
󱉘󱉙󱉚
        """
      }
    , { id = "##093"
      , tags = [ "ENKO", "Aost", "CM1", "rev", "lisible" ]
      , dir = UNKNOWN, text =
        """
󱂡󱉖󱉛󱉜
󱂢󱉝󱉞
        """
      }
    , { id = "##094"
      , tags = [ "ENKO", "Aost", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇆󱂔󱀛󿊀󿊀󿊀
󱅻󱂦󱆅󱇰󱂧󱂒󱅴
󱁭󱂧󱅧󱅻󱂧󱁒󱀰
󿊀
󿊀󱀜󱁧󱂓
        """
      }
    , { id = "##095"
      , tags = [ "ENKO", "Apes", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂋󱁵󱀧󱂦󱀜󱂘󱆖
        """
      }
    , { id = "##096"
      , tags = [ "ENKO", "Apla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱂧󱂐
        """
      }
    , { id = "##097"
      , tags = [ "ENKO", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁊󱁾󱂒󱀵󱁩󱀵 󱂨
󱆦󱁵󱂦󱁵󱂉󱂂󱀵󱂩󱂓
󱀠󱂩󱁘󱀥󱁫󱀪󱀵󱂩󱂛
󱂏󱁘󱀚󱂦󱀻󱅏󱂜󱉩
󱀵󱂩󱈲󱂩󱁵󱁱󱂍󱂦
󱂓󱀧󱀶󱀞󱀪󱀵󱂩󱀞󱂩
󱀺󱅏󱂩󱂧󱀞󱂩󱁓󱁘󱀪
󱀵󱂩󱁵󱂩󱀪󱀸󱂦󱈱󱂩
󱁵󱂉󱂂󱀵󱂩󱀤󱁫󱀺
󱁱󱂩󱀛󱂁󱀸󱂦󱁏󱁏
󱉦󱂩󱁊󱀤󱁱󱀠󱀳󱂩󱁊
󱀳󱂩󱂕󱀧󱀶󱂖󱀻󱁪
󱀵󱂩󱀛󱀤󱂂󱅏󱀠󱀳
󱁑󱀺󱈲󱆧󱀹󱀵󱀛
󱁾󱀹󱂦󱁑󱁉󱉩󱂒
󱀸󱁱󱂒󱈳󱁩󱀸󱂒
󱁩󱀛󱁿󱀸󱁍󱀳󱅏󱂦
󱀳󱀞󱂕󱅘󱁘󱈴󱂓󱂒
󱀸󱂏󱉧󱅏󱂦󱁅󱀳
󱈵󱀵󱂩󱆦󱉩󱂩󱈶󱀵
󱁩󱀠󱀳󱂩󱁓󱀹󱀛󱀵
󱀻󱀜󱀸󱀛󱂍󱂈󱀵
󱀛󱁿󱀸󱂦󱁑󱂀󱂊󱀵
󱀹󱀛󱂍󱀠󱂦󱈷󱀞󱁘󱂈
󱀹󱂒󱁩󱁵󱁱󱂍󱂦󱀠󱀜
󱁵󱂉󱂀󱀵󱁩󱀺󱁖
󱁩󱀹󱂒󱁩󱁵󱁱󱂍󱂦
        """
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
      }
    , { id = "##099"
      , tags = [ "KALA", "Arou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󱁞󱀚󱂧󱆰
󱁑󱁁󱅨󿊀
󿊀󿊀󿊀󿊀󿊀󱁒
        """
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
      }
    , { id = "##103"
      , tags = [ "PSIL", "Asta", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁚󱀙󱀥󱁭
        """
      }
    , { id = "##104"
      , tags = [ "ALAS", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆨󱀵󿊀󿊀
        """
      }
    , { id = "##105"
      , tags = [ "ARPE", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆇󱄻󱂊󱂣󱆎󱂈󱈨
        """
      }
    , { id = "##106"
      , tags = [ "ATHI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅶󱁿󱁿󱀚󱈫󱁩󱀵
        """
      }
    , { id = "##107"
      , tags = [ "ATHI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉁󿊀
        """
      }
    , { id = "##108"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅛󱄽󱅩󱅜󱇈
        """
      }
    , { id = "##109"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁿󱀮󱁵󱂦󱂐󱁮󱀚󱂋󱂦󱂕󱇆
        """
      }
    , { id = "##110"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂦󱅪󱆩󱁢󱀵
        """
      }
    , { id = "##111"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱄽󱀵󱀬󱀵󱂦󱂛
        """
      }
    , { id = "##112"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇏󱁵󱁪󱂁󱇇󱀵
        """
      }
    , { id = "##113"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇐
󱅕
        """
      }
    , { id = "##114"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵
󱄷
        """
      }
    , { id = "##115"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵
󱆶
        """
      }
    , { id = "##116"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁊change
󱀝doubt
        """
      }
    , { id = "##117"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑
󱉂evtl zwei z
        """
      }
    , { id = "##118"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆗󱇳󱆘
        """
      }
    , { id = "##119"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀶
󱅵
        """
      }
    , { id = "##120"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂦󱂛
        """
      }
    , { id = "##121"
      , tags = [ "ENKO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱂧󱀵󱂧󱀳
        """
      }
    , { id = "##122"
      , tags = [ "HALA", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅝
󱅞
        """
      }
    , { id = "##123"
      , tags = [ "IDAL", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅼󱅼󱆜
        """
      }
    , { id = "##124"
      , tags = [ "IDAL", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁍󱁢󱁟󱆸
󿊀󿊀󱀵mit oberer z󱂃
        """
      }
    , { id = "##125"
      , tags = [ "KALA", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁋󱀝ligatur
        """
      }
    , { id = "##126"
      , tags = [ "KALA", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆞
󱁵
󱀵mit oberer z
        """
      }
    , { id = "##127"
      , tags = [ "KATY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅷
󱅫
󱈦
        """
      }
    , { id = "##128"
      , tags = [ "KATY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁜󱁙󱁶󱈧
        """
      }
    , { id = "##129"
      , tags = [ "KATY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆺
󱆢
        """
      }
    , { id = "##130"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀝󱁉󱂋󱀵󱆈
        """
      }
    , { id = "##131"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀚󱅟nonver
        """
      }
    , { id = "##132"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅲󱅬
        """
      }
    , { id = "##133"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅭󱅳
        """
      }
    , { id = "##134"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅳󱅮
        """
      }
    , { id = "##135"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱇷󱇣
        """
      }
    , { id = "##136"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵plus ein z
        """
      }
    , { id = "##137"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂦󱇟rhomb buendig
        """
      }
    , { id = "##138"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂧󿊀
        """
      }
    , { id = "##139"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱉬
        """
      }
    , { id = "##140"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅯󱁭
        """
      }
    , { id = "##141"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
irgend
󱀵
󱀵
        """
      }
    , { id = "##142"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      }
    , { id = "##143"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂦󱇠change
        """
      }
    , { id = "##144"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱄾󱀵
        """
      }
    , { id = "##145"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉟󱁋󱉠
        """
      }
    , { id = "##146.A"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀴
        """
      }
    , { id = "##146.B"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      }
    , { id = "##147"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂧󱇡change
        """
      }
    , { id = "##148"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂕change
󱅖
        """
      }
    , { id = "##149"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁡
        """
      }
    , { id = "##150"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛change󱁡
        """
      }
    , { id = "##151"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁡nonver
        """
      }
    , { id = "##152"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱁠nonver
        """
      }
    , { id = "##153"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅸
󱆮
        """
      }
    , { id = "##154"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂓󱇈
        """
      }
    , { id = "##155"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      }
    , { id = "##156"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib󱀵
        """
      }
    , { id = "##157"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁋󱆉󱀵󱂦󱁒󱀻󱁧󱀵󱂦
        """
      }
    , { id = "##158"
      , tags = [ "MYRT", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑󱁾change󱀾󱇫
        """
      }
    , { id = "##159"
      , tags = [ "MYRT", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󿊀changed
        """
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
      }
 , { id = "##161"
      , tags = [ "KITI", "Iins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇢󱂓󱀵
󱁵󱂇󱂂󱂧󱂛󱀵󱁝󱀳󱀵󱂣󱂐
        """
      }
 , { id = "##162"
      , tags = [ "KITI", "Iins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇒󱀛󱁘󱆟
󱀵󱂆󱂌󱂦󱀵plus numeralia
        """
      }
 , { id = "##163.A"
      , tags = [ "KITI", "Ipla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆱󱇬󱇤󱆙󱁭invert
        """
      }
 , { id = "##163.B"
      , tags = [ "KITI", "Ipla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇓󱁺󱂧󱂐󱁮󱀚󱉦󱀵
        """
      }
 , { id = "##164"
      , tags = [ "ENKO", "Mbij", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉃󱉄󱉅󱉆󿊀󱉇󿊀󿊀
        """
      }
 , { id = "##165"
      , tags = [ "KALA", "Mbij", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂈󱇭󱁁󱆏invert poss
        """
      }
 , { id = "##166"
      , tags = [ "KALA", "Mbij", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂈󱂛󱁁󱆐invert poss
        """
      }
 , { id = "##167", group = "", dir = UNKNOWN, text =
        """
󱀵󱂧󱁷irgend
        """
      }
 , { id = "##168"
      , tags = [ "KITI", "Mexv", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀮󱀰󱀵󱂧󱇚󱁭󱀵
        """
      }
 , { id = "##169"
      , tags = [ "ENKO?", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇲󱂦unsicher
󱁟󱁶
        """
      }
 , { id = "##170"
      , tags = [ "PPAP", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁢󱀦󱀶󱀚󱀨
        """
      }
 , { id = "##171"
      , tags = [ "PPAP", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
neu schreib
        """
      }
 , { id = "##172"
      , tags = [ "PPAP", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈀󱂌nonver keine schrift
        """
      }
 , { id = "##173"
      , tags = [ "PYLA", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱀳eckig nonver
        """
      }
 , { id = "##174"
      , tags = [ "ENKO", "Mlin", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇔󱂧󱀵
        """
      }
 , { id = "##175"
      , tags = [ "ENKO", "Mlin", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇕󱉈
󱇖󱁈󱀵󱂠󱀵
        """
      }
 , { id = "##176"
      , tags = [ "ENKO", "Mlin", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇗󱉖󱉉
        """
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
      }
 , { id = "##178"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂓󱁭󱆛
        """
      }
 , { id = "##179"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂚󱀚󱅀󱀵󱂧󱀚󱀚󱂋󱂧󱀞󱅇
        """
      }
 , { id = "##180"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀻󱁩󱀥󱂀󱀵󱂧󱉥󱀰letztes
        """
      }
 , { id = "##181"
      , tags = [ "CYPR", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂆󱄿󱀮󱅙󱂧󱁊
        """
      }
 , { id = "##182"
      , tags = [ "ENKO", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱂚󱆚󱀵󱂧󱉡󱉢zweites
        """
      }
 , { id = "##183"
      , tags = [ "ENKO", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂚󱀚󱄿󱀵󱂦󱇱zweites
        """
      }
 , { id = "##184"
      , tags = [ "MYRT", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁋󱉖󱂔󱉪
        """
      }
 , { id = "##185"
      , tags = [ "MYRT", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁌󱂓󱉫
        """
      }
 , { id = "##186"
      , tags = [ "PPAP", "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁷󱀞󱁷󱆻󱀵zweites
        """
      }
 , { id = "##187"
      , tags = [ "ENKO", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅎󱀮󿊀󿊀󿊀󱀻ergaenzen
        """
      }
 , { id = "##188"
      , tags = [ "KITI", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂅󱀿󿊀
        """
      }
 , { id = "##189"
      , tags = [ "PPAP", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱂧󱂒change
        """
      }
 , { id = "##190"
      , tags = [ "PPAP", "Pblo", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇥󱉖󱀵check
        """
      }
 , { id = "##191"
      , tags = [ "KALA", "Ppla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉖󱂡
        """
      }
 , { id = "##192"
      , tags = [ "KALA", "Ppla", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂛󱆊󱇮zweites
        """
      }
 , { id = "##193"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱀸󱁵󱂧󱁫󱁩󱀵checken
        """
      }
 , { id = "##194"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁧󱀨󱉖󱉊󱉋
        """
      }
 , { id = "##195"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑
󱀚 turn both
        """
      }
 , { id = "##196"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉌󱉍󱁦󱀜check and turn
        """
      }
 , { id = "##197"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇷󱂙󱇋󱀵󱇶
        """
      }
 , { id = "##198"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆠󱉎󱉎mut zur luecke
        """
      }
 , { id = "##199"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆪󱆫
󱅱
        """
      }
 , { id = "##200"
      , tags = [ "ENKO?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀞󱀵
        """
      }
 , { id = "##201"
      , tags = [ "HALA", "Psce ", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁘󱁿󱁁󱁵󿊀checken
        """
      }
 , { id = "##202"
      , tags = [ "KOUR", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉏󱀬󱇯󱂊󱀵
        """
      }
 , { id = "##203"
      , tags = [ "PARA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁑󱀚󱅂󱁩
        """
      }
 , { id = "##204"
      , tags = [ "PYLA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱆑󱆽󱁀
        """
      }
 , { id = "##205"
      , tags = [ "SALA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉐󱇯
        """
      }
 , { id = "##206"
      , tags = [ "PPAP", "Vsce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇘󿊀
        """
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
      }
 , { id = "##209.A.top"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂺󱂶󱂮󱃯󱂫󱃟󱃯󱂻󱃇󱃯󱃒󱂺󱃧nonver
        """
      }
 , { id = "##209.A.left.1"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󱃮󱈑󱃯󱂻󿊀
󿊀󿊀󱂿󱃦󿊀󿊀󿊀󿊀
󱃃󱃐󱃯󱃜󱃂󱃭󱃯󱂾󱃄󱂿󱃖nonver
        """
      }
 , { id = "##209.A.left.2"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃫󱃃󱃦󱃇󱃯󱂫󿊀󿊀󱃯󱂻󱂻
󱃒󱃟󱂼󱃦󱃯󱃃󱃐󱃯󱃜󱃂󱃭
󱂾󱃄󱂿󱃖nonver
        """
      }
 , { id = "##209.A.left.3"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃫󱃒󱃦󿊀󿊀󿊀󱃧󱃯󱃃󱃒󱃧
󱂾󱃄󱂿󱃖󱃯󱃃󱃐󱃯󱃜󱃂󱃭nonver
        """
      }
 , { id = "##209.A.left.4"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂷󱂯󱂻󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃬󱃮󱃦
󱃃󱃐󱃯󱃜󱃂󱃭󱃯󱂾󱃄󱂿󱃖nonver
        """
      }
 , { id = "##209.A.left.5"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃃󱂺󿊀󿊀󱂽󱃐󱃯󱂳󱃥󱃃
󱃒󱃟󱂼󱃦󱃯󱂾󱃄󱂿󱃖󱃯󱃃󱃐
󱃜󱃂󱃭nonver
        """
      }
 , { id = "##209.A.left.6"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󱃭󱃟󱃯󱃏󱃐󱃯󱃒󱃟󱂼󱃦
󱂾󱃄󱂿󱃖󱃯󱃃󱃐󱃯󱃜󱃂󱃭nonver
        """
      }
 , { id = "##209.A.left.7"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󱃯󱂯󱃠󱃎󱃯󱃟󱃅󱃖󿊀
󱂾󱃄󱂿󱃖󱃯󱃃󱃐󱃜󱃂󱃭nonver
        """
      }
 , { id = "##209.A.left.8"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱂾󱃦󱃯󱃟󱂸󿊀
󿊀󿊀󿊀󿊀󿊀󿊀󿊀󿊀󱃯󱃬nonver
        """
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
      }
 , { id = "##209.A.right.2"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃎󱃋󿊀󿊀󿊀󿊀󱃯󱃮󿊀
󿊀󿊀󿊀󿊀󿊀󱃐󱃯󱃒󱃟󱂼󱃦
󱂾󱃄󱂿󱃖󱃯󱃃nonver
        """
      }
 , { id = "##209.A.right.3"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱂾󱃭󱃖󱃟󱃯󿊀󱃂
󱈋󱃩󱃯󱂾󱃄󱂿
󱃜󱃂󱃭nonver
        """
      }
 , { id = "##209.A.right.4"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󿊀󿊀󿊀󱃋󱃎󱂹󱃯
󿊀󿊀󿊀󱃂󱃐󱃯󱃃
󱂾󱃄󱂿󱃖nonver
        """
      }
 , { id = "##209.A.right.5"
      , tags = [ "ENKO", "Atab", "CM2" ]
      , dir = UNKNOWN, text =
        """
󱃒󱂯󱃔󱃋
󿊀󿊀󿊀󿊀󿊀󱃖󿊀
󿊀󿊀nonver
        """
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
      }
 , { id = "##210"
      , tags = [ "RASH", "Aéti", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄪󱄁
        """
      }
 , { id = "##211"
      , tags = [ "RASH?", "Aéti", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱉑󱉒󱉓nonver
        """
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
      }
 , { id = "##212.B.side"
      , tags = [ "RASH", "Atab", "CM3" ]
      , dir = UNKNOWN, text =
        """
 󱄁󱄭󱄥󱃳󱄞
        """
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
      }
 , { id = "##216"
      , tags = [ "RASH", "Mvas", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄟󱄲󱈟󱈠
        """
      }
 , { id = "##217"
      , tags = [ "SYRI", "Psce", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄖󱄌󱃴󱄐
        """
      }
 , { id = "##218"
      , tags = [ "PARA", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅍󱀵
        """
      }
 , { id = "##219"
      , tags = [ "APLI", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑
        """
      }
 , { id = "##220"
      , tags = [ "CYPR", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀗󱁩󱅍󱄦
        """
      }
 , { id = "##221"
      , tags = [ "DHEN", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀜󱇶󱀜
        """
      }
 , { id = "##222"
      , tags = [ "ENKO", "Apes", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂊nonver
        """
      }
 , { id = "##223"
      , tags = [ "ENKO", "Apes", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐nonver
        """
      }
 , { id = "##224"
      , tags = [ "ENKO Pblo", "002", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱇶󱀜󱀡change
        """
      }
 , { id = "##225"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱇆󱀵󱀠erstes change
        """
      }
 , { id = "##226"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀nonver
        """
      }
 , { id = "##227"
      , tags = [ "ENKO", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱆺󱀿erstes change
        """
      }
 , { id = "##228"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀nonver
        """
      }
 , { id = "##229"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀛󱀻󱂋change
        """
      }
 , { id = "##230"
      , tags = [ "ENKO", "Mins", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱂓nonver
        """
      }
 , { id = "##231"
      , tags = [ "KLAV", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱉔󱉕
        """
      }
 , { id = "##232"
      , tags = [ "IDAL", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀
        """
      }
 , { id = "##233"
      , tags = [ "IDAL", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱀡󿊀󱀻ergaenz
        """
      }
 , { id = "##234"
      , tags = [ "IDAL", "Pfus", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀜󱀠󱀵nonver source Ferrara 2013:121
        """
      }
 , { id = "##235"
      , tags = [ "KALO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󿊀󱂏󿊀󱇷change
        """
      }
 , { id = "##236"
      , tags = [ "KITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱇷󱀵eliminate
        """
      }
 , { id = "##237"
      , tags = [ "ITI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵
󱀞change
        """
      }
 , { id = "##238"
      , tags = [ "MAAP", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁟󱂏change
        """
      }
 , { id = "##239"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁵󱂃󱀵change
        """
      }
 , { id = "##240"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱀧󿊀󱃅change
        """
      }
 , { id = "##241"
      , tags = [ "MARO", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂃󱂅change willkuer
        """
      }
 , { id = "##242"
      , tags = [ "SANI", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀵󱁵󱂓change upsidedown
        """
      }
 , { id = "##243"
      , tags = [ "RASH", "Avas", "CM3" ]
      , dir = UNKNOWN, text =
        """
unspecified
        """
      }
 , { id = "##244"
      , tags = [ "TIRY", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱅹󱅹󱂊abfolge unklar
        """
      }
 , { id = "##245"
      , tags = [ "TIRY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀸󱁾nonver Source Douros
        """
      }
 , { id = "##246"
      , tags = [ "TIRY", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱁿󱁖󱀜󱇸nonver Source Brent, Maran & Wirhova 2014
        """
      }
 , { id = "##247"
      , tags = [ "ENKO", "Abou", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁿󱇝󱇃󱂦󱀚nonver Source Valerio 2014
        """
      }
 , { id = "##248"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂑󱄼nonver Source Valerio 2014
        """
      }
 , { id = "##249"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱀜󱁷󱀜nonver Source Valerio 2014
        """
      }
 , { id = "##250"
      , tags = [ "KOUR", "Avas", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱈩󱀸󱀵nonver Source Valerio 2014
        """
      }
 , { id = "##251"
      , tags = [ "RASH", "Avas", "CM3" ]
      , dir = UNKNOWN, text =
        """
󱄻󱂉nonver Source Valerio 2014
        """
      }
 , { id = "##252"
      , tags = [ "CYPR?", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
 󱂐󱁎󱁓nonver Source Valerio 2014
        """
      }
    , { id = "##253"
      , tags = [ "PPAP", "Psce", "CM1" ]
      , dir = UNKNOWN, text =
        """
󱂐󱁭nonver Source Valerio 2014
        """
    }
    , { id = "##254",
      , tags [ "Mvas", "CM1" ]
      , dir = UNKNOWN, text =
        """
noch einfuegen Source Egetmeyer 2016
        """
    }
    , { id = "##255",
      , tags [ "CM1" ]
      , dir = UNKNOWN, text =
        """
noch einfuegen Source Egetmeyer 2016
        """
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
