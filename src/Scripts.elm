module Scripts exposing (scripts, fromName, initialScript, sylDict, syllabizer)

import Byblos as Byblos
import Elam as Elam
import Raetic as Raetic
import Lepontic as Lepontic
import Etruscan
import Runic

import Dict exposing (Dict)
import List
import Regex
import Script exposing (..)
import Specialchars exposing (..)
import Set exposing (Set)
import String
import Token exposing (..)
import WritingDirections exposing (..)


scripts : List Script
scripts =
    [ Byblos.byblos, Elam.elam, Raetic.raetic, Lepontic.lepontic, Etruscan.etruscan, Runic.runic ]

fromName : String -> Maybe Script
fromName n = List.head (List.filter (\s -> s.id == n) scripts)

initialScript =
    Elam.elam


-- Digest the mapping from letters to "spoken sound" into a dictionary


sylDict : String -> Dict.Dict Token String
sylDict strMap =
    let
        lines =
            String.lines strMap

        addRepl : String -> Char -> Dict.Dict Token String -> Dict.Dict Token String
        addRepl target source state =
            Dict.insert source target state

        addLine line state =
            let
                sylls =
                    String.words line

                target =
                    Maybe.withDefault "" (List.head sylls)

                sources : List Token
                sources =
                    List.concat <| List.map Token.toList (Maybe.withDefault [] (List.tail sylls))
            in
            if List.isEmpty sylls then
                state

            else
                List.foldr
                    (addRepl target)
                    state
                    sources
    in
    List.foldl addLine Dict.empty lines



-- Function that replaces letters with their "spoken sound" based on a
-- mapping given as string. Each line defines a mapping from letters to spoken
-- sound. The first word of each line is the spoken sound, separated from
-- the letters that are expected to sound like that.
-- Based on the mapping
--     why Yy
--     oh Oo
-- this function would turn "Y o y" into "why oh why".


syllabizer : String -> String -> String
syllabizer strMap =
    let
        map =
            sylDict strMap

        replacer char =
            Maybe.withDefault (String.fromChar char) (Dict.get char map)
    in
    String.toList >> List.map replacer >> String.concat


