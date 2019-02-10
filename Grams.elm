module Grams exposing (read, tally)
{-| Database to find repeated subsequences in character sequences -}
import Dict exposing (Dict)
import String

type alias Grams = Dict String Int

empty : Grams
empty = Dict.empty

registerInc seq inc grams =
    let oneMore entry =
        case entry of
            Just count -> Just (count + inc)
            Nothing -> Just inc
    in Dict.update seq oneMore grams

register : String -> Grams -> Grams
register seq grams = registerInc seq 1 grams

{-| Get the list of gram count per length -}
tally : Grams -> List { seq: String, count: Int }
tally grams =
    let rec (seq, count) =
        { seq = seq
        , count = count
        }
    in List.reverse (List.sortBy .count (List.map rec (Dict.toList grams)))

{-| Construct Grams from strings -}
read : Int -> List String -> List Grams
read max seqs =
    let addGrams n =
            let readSeq seq grams =
                    let last = String.length seq
                        reg i result = register (String.slice i (i+n) seq) result
                    in List.foldl reg grams <| List.range 0 (String.length seq - n)
            in List.foldl readSeq empty seqs
                    in List.map addGrams <| List.range 1 max
