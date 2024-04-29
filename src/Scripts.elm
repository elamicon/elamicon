module Scripts exposing (scripts, fromName, initialScript, sylDict)

import Byblos as Byblos
import Elam as Elam
import Raetic as Raetic
import Lepontic as Lepontic
import Etruscan
import Runic
import DeirAlla

import Dict
import List
import Script exposing (..)
import Specialchars exposing (..)
import String
import Token exposing (..)
import WritingDirections exposing (..)


scripts : List Script
scripts =
    [ Byblos.byblos, Elam.elam, DeirAlla.deiralla, Raetic.raetic, Lepontic.lepontic, Etruscan.etruscan, Runic.runic ]

fromName : String -> Maybe Script
fromName n = List.head (List.filter (\s -> s.id == n) scripts)

initialScript =
    Elam.elam


-- Digest the mapping from letters to "spoken sound" into a dictionary
-- Replaces letters with their "spoken sound" based on a
-- mapping given as string. Each line defines a mapping from letters to spoken
-- sound. The first word of each line is the spoken sound, separated from
-- the letters that are expected to sound like that.
-- Based on the mapping
--     why Yy
--     oh Oo
-- this dict would turn "Y o y" into "why oh why".

sylDict : String -> Dict.Dict Token String
sylDict strMap =
    let
        addLine line state =
            case String.words line of
                target :: sourceTokens :: _ ->
                    List.foldl (\k -> Dict.insert k target) state (Token.toList sourceTokens)
                _ ->
                    state
    in
    List.foldl addLine Dict.empty (String.lines strMap)
