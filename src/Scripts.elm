module Scripts exposing (scripts, fromName, initialScript)

import Byblos as Byblos
import Elam as Elam
import Raetic as Raetic
import Lepontic as Lepontic
import Etruscan
import Runic
import DeirAlla

import List
import Script exposing (..)
import Specialchars exposing (..)
import Token exposing (..)
import WritingDirections exposing (..)


scripts : List Script
scripts =
    [ Byblos.byblos, Elam.elam, DeirAlla.deiralla, Raetic.raetic, Lepontic.lepontic, Etruscan.etruscan, Runic.runic ]

fromName : String -> Maybe Script
fromName n = List.head (List.filter (\s -> s.id == n) scripts)

initialScript =
    Elam.elam
