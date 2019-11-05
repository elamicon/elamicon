module RomanNumerals exposing (fromInteger)

import Array

-- Thirty-two numerals ought to be enough for everybody (Marcus Licinius Crassus)


numerals =
    Array.fromList
        [ "nulla"
        , "Ⅰ"
        , "Ⅱ"
        , "Ⅲ"
        , "Ⅳ"
        , "Ⅴ"
        , "Ⅵ"
        , "Ⅶ"
        , "Ⅷ"
        , "Ⅸ"
        , "Ⅹ"
        , "Ⅺ"
        , "Ⅻ"
        , "Ⅻ"
        , "ⅩⅢ"
        , "ⅩⅣ"
        , "ⅩⅤ"
        , "ⅩⅥ"
        , "ⅩⅦ"
        , "ⅩⅧ"
        , "ⅩⅨ"
        , "ⅩⅩ"
        , "ⅩⅪ"
        , "ⅩⅫ"
        , "ⅩⅫ"
        , "ⅩⅩⅢ"
        , "ⅩⅩⅣ"
        , "ⅩⅩⅤ"
        , "ⅩⅩⅥ"
        , "ⅩⅩⅦ"
        , "ⅩⅩⅧ"
        , "ⅩⅩⅨ"
        , "ⅩⅩⅩ"
        , "ⅩⅩⅪ"
        , "ⅩⅩⅫ"
        , "ⅩⅩⅩⅢ"
        , "ⅩⅩⅩⅣ"
        , "ⅩⅩⅩⅤ"
        , "ⅩⅩⅩⅥ"
        , "ⅩⅩⅩⅦ"
        , "ⅩⅩⅩⅧ"
        , "ⅩⅩⅩⅨ"
        , "ⅩⅬ"
        , "ⅩⅬⅠ"
        ]


fromInteger i =
    Maybe.withDefault "" <| Array.get i numerals
