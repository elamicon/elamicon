module RegexMaybe exposing
    ( regex
    )

import Regex
import Maybe exposing (Maybe)
import Native.RegexMaybe

{-| Try to build a regex and return Nothing if that fails -}

regex : String -> Maybe Regex.Regex
regex =
  Native.RegexMaybe.regex
