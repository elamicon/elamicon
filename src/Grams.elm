module Grams exposing (..)

import Dict exposing (Dict)
import String

import AstralString

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

-- Build gram stats by adding all grams of max length <max> found in list of
-- strings <seqs>
read : Int -> List String -> List Grams
read max seqs =
    let
        tokenSeqs = List.map AstralString.toList seqs
        addGrams n =
            let
                readSeqs seq grams =
                    if List.length seq >= n
                    then
                        readSeqs (List.drop 1 seq) (register (List.take n seq |> AstralString.fromList) grams)
                    else
                        grams
            in
                List.foldl readSeqs Dict.empty tokenSeqs
    in
        List.map addGrams <| List.range 1 max
