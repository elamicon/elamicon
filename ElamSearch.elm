module ElamSearch exposing (..)

import Regex
import Set
import Elam

type alias MatchLoc = (Int, Int)

uniqueSort = Set.toList << Set.fromList

regex : Bool -> Regex.Regex -> String -> List MatchLoc
regex reverseToo pat text =
    let
        find = Regex.find Regex.All pat

        -- We're matching against the indexed Elam chars only.
        -- This means all whitespace, guess marks, and other letters are removed.
        matchText = String.filter Elam.indexed text
        matchTextLen = String.length matchText


        fromStraight match =
            let
                matchLen = String.length match.match
            in
                (match.index, matchLen)

        matches = List.map fromStraight <| find matchText

        fromReverse match =
            let
                matchLen = String.length match.match
            in
                (matchTextLen - match.index - matchLen, matchLen)

        reverseMatches =
            if
                reverseToo
            then
                List.map fromReverse <| find (String.reverse matchText)
            else
                []
    in
        uniqueSort matches ++ reverseMatches


-- Split text into letter chunks. Characters which are not indexed are kept with the preceding letter.
-- The first slot does not contain an indexed letter but may contain other characters. All other
-- slots start with an indexed letter and may contain further characters which are not indexed.
letterSplit : String -> List String
letterSplit text =
    let addChar char result = case result of
        [] ->
            [String.fromChar char]
        head :: tail ->
            if
                Elam.indexed char
            then
                "" :: (String.cons char head) :: tail
            else
                (String.cons char head) :: tail
    in
        String.foldr addChar [""] text

type alias MatchContext =
    { fragment : Elam.Fragment
    , location : MatchLoc, start : (Int, Int), end : (Int, Int)
    , before : String, match : String, after : String
    }

type alias MatchResults =
    { items : List MatchContext
    , raw : List String
    , more : Bool
    }

extract : Int -> Int -> List Elam.Fragment -> (String -> List MatchLoc) -> MatchResults
extract limit contextLen fragments search =
    let
        addMatches fragment results =
            let
                letterSlots = letterSplit fragment.text
                matches = search fragment.text |> uniqueSort
                addMatch (index, length) results =
                    let
                        -- Slot zero contains prepended dross, the first indexed letter is in slot one
                        slotIndex = index + 1
                        lastSlotIndex = index + length
                        beforeStart = Basics.max 0 (slotIndex - contextLen)
                        beforeLen = Basics.min slotIndex contextLen
                        beforeText = String.concat (List.take beforeLen (List.drop beforeStart letterSlots))

                        -- The last slot of the match may contain appended characters which should not
                        -- be shown as part of the match, instead we prepend them to the context
                        -- following the match
                        matchReversed = List.reverse (List.take length (List.drop slotIndex letterSlots))
                        matchLast =
                            case (List.head matchReversed) of
                            Just s -> s
                            Nothing -> ""
                        (matchLastLetter, matchAppended) =
                            case (String.uncons matchLast) of
                                Just (l, a) -> (String.fromChar l, a)
                                Nothing -> ("", "")
                        matchText = String.concat (List.reverse (matchLastLetter :: List.drop 1 matchReversed))
                        afterText = String.concat (matchAppended :: List.take contextLen (List.drop (lastSlotIndex + 1) letterSlots))

                        -- Finding the line nr of the match is somewhat involved because the
                        -- linebreaks are buried in the slots
                        pos atSlot =
                            let
                                countLines slotStr (lc, cc) =
                                    -- This assumes there is only one linebreak per slot, a safe assumption for our corpus
                                    if String.contains "\n" slotStr
                                    then (lc+1, 1)
                                    else (lc, cc+1)
                            in
                                List.foldl countLines (1, 1) <| List.take atSlot letterSlots


                        -- Try to be lazy about it
                        result = \_ ->
                            { fragment = fragment
                            , location = (index, length)
                            , start = pos slotIndex
                            , end = pos lastSlotIndex
                            , before = beforeText
                            , match = matchText
                            , after = afterText
                            }
                    in
                        if limit > 0 && List.length results.items >= limit
                        then { results | more = True, raw = matchText :: results.raw }
                        else { results | items = result () :: results.items, raw = matchText :: results.raw }
            in
                List.foldl addMatch results matches
    in
        List.foldl addMatches {items=[], raw=[], more=False} fragments |>  \r -> { r | items = List.reverse r.items }
