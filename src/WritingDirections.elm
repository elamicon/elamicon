module WritingDirections exposing (..)

-- Linear Elam texts are written left-to-right (LTR) and right-to-left (RTL).
-- The majority is written RTL. We display them in their original direction, but
-- allow coercing the direction to one of the two for all panels.
-- There is speculation that at least one of the fragments is written in
-- boustrophedon meaning alternating writing direction per line.
type Dir
    = UNKNOWN   -- no presumed writing direction
    | LTR       -- assumed to be written left-to-right
    | RTL       -- assumed to be written right-to-left
    | BoustroR  -- assumed to be written boustrophedon, first line right-to-left
