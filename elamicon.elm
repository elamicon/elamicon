import Html exposing (..)
import Html.App as Html
import Html.Events exposing (on, onClick, onInput, targetValue)
import Html.Attributes exposing (..)
import Dict
import String
import Regex
import Json.Decode
import List exposing (map)
import Set


-- List of letters found in Linear-Elam writings
--
-- Many letters are present in variations that only differ in small details.
-- Most of these variations are likely style differences as the writing
-- developed over the centuries. The differences may also be ornamental or
-- idiosyncratic. There are not enough samples to decide, maybe there never will
-- be.
--
-- We were very conservative when it came to lumping glyphs into letters and
-- many variants are preserved to allow alternate interpretations.
--
-- Note that the letters are encoded in the Unicode private-use area and will
-- not show their intended form unless you use the specially crafted "elamicon"
-- font. They are listed here in codepoint order.
letters =
    [ { char = '', syllable = [] }
    , { char = '', syllable = [ "na" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "uk ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "NAP"] }
    , { char = '', syllable = [ "NAP" ] }
    , { char = '', syllable = [ "en ?", "im ?"] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "šu" ] }
    , { char = '', syllable = [ "ša ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "in" ] }
    , { char = '', syllable = [ "ki" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "iš ?", "uš ?" ] }
    , { char = '', syllable = [ "tu ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "hu ?"] }
    , { char = '', syllable = [ "me ?" ] }
    , { char = '', syllable = [ "me ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "ši" ] }
    , { char = '', syllable = [ "še ?", "si ?" ] }
    , { char = '', syllable = [ "ak", "ik"] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "hal ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "ú" ] }
    , { char = '', syllable = [ "ni ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "piš ?" ] }
    , { char = '', syllable = [] }
    ]

-- List of "special" characters
--
-- Most of the artifacts did not make it through time in mint condition. The
-- "special" characters can be used to mark glyphs that are unreadable or
--  are guesses.
specialChars =
    [ { displayChar = "", char = '', description = "Platzhalter für unbekannte Zeichen" }
    , { displayChar = "", char = '', description = "Kann angefügt werden, um ein anderes Zeichen als schlecht lesbar zu markieren" }
    ]

-- We're nowhere near establishing a meaningful order to the letters.
letterList = List.map .char letters
letterMap = Dict.fromList (List.map2 (,) letterList letters)


-- The many letter variants are grouped into an alphabet with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the alphabet a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
alphabetPreset = "                                   "
alphabetList alphabet =
    let
        letterGroup letterString =
            case (String.toList letterString) of
                main :: ext -> (main, ext)
                _ -> ('?', []) -- should not be reachable?
    in
        map letterGroup (String.words alphabet)

-- Sanitize the alphabet string to include all Elam letters but no duplicates
completeAlphabet alphabet =
    let
        allLetters = Set.fromList letterList
        dedup letter (seen, dedupAlphabet) =
            if Set.member letter seen
            then
                (seen, dedupAlphabet)
            else
                if Set.member letter allLetters
                then
                    (Set.insert letter seen, dedupAlphabet ++ String.fromChar letter)
                else
                    (seen, dedupAlphabet ++ String.fromChar letter)

        (presentLetters, dedupedAlphabet) = List.foldl dedup (Set.empty, "") (String.toList alphabet)
        missingLetters = Set.diff allLetters presentLetters
    in
        dedupedAlphabet
        ++ " "
        ++ String.join " " (map String.fromChar (Set.toList missingLetters))

-- Linear Elam texts are written left-to-right (LTR) and right-to-left (RTL).
-- The majority is written RTL. We display them in their original direction, but
-- allow coercing the direction to one of the two for all panels.
type Dir = Original | LTR | RTL


fragments =
    [ { id = "A", dir = RTL, lines =
        [ ""
        , ""
        , ""
        , ""
        , ""
        ]
      }
    , { id = "B", dir = LTR, lines =
        [ ""
        , ""
        , ""
        ]
      }
    , { id = "C", dir = RTL, lines =
        [ ""
        , ""
        , ""
        , ""
        ]
      }
    , { id = "E", dir = LTR, lines =
        [ ""
        , ""
        , ""
        , ""
        ]
      }
    , { id = "Q", dir = LTR, lines =
        [ ""
        ]
      }
    , { id = "neuE", dir = RTL, lines =
        [ "XXXXXXXXXXXX"
        , "XXXXXXXXX"
        , "XXXXXXX"
        , "XXXXXXXXX"
        , "XXXXXXXXXX"
        , "XXXXXX"
        , "XXXXXXXXXX"
        , "XXXXXXXXXX"
        , "XXXXXXXXXXXX"
        ]
      }
    ]




main = Html.beginnerProgram { model = model, view = view, update = update }

type alias Pos = (String, Int, Int)
type alias Model = { dir : Dir, fixedBreak: Bool, selected : Maybe Pos, alphabet : String, sandbox: String }
model = { dir = Original, fixedBreak = True, selected = Nothing, alphabet = alphabetPreset, sandbox = "" }

type Msg
    = Select (String, Int, Int)
    | SetBreaking Bool
    | SetDir Dir
    | SetSandbox String
    | SetAlphabet String
    | AddChar String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetSandbox str -> { model | sandbox = str }
        AddChar char -> { model | sandbox = model.sandbox ++ char }
        Select pos -> { model | selected = Just pos }
        SetBreaking breaking -> { model | fixedBreak = breaking }
        SetDir dir -> { model | dir = dir }
        SetAlphabet new -> { model | alphabet = completeAlphabet new }


dirStr dir = case dir of
    LTR -> "LTR"
    _ -> "RTL"

dirDecoder : Json.Decode.Decoder Dir
dirDecoder = Html.Events.targetValue `Json.Decode.andThen` (\valStr -> case valStr of
    "Original" -> Json.Decode.succeed Original
    "LTR" -> Json.Decode.succeed LTR
    "RTL" -> Json.Decode.succeed RTL
    _ -> Json.Decode.fail ("dir " ++ valStr ++ "unknown"))

breakingDecoder : Json.Decode.Decoder Bool
breakingDecoder = Html.Events.targetValue `Json.Decode.andThen` (\valStr -> case valStr of
    "true" -> Json.Decode.succeed True
    "false" -> Json.Decode.succeed False
    _ -> Json.Decode.fail ("dir " ++ valStr ++ "unknown"))


view : Model -> Html Msg
view model =
    let effectiveDir original = if model.dir == Original then original else model.dir
        dirAttr original = dir (dirStr (effectiveDir original))

        -- There are two "guess" marker characters that are used depending on direction
        guessmarkDir original = Regex.replace Regex.All (Regex.regex "[]") (\_ -> if effectiveDir original == LTR then "" else "")

        letterCounter letters = String.toList >> List.filter (\candidate -> Set.member candidate (Set.fromList letters)) >> List.length

        alphabet =
            [ h2 [] [ text "Die Buchstaben" ]
            , ol [ dirAttr LTR, classList [ ("alphabet", True) ] ]
                ( List.map alphabetEntry (alphabetList model.alphabet)
                ++ List.map specialEntry specialChars
                )
            ]

        alphabetEntry (main, ext) =
            let
                info = Maybe.withDefault { char = '?', syllable = [] } (Dict.get main letterMap)
                letterEntry entryClass char = div [ classList [("elam", True), (entryClass, True)], onClick (AddChar (String.fromChar char)) ] [ text (String.fromChar char) ]
                syllableEntry syl = div [ class "syl" ] [ text syl ]
                letterCount = letterCounter (main :: ext) model.sandbox
            in
                li [ class "letter" ]
                    ( (if letterCount > 0 then [ div [ class "counter" ] [ text (toString letterCount) ] ] else [] )
                    ++ [ letterEntry "main" main ]
                    ++ (if ext /= [] then [ div [class "menu"] (map (letterEntry "ext") ext) ] else [])
                    ++ (map (letterEntry "ext") ext)
                    ++ [ div [ class "clear" ] [] ]
                    ++ (map syllableEntry info.syllable)
                    )

        specialEntry { displayChar, char, description } =
            li [ class "letter" ]
                [ div [ classList [("elam", True), ("main", True)], onClick (AddChar (String.fromChar char)), title description ] [ text ((guessmarkDir LTR) displayChar) ] ]


        -- HACK horrid workaround to throw off the differ.
        -- otherwise the textarea is not updated (this way it is recreated)
        updateTextareaWorkaround = List.repeat (String.length model.sandbox) (textarea [ Html.Attributes.style [ ("display", "none") ] ] [])


        playground =
            [ h2 [] [ text "Spielplatz" ]
            ] ++ updateTextareaWorkaround ++
            [ textarea
                [ class "elam"
                , dirAttr LTR
                , on "change" (Json.Decode.map SetSandbox Html.Events.targetValue)
                , onInput SetSandbox
                ] [ text ((guessmarkDir LTR) model.sandbox) ]
            ] ++ updateTextareaWorkaround


        settings =
            let dirOptAttrs val dir = [ value val, selected (dir == model.dir) ]
                breakOptAttrs val break = [ value val, selected (break == model.fixedBreak) ]
            in  [ h2 [] [ text "Einstellungen" ]
                , label []
                    [ text "Schreibrichtung"
                    , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                        [ option (dirOptAttrs "Original" Original) [ text "ursprünglich ⇔" ]
                        , option (dirOptAttrs "LTR" LTR) [ text "von links ⇒ nach rechts" ]
                        , option (dirOptAttrs "RTL" RTL) [ text "nach links ⇐ von rechts" ]
                        ]
                    ]
                , label []
                    [ text "Zeilenumbrüche"
                    , Html.select [ on "change" (Json.Decode.map SetBreaking breakingDecoder) ]
                        [ option (breakOptAttrs "true" True) [ text "ursprünglich" ]
                        , option (breakOptAttrs "false" False) [ text "automatisch" ]
                        ]
                    ]
                , label []
                    [ text "Alphabet"
                    , Html.input [ class "elam", value model.alphabet, onInput SetAlphabet ] []
                    ]
                ]

        fragmentView fragment =
            -- Insert a zero-width space after the "" separator so that long
            -- lines can be broken by the browser
            let zeroWidthSpace = "​"
                breakAfterSeparator = Regex.replace Regex.All (Regex.regex "") (\_ -> "" ++ zeroWidthSpace)
                textMod = breakAfterSeparator >> guessmarkDir fragment.dir
                fragmentLine nr line = li [ class "line", dirAttr fragment.dir ] [ span [ class "elam" ] [ text (textMod line) ] ]
            in div [ classList [ ("plate", True), ("fixedBreak", model.fixedBreak) ], dirAttr fragment.dir ]
                [ h3 [] [ text fragment.id ]
                , ol [ class "fragment", dirAttr fragment.dir ] (List.indexedMap fragmentLine fragment.lines)
                ]
    in
        div []
            ([ style
            , h1 [] [ text "Elamische Zeichensammlung" ]
            ] ++ alphabet
              ++ playground
              ++ settings ++
            [ h2 [] [ text "Textfragmente" ]
            ] ++ [ div [ dirAttr LTR ] (List.map fragmentView fragments) ])














style = Html.node "style" [type' "text/css"]
    [ Html.text "

body {
    padding: 1em;
}

@font-face {
    font-family: 'elamicon';
    src: url('elamicon.ttf');
}
.elam {
    font-family: elamicon;
    unicode-bidi: bidi-override;
}

.alphabet {
    padding: 0;
    list-style-type: none;
}

.alphabet li {
    margin: 0.1em;
    display: inline-block;
    background-color: #ddd;
}

.alphabet div {
    padding: 0.3em;

    color: rgba(100, 100, 100, 0.8);
    text-shadow: #ddd 0.03ex 0.03ex 0.05ex, #000 0 0 0;
}

.letter {
    text-align: center;
    height: 10em;
    vertical-align: top;
    position: relative;
}

.letter .counter {
    position: absolute;
    top: 0;
    right: 0;
    font-size: small;
    font-weight: bold;
}

.letter .main {
    font-size: 300%;
    cursor: pointer;
}


.letter .ext {
    font-size: 80%;
    display: inline;
}

.letter .menu {
    float: left;
    cursor: pointer;
    background-color: #ddd;
}

.letter .menu .ext {
    float: left;
}

.letter .menu {
    display: none;
}

.letter:hover .menu {
    display: block;
    position: absolute;

    font-size: 200%;
}


input {
    width: 80em;
}


.plate {
    vertical-align: top;
    margin: 0 2em;
    display: inline-block;
}

.fragment {
    font-size: 200%;
    margin-top: 0;

    /* horizontal rules between the lines */
    line-height: 1em;
    background: -moz-linear-gradient(top, #000 0%, #000 5%, #fff 5%) 0 0;
    background: linear-gradient(top, #000 0%, #000 6%, #fff 6%) 0 0;
    background-size: 100% 1.055em;
    padding: 0.07em 0; /* top and bottom offset to align the rule */
}

.fragment[dir=RTL] {
    text-align: right;
}

.fixedBreak {
    /* custom line counter */
    position: relative;
    list-style: none;
    counter-reset: lines;
}

.fixedBreak[dir=LTR] {
    /* custom line counter */
    margin-left: 3em;
}

.fixedBreak[dir=RTL] {
    /* custom line counter */
    margin-right: 3em;
}



.line {
    unicode-bidi: bidi-override; /* not inherited through display: block */
    line-height: 1em;
    counter-increment: lines;
    display: inline-block;
}

.fixedBreak .line {
    display: block;
}

/* custom line counter */
.fixedBreak .line:before {
    content: counter(lines, upper-roman);
    position: absolute;
    font-size: 50%;
}

.fixedBreak .fragment[dir=LTR] .line:before {
    text-align: right;
    left: -2em;
}

.fixedBreak .fragment[dir=RTL] .line:before {
    text-align: left;
    right: -2em;
}


h2 {
    clear: both;
}


textarea {
    width: 100%;
    height: 5em;
    font-size: 200%;
}

label {
    display: block;
}

.clear {
    clear: both;
}

    "]