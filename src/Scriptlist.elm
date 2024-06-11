module Scriptlist exposing (scripts, fromName, initialScript)

import Scripts.Byblos as Byblos
import Scripts.Elam as Elam
import Scripts.Raetic as Raetic
import Scripts.Lepontic as Lepontic
import Scripts.Etruscan as Etruscan
import Scripts.Runic as Runic
import Scripts.DeirAlla as DeirAlla

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
