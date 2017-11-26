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
    [ { id = "##001", group = "ENKO Atab", dir = UNKNOWN, text =
        """
󱀀󱀁󱀂󱀃󱀄󱀅󱀆󱀈
󱀊󱀋󱀌󱀍󱀎󱀏󱀐
󱀑󱀒󱀓󱀔󱀕󱀖
        """
      }
    , { id = "##001r", group = "ENKO Atab", dir = UNKNOWN, text =
        """
󱀇󱀉
        """
      }
    , { id = "##002", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱈪󱂎󱆲󱂧󱀱
        """
      }
    , { id = "##003", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆳󱁖󱀤󱇸
        """
      }
    , { id = "##004", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅹󱀾󱀳󱂧󱆌
        """
      }
    , { id = "##005", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁘󱇛󱇉
        """
      }
    , { id = "##006", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂏󱀛󱀬󱁖󱂧󱀹
        """
      }
    , { id = "##007", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁊󱂖󱈫󱅺
        """
      }
    , { id = "##008", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀󱀾󱀹󱂈
        """
      }
    , { id = "##009", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##010", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##011", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱈬󱁉󱀡
        """
      }
    , { id = "##012", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇛󿊀󿊀󿊀󱆲󱁟󱀞󱇊
        """
      }
    , { id = "##013", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆬󱅠󱁘󱇸󱇛󱅡󱇸
        """
      }
    , { id = "##014", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁳󱂉󱂧󱄺
        """
      }
    , { id = "##015", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀛󱂄󱁵󱀼󿊀󿊀
        """
      }
    , { id = "##016", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇍󱁮󱀛󱇀󱉖󿊀󱇸
        """
      }
    , { id = "##016r", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀󱂧󿊀
        """
      }
    , { id = "##018", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅹󱀾󱀳󱂧󱅒
        """
      }
    , { id = "##018r", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀
        """
      }
    , { id = "##020", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁒󱁠󱂊󱂦󱀫󱀚
        """
      }
    , { id = "##021", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇦󱁎󱇾󱂧󱄹󱆣󱇧󱀻󱀜󱂧
        """
      }
    , { id = "##022", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱂦󱀻󱀞󱆾
        """
      }
    , { id = "##023", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅣󱇽󱂒
        """
      }
    , { id = "##024", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁮󱀚󱆿󱂛󱁮󱂦󱆼
        """
      }
    , { id = "##025", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅢󱁵󱀣󱇳󱀵󱁭󱅆󱅃󱁭
        """
      }
    , { id = "##026", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀵󱆭󱆍󱀤󱇼
        """
      }
    , { id = "##027", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀮󱀰󱄿󱂦󱉤
        """
      }
    , { id = "##028", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂛󱂈󱁃
        """
      }
    , { id = "##029", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀫󱈁󱇁󱂦󱂐
        """
      }
    , { id = "##030", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀯󱀰󱀣󱂧󱁗󱅿󱁃󱂊
        """
      }
    , { id = "##031", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱀸󱂊󿊀
        """
      }
    , { id = "##032", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱅤󱁬󱁽
        """
      }
    , { id = "##033", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁾󱁵󱀷
        """
      }
    , { id = "##034", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁵󱂇󱂀󱉖󱀹
        """
      }
    , { id = "##035", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅄󱆝󱂧󱀛󱂓󱁉󱁘
        """
      }
    , { id = "##036", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆴󱇂󱂦
        """
      }
    , { id = "##037", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇨󱆁󱇃󱂧󱀵󱀯
        """
      }
    , { id = "##038", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆂󱀰󱂦󱁒
        """
      }
    , { id = "##039", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆀󱀯󱁻󱂀
        """
      }
    , { id = "##040", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇩󱆤󱁻
        """
      }
    , { id = "##041", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁶󱂒󱂎󱀵󱂧󱀛
        """
      }
    , { id = "##042", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀗󱁻󱂁󱂞
        """
      }
    , { id = "##043", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀗󱀵󱆡󱁻󱉖󱄸
        """
      }
    , { id = "##044", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇿󱁗󱅇󱉖󱁗
        """
      }
    , { id = "##045", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁿󱂓󱂊󱉖󱂞
        """
      }
    , { id = "##046", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂛󱁧󱇜󱀤󱅤󱉖󱂞
        """
      }
    , { id = "##047", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅽󱁟󱇃󱅓󱂛
        """
      }
    , { id = "##048", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁮󱀚󱂌󱉖󱀵
        """
      }
    , { id = "##049", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂔󱁭󱀬󱁥󱂧󱀣
        """
      }
    , { id = "##050", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂛󱁄󱈭󱁗
        """
      }
    , { id = "##051", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅾󱈮󱂋󱂧󱀮
        """
      }
    , { id = "##052", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁧󱂛󱁤󱉖󱀵
        """
      }
    , { id = "##053", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇝󱂛󱀵
        """
      }
    , { id = "##054", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱀥󱁵󱁻󱅐
        """
      }
    , { id = "##055", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁿󱂗󱂋󱉖󱁍
        """
      }
    , { id = "##056", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀻󱀬󱁬󱂦󱁵
        """
      }
    , { id = "##057", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀸󱁵󱂌󱂧󱄼
        """
      }
    , { id = "##058", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀞󱀹󱁵󱇄󱂦󱆃
        """
      }
    , { id = "##059", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆯󱂊󱂦󱁖
        """
      }
  , { id = "##060", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱀞󱁤󱂄󱆡
        """
      }
  , { id = "##061", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱂧󱀞
        """
      }
  , { id = "##062", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀸󱅍󱂦󱁆
        """
      }
  , { id = "##063", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁾󱂓󱇃
        """
      }
  , { id = "##064", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱅥󱆋󱅈󱀝󱂑󱁾󱈩
        """
      }
  , { id = "##065", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂛󱀵󱁝
        """
      }
  , { id = "##066", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆔󱅅󱂦󱆔󱅀󱂃󱂀
        """
      }
  , { id = "##067", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀘󱅗󱆡󱁺󱂦󱁢
        """
      }
  , { id = "##068", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱂊󱂦󱅀󱁭󱀚
        """
      }
  , { id = "##069", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀗󱀵󱁭󱁻󱂧󱂞
        """
      }
  , { id = "##070", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁣󱀜󱀶󱂧󱁴󱀣󱀥󱁭
        """
      }
  , { id = "##071", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁸󱁺󱂁󱂦󱁹
        """
      }
  , { id = "##072", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂐󱁿󱇙󱂊󱂦󱀻
        """
      }
  , { id = "##073", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀
        """
      }
  , { id = "##074", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󿊀
        """
      }
  , { id = "##075", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀚󱁇󱀪󱁩󱂦󱀜
        """
      }
  , { id = "##076", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁢󱀝󱀶󱂧󱁕
        """
      }
  , { id = "##077", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱆄󱁬󱅑󱂧󱆥
        """
      }
  , { id = "##078", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱈯󱀣
        """
      }
  , { id = "##079", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂏󱀟󱀵󿊀󿊀
        """
      }
  , { id = "##080", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁴󱇅󱂦󱇞󱁍󿊀
        """
      }
  , { id = "##081", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁶󱂐󱁞󱀢󱂦󱀹
        """
      }
  , { id = "##082", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀩󱀶󱇪󱂊󱂦󱂛
        """
      }
  , { id = "##083", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱂞󿊀󿊀󱂦󱂞
        """
      }
  , { id = "##084", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱈪󱀥󱀞󱀥
        """
      }
  , { id = "##085", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱇌󱅃󱁵󱁻󱂦󱂛
        """
      }
  , { id = "##086", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱀞󱀞󱀚󱂍󱈰
        """
      }
  , { id = "##087", group = "ENKO Abou", dir = UNKNOWN, text =
        """
󱁝󱀰󱀤󱁑
        """
      }
  , { id = "##088", group = "HALA Abou", dir = UNKNOWN, text =
        """
󱂐󱁾󱂗󱂊󱁵󱀣
        """
      }
  , { id = "##089", group = "HALA Abou", dir = UNKNOWN, text =
        """
󱁣󱀜󱅚󱂧󱁰
        """
      }
  , { id = "##090", group = "KITI Abou", dir = UNKNOWN, text =
        """
󱆵󱀚󱅔󱆷
        """
      }
  , { id = "##091", group = "KITI Abou", dir = UNKNOWN, text =
        """
󱀚󱅁󱂔󿊀
        """
      }
  , { id = "##092", group = "ATHI Adis", dir = UNKNOWN, text =
        """
󱆕󱅦󱀚󱄻
󱉘󱉙󱉚
        """
      }
  , { id = "##093", group = "ENKO Aost", dir = UNKNOWN, text =
        """
󱂡󱉛󱉜
󱂢󱉝󱉞
        """
      }
  , { id = "##094", group = "ENKO Aost ", dir = UNKNOWN, text =
        """
󱇆󱂔󱀛󿊀󿊀󿊀
󱅻󱂦󱆅󱇰󱂧󱂒󱅴
󱁭󱂧󱅧󱅻󱂧󱁒󱀰
󿊀
󿊀󱀜󱁧󱂓
        """
      }
  , { id = "##095", group = "ENKO Apes", dir = UNKNOWN, text =
        """
󱂋󱁵󱀧󱂦󱀜󱂘󱆖
        """
      }
  , { id = "##096", group = "ENKO Apla", dir = UNKNOWN, text =
        """
󱀚󱂧󱂐
        """
      }
  , { id = "##097", group = "ENKO Arou", dir = UNKNOWN, text =
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
  , { id = "##098", group = "KALA Arou", dir = UNKNOWN, text =
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
  , { id = "##099", group = "KALA Arou", dir = UNKNOWN, text =
        """
󿊀󿊀󱁞󱀚󱂧󱆰
󱁑󱁁󱅨󿊀
󿊀󿊀󿊀󿊀󿊀󱁒
        """
      }
  , { id = "##100", group = "KALA Arou", dir = UNKNOWN, text =
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
  , { id = "##101", group = "KALA Arou", dir = UNKNOWN, text =
        """
󱂔󱀶󱂃
󱁓󱀸󱈫󱀚
󱂐󱁱󱀵󿊀
󱇻
        """
      }
  , { id = "##102", group = "KALA Arou", dir = UNKNOWN, text =
        """
󿊀󱀶󱂃󱂦󱂔󱁭󿊀󿊀
󿊀󱁓󱉀󱁧󱁭
󿊀󱁁󱁢󱇳󱀭󱉩󿊀󱀻
󱂍󱀤󱂦󱀣󱁪󱇴
󱀵󱈾󱁀󱈿󱁭󱂎󱁀󱉀
󱁅󿊀
        """
      }
  , { id = "##103", group = "PSIL Asta", dir = UNKNOWN, text =
        """
󱁚󱀙󱀥󱁭
        """
      }
  , { id = "##104", group = "ALAS Avas", dir = UNKNOWN, text =
        """
󱆨󱀵󿊀󿊀
        """
      }
  , { id = "##105", group = "ARPE Avas", dir = UNKNOWN, text =
        """
󱆇󱄻󱂊󱂣󱆎󱂈󱈨
        """
      }
  , { id = "##106", group = "ATHI Avas", dir = UNKNOWN, text =
        """
󱅶󱁿󱁿󱀚󱈫󱁩󱀵
        """
      }
  , { id = "##107", group = "ATHI Avas", dir = UNKNOWN, text =
        """
󱉁󿊀
        """
      }
  , { id = "##108", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱅛󱄽󱅩󱅜󱇈
        """
      }
  , { id = "##109", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱁿󱀮󱁵󱂦󱂐󱁮󱀚󱂋󱂦󱂕󱇆
        """
      }
  , { id = "##110", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱂦󱅪󱆩󱁢󱀵
        """
      }
  , { id = "##111", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱄽󱀵󱀬󱀵󱂦󱂛
        """
      }
  , { id = "##112", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱇏󱁵󱁪󱂁󱇇󱀵
        """
      }
  , { id = "##113", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱇐
󱅕
        """
      }
  , { id = "##114", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱀵
󱄷
        """
      }
  , { id = "##115", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱀵
󱆶
        """
      }
  , { id = "##116", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱁊change
󱀝doubt
        """
      }
  , { id = "##117", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱂑
󱉂evtl zwei z
        """
      }
  , { id = "##118", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱆗󱇳󱆘
        """
      }
  , { id = "##119", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱀶
󱅵
        """
      }
  , { id = "##120", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󿊀󱂦󱂛
        """
      }
  , { id = "##121", group = "ENKO Avas", dir = UNKNOWN, text =
        """
󱀸󱂧󱀵󱂧󱀳
        """
      }
  , { id = "##122", group = "HALA Avas", dir = UNKNOWN, text =
        """
󱅝
󱅞
        """
      }
  , { id = "##123", group = "IDAL Avas", dir = UNKNOWN, text =
        """
󱅼󱅼󱆜
        """
      }
  , { id = "##124", group = "IDAL Avas", dir = UNKNOWN, text =
        """
󱁍󱁢󱁟󱆸
󿊀󿊀󱀵mit oberer z󱂃
        """
      }
  , { id = "##125", group = "KALA Avas", dir = UNKNOWN, text =
        """
󱁋󱀝ligatur
        """
      }
  , { id = "##126", group = "KALA Avas", dir = UNKNOWN, text =
        """
󱆞
󱁵
󱀵mit oberer z
        """
      }
  , { id = "##127", group = "KATY Avas", dir = UNKNOWN, text =
        """
󱅷
󱅫
󱈦
        """
      }
  , { id = "##128", group = "KATY Avas", dir = UNKNOWN, text =
        """
󱁜󱁙󱁶󱈧
        """
      }
  , { id = "##129", group = "KATY Avas", dir = UNKNOWN, text =
        """
󱆺
󱆢
        """
      }
  , { id = "##130", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀝󱁉󱂋󱀵󱆈
        """
      }
  , { id = "##131", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀚󱅟nonver
        """
      }
  , { id = "##132", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱅲󱅬
        """
      }
  , { id = "##133", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱅭󱅳
        """
      }
  , { id = "##134", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱅳󱅮
        """
      }
  , { id = "##135", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵󱇷󱇣
        """
      }
  , { id = "##136", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵plus ein z
        """
      }
  , { id = "##137", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵󱂦󱇟rhomb buendig
        """
      }
  , { id = "##138", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵󱂧󿊀
        """
      }
  , { id = "##139", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵󱉬
        """
      }
  , { id = "##140", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱅯󱁭
        """
      }
  , { id = "##141", group = "KITI Avas", dir = UNKNOWN, text =
        """
irgend
󱀵
󱀵
        """
      }
  , { id = "##142", group = "KITI Avas", dir = UNKNOWN, text =
        """
neu schreib
        """
      }
  , { id = "##143", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵󱂦󱇠change
        """
      }
  , { id = "##144", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱄾󱀵
        """
      }
  , { id = "##145", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱉟󱁋󱉠
        """
      }
  , { id = "##146", group = "KITI Avas", dir = UNKNOWN, text =
        """
󿊀󱀴
        """
      }
  , { id = "##146r", group = "KITI Avas", dir = UNKNOWN, text =
        """
neu schreib
        """
      }
  , { id = "##147", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱀵󱂧󱇡change
        """
      }
  , { id = "##148", group = "KITI Avas", dir = UNKNOWN, text =
        """
󱂕change
󱅖
        """
      }
  , { id = "##149", group = "KOUR Avas", dir = UNKNOWN, text =
        """
󱂛󱁡
        """
      }
  , { id = "##150", group = "KOUR Avas", dir = UNKNOWN, text =
        """
󱂛change󱁡
        """
      }
  , { id = "##151", group = "KOUR Avas", dir = UNKNOWN, text =
        """
󱁡nonver
        """
      }
  , { id = "##152", group = "KOUR Avas", dir = UNKNOWN, text =
        """
󱂛󱁠nonver
        """
      }
  , { id = "##153", group = "MAAP Avas", dir = UNKNOWN, text =
        """
󱅸
󱆮
        """
      }
  , { id = "##154", group = "MAAP Avas", dir = UNKNOWN, text =
        """
󱂓󱇈
        """
      }
  , { id = "##155", group = "MAAP Avas", dir = UNKNOWN, text =
        """
neu schreib
        """
      }
  , { id = "##156", group = "MAAP Avas", dir = UNKNOWN, text =
        """
neu schreib󱀵
        """
      }
  , { id = "##157", group = "MARO Avas", dir = UNKNOWN, text =
        """
󱁋󱆉󱀵󱂦󱁒󱀻󱁧󱀵󱂦
        """
      }
  , { id = "##158", group = "MYRT Avas", dir = UNKNOWN, text =
        """
󱂑󱁾change󱀾󱇫
        """
      }
  , { id = "##159", group = "MYRT Avas", dir = UNKNOWN, text =
        """
󱀸󿊀changed
        """
      }
 , { id = "##160", group = "TOUM Avas", dir = UNKNOWN, text =
        """
󿊀󱂧󱅰󿊀
󱇑
󱅍
󱂚󱀰󿊀nonver unless l 1
        """
      }
 , { id = "##161", group = "KITI Iins", dir = UNKNOWN, text =
        """
󱇢󱂓󱀵
󱁵󱂇󱂂󱂧󱂛󱀵󱁝󱀳󱀵󱂣󱂐
        """
      }
 , { id = "##162", group = "KITI Iins", dir = UNKNOWN, text =
        """
󱇒󱀛󱁘󱆟
󱀵󱂆󱂌󱂦󱀵plus numeralia
        """
      }
 , { id = "##163", group = "KITI Ipla", dir = UNKNOWN, text =
        """
󱆱󱇬󱇤󱆙󱁭invert
        """
      }
 , { id = "##163r", group = "KITI Ipla", dir = UNKNOWN, text =
        """
󱇓󱁺󱂧󱂐󱁮󱀚󱉦󱀵
        """
      }
 , { id = "##164", group = "ENKO Mbij", dir = UNKNOWN, text =
        """
󱉃󱉄󱉅󱉆󿊀󱉇󿊀󿊀
        """
      }
 , { id = "##165", group = "KALA Mbij", dir = UNKNOWN, text =
        """
󱂈󱇭󱁁󱆏invert poss
        """
      }
 , { id = "##166", group = "KALA Mbij", dir = UNKNOWN, text =
        """
󱂈󱂛󱁁󱆐invert poss
        """
      }
 , { id = "##167", group = "", dir = UNKNOWN, text =
        """
󱀵󱂧󱁷irgend
        """
      }
 , { id = "##168", group = "KITI Mexv", dir = UNKNOWN, text =
        """
󱀮󱀰󱀵󱂧󱇚󱁭󱀵
        """
      }
 , { id = "##169", group = "ENKO? Mins", dir = UNKNOWN, text =
        """
󱇲󱂦unsicher
󱁟󱁶
        """
      }
 , { id = "##170", group = "PPAP Mins", dir = UNKNOWN, text =
        """
󱁢󱀦󱀶󱀚󱀨
        """
      }
 , { id = "##171", group = "PPAP Mins", dir = UNKNOWN, text =
        """
neu schreib
        """
      }
 , { id = "##172", group = "PPAP Mins", dir = UNKNOWN, text =
        """
󱈀󱂌nonver keine schrift
        """
      }
 , { id = "##173", group = "PYLA Mins", dir = UNKNOWN, text =
        """
󱀸󱀳eckig nonver
        """
      }
 , { id = "##174", group = "ENKO Mlin", dir = UNKNOWN, text =
        """
󱇔󱂧󱀵
        """
      }
 , { id = "##175", group = "ENKO Mlin", dir = UNKNOWN, text =
        """
󱇕󱉈
󱇖󱁈󱀵󱂠󱀵
        """
      }
 , { id = "##176", group = "ENKO Mlin", dir = UNKNOWN, text =
        """
󱇗󱉖󱉉
        """
      }
 , { id = "##177", group = "PYLA Mlin ", dir = UNKNOWN, text =
        """
󱀬
󱀵
󱀸duktus!
󿊀
        """
      }
 , { id = "##178", group = "CYPR Mvas", dir = UNKNOWN, text =
        """
󱂓󱁭󱆛
        """
      }
 , { id = "##179", group = "CYPR Mvas", dir = UNKNOWN, text =
        """
󱂐󱂚󱀚󱅀󱀵󱂧󱀚󱀚󱂋󱂧󱀞󱅇
        """
      }
 , { id = "##180", group = "CYPR Mvas", dir = UNKNOWN, text =
        """
󱀻󱁩󱀥󱂀󱀵󱂧󱉥󱀰letztes
        """
      }
 , { id = "##181", group = "CYPR Mvas", dir = UNKNOWN, text =
        """
󱂆󱄿󱀮󱅙󱂧󱁊
        """
      }
 , { id = "##182", group = "ENKO Mvas", dir = UNKNOWN, text =
        """
󱁵󱂚󱆚󱀵󱂧󱉡󱉢zweites
        """
      }
 , { id = "##183", group = "ENKO Mvas", dir = UNKNOWN, text =
        """
󱂐󱂚󱀚󱄿󱀵󱂦󱇱zweites
        """
      }
 , { id = "##184", group = "MYRT Mvas", dir = UNKNOWN, text =
        """
󱁋󱉖󱂔󱉪
        """
      }
 , { id = "##185", group = "MYRT Mvas", dir = UNKNOWN, text =
        """
󱁌󱂓󱉫
        """
      }
 , { id = "##186", group = "PPAP Mvas", dir = UNKNOWN, text =
        """
󱁷󱀞󱁷󱆻󱀵zweites
        """
    }
  , { id = "##187", group = "ENKO Pblo", dir = UNKNOWN, text =
        """
󱅎󱀮󿊀󿊀󿊀󱀻ergaenzen
        """
    }
  , { id = "##188", group = "KITI Pblo", dir = UNKNOWN, text =
        """
󱂅󱀿󿊀
        """
    }
  , { id = "##189", group = "PPAP Pblo", dir = UNKNOWN, text =
        """
󱂐󱂧󱂒change
        """
    }
  , { id = "##190", group = "PPAP Pblo", dir = UNKNOWN, text =
        """
󱇥󱉖󱀵check
        """
    }
  , { id = "##191", group = "KALA Ppla", dir = UNKNOWN, text =
        """
󱉖󱂡
        """
    }
  , { id = "##192", group = "KALA Ppla", dir = UNKNOWN, text =
        """
󱂛󱆊󱇮zweites
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
