module Search exposing (MatchContext, MatchLoc, MatchResults, Search, bidirectional, extract, fuzzy, regex, uniqueSort)

import Levenshtein
import Regex
import Script exposing (..)
import Scriptlist exposing (..)
import Set


type alias MatchLoc =
    ( Int, Int )


type alias Search =
    String -> List MatchLoc


uniqueSort =
    Set.toList << Set.fromList



-- Build a regex search


regex : Regex.Regex -> Search
regex pat text =
    let
        find =
            Regex.find pat

        -- The returned match index miscounts astral chars
        extractIndex match =
            ( String.length (String.slice 0 match.index text)
            , String.length match.match
            )
    in
    find text |> List.map extractIndex


fuzzy : Int -> String -> Search
fuzzy fuzz query =
    let
        distMap =
            Levenshtein.distMap query

        needleLen =
            String.length query

        maxDist =
            Basics.min fuzz (needleLen - 1)

        extendRange ( pos, dist ) state =
            let
                ( reserve, ranges ) =
                    state

                ( rangePos, rangeLen ) =
                    Maybe.withDefault ( pos, 0 ) (List.head ranges)

                newReserve =
                    if dist < maxDist then
                        needleLen - 1

                    else
                        reserve - 1
            in
            if newReserve < 1 then
                state

            else if rangePos > pos + 1 then
                ( newReserve, ( pos, 1 ) :: ranges )

            else
                ( newReserve, ( pos, rangeLen + 1 ) :: Maybe.withDefault [] (List.tail ranges) )
    in
    distMap >> List.indexedMap (\a b -> ( a, b )) >> List.foldr extendRange ( 0, [] ) >> Tuple.second



-- Turn a search into a bidirectional search by running the search against
-- the original and the reverted text and combining the results.


bidirectional : Search -> Search
bidirectional search text =
    let
        len =
            String.length text

        matches =
            search text

        reverseIndex ( matchIndex, matchLen ) =
            ( len - matchIndex - matchLen, matchLen )

        reverseMatches =
            search (String.reverse text) |> List.map reverseIndex
    in
    uniqueSort (reverseMatches ++ matches)


type alias MatchContext =
    { fragment : FragmentDef
    , location : MatchLoc
    , start : ( Int, Int )
    , end : ( Int, Int )
    , before : String
    , match : String
    , after : String
    }


type alias MatchResults =
    { items : List MatchContext
    , raw : List String
    , more : Bool
    }


-- Run a search over fragments
--   indexed: Which characters to include in the search
--   limit: only return this many matches
--   contextLen: how many chars of context to include with each match
--   fragments: list of fragments to search
--   search: search function
extract : (Char -> Bool) -> Int -> Int -> List FragmentDef -> Search -> MatchResults
extract indexed limit contextLen fragments search =
    let
        -- Split text into letter chunks. Characters which are not indexed are kept with the preceding letter.
        -- The first slot does not contain an indexed letter but may contain other characters. All other
        -- slots start with an indexed letter and may contain further characters which are not indexed.
        letterSplit : String -> List String
        letterSplit =
            let
                addChar char result =
                    case result of
                        [] ->
                            [ String.fromChar char ]

                        head :: tail ->
                            if indexed char then
                                "" :: String.cons char head :: tail

                            else
                                String.cons char head :: tail
            in
            String.toList >> List.foldr addChar [ "" ]

        addMatches fragment results =
            let
                -- We're matching against the indexed chars only.
                -- This means all whitespace, guess marks, and other letters are removed.
                matchNormalized =
                    String.filter indexed fragment.text

                matches =
                    search matchNormalized |> uniqueSort

                letterSlots =
                    letterSplit fragment.text

                addMatch ( index, length ) resultMatches =
                    let
                        -- Slot zero contains prepended dross, the first indexed letter is in slot one
                        slotIndex =
                            index + 1

                        lastSlotIndex =
                            index + length

                        beforeStart =
                            Basics.max 0 (slotIndex - contextLen)

                        beforeLen =
                            Basics.min slotIndex contextLen

                        beforeText =
                            String.concat (List.take beforeLen (List.drop beforeStart letterSlots))

                        -- The last slot of the match may contain appended characters which should not
                        -- be shown as part of the match, instead we prepend them to the context
                        -- following the match
                        matchReversed =
                            List.reverse (List.take length (List.drop slotIndex letterSlots))

                        ( matchLastLetter, matchAppended ) =
                            case List.head matchReversed of
                                Just s ->
                                    case String.uncons s of
                                        Just (headChar, rest) ->
                                            ( String.fromChar headChar, rest )
                                        _ ->
                                            ( "", "" )

                                _ ->
                                    ( "", "" )

                        matchText =
                            String.concat (List.reverse (matchLastLetter :: List.drop 1 matchReversed))

                        afterText =
                            String.concat (matchAppended :: List.take contextLen (List.drop (lastSlotIndex + 1) letterSlots))

                        -- Finding the line nr of the match is somewhat involved because the
                        -- linebreaks are buried in the slots
                        pos atSlot =
                            let
                                -- first slot in the list doesn't count
                                slotsBefore =
                                    List.drop 1 <| List.take atSlot letterSlots

                                countLines slotStr ( lc, cc ) =
                                    -- This assumes there is only one linebreak per slot, a safe assumption for our corpus
                                    if String.contains "\n" slotStr then
                                        ( lc + 1, 1 )

                                    else
                                        ( lc, cc + 1 )
                            in
                            List.foldl countLines ( 1, 1 ) slotsBefore

                        -- Try to be lazy about it
                        result =
                            \_ ->
                                { fragment = fragment
                                , location = ( index, length )
                                , start = pos slotIndex
                                , end = pos lastSlotIndex
                                , before = beforeText
                                , match = matchText
                                , after = afterText
                                }
                    in
                    if limit > 0 && List.length resultMatches.items >= limit then
                        { resultMatches | more = True, raw = matchText :: resultMatches.raw }

                    else
                        { resultMatches | items = result () :: resultMatches.items, raw = matchText :: resultMatches.raw }
            in
            List.foldl addMatch results matches
    in
    List.foldl addMatches { items = [], raw = [], more = False } fragments |> (\r -> { r | items = List.reverse r.items })
