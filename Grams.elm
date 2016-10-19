module Grams exposing (..)

import Dict exposing (Dict)
import String

type alias Grams = Dict String Int

registerInc seq inc grams =
    let oneMore entry =
        case entry of
            Just count -> Just (count + inc)
            Nothing -> Just inc
    in Dict.update seq oneMore grams

register : String -> Grams -> Grams
register seq grams = registerInc seq 1 grams

tally grams =
    let rec (seq, count) =
        { seq = seq
        , count = count
        }
    in List.reverse (List.sortBy .count (List.map rec (Dict.toList grams)))

merge =
    Dict.foldl registerInc

read max seq =
    let last = String.length seq
        addGrams n =
            let reg i result =
                register (String.slice i (i+n) seq) result
            in List.foldl reg Dict.empty [0..(last - n)]
    in List.map addGrams [1..(max)]
