module Levenshtein exposing (distMap)

import List


distMap needle haystack =
    let
        needleChars =
            String.toList needle

        haystackChars =
            String.toList haystack

        descend needleChar rowDists =
            let
                startCost =
                    1 + Maybe.withDefault 0 (List.head rowDists)

                calcRow : List Char -> List Int -> List Int -> List Int
                calcRow chars dists collectedDists =
                    if List.isEmpty chars then
                        List.reverse collectedDists

                    else
                        let
                            charCost =
                                if needleChar == Maybe.withDefault ' ' (List.head chars) then
                                    0

                                else
                                    1

                            remainingChars =
                                Maybe.withDefault [] (List.tail chars)

                            remainingDists =
                                Maybe.withDefault [] (List.tail dists)

                            subCost =
                                charCost + Maybe.withDefault 0 (List.head dists)

                            insCost =
                                1 + Maybe.withDefault 0 (List.head dists)

                            delCost =
                                1 + Maybe.withDefault 0 (List.head remainingDists)

                            currentDist =
                                Maybe.withDefault 0 (List.minimum [ subCost, insCost, delCost ])
                        in
                        calcRow remainingChars remainingDists (currentDist :: collectedDists)
            in
            calcRow haystackChars rowDists [ startCost ]

        initialRow =
            List.repeat (String.length haystack + 1) 0
    in
    List.drop 1 (List.foldl descend initialRow needleChars)
