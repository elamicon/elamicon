import Html exposing (..)
import Html.App as Html
import Html.Events exposing (on, onClick, onInput, targetValue)
import Html.Attributes exposing (..)
import Dict
import String
import Regex
import RegexMaybe
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
letters = String.toList (String.trim "

")
elamLetters = Set.fromList letters

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedLetters = Set.fromList ([ '', 'X' ] ++ letters)


-- The syllable mapping is short as of now and will likely never become
-- comprehensive. All of this is guesswork.
syllables : Dict.Dict Char (List String)
syllables = Dict.fromList
    [ ( '', [ "na" ] )
    , ( '', [ "uk ?" ] )
    , ( '', [ "NAP"] )
    , ( '', [ "NAP"] )
    , ( '', [ "en ?", "im ?"] )
    , ( '', [ "šu" ] )
    , ( '', [ "ša ?" ] )
    , ( '', [ "in" ] )
    , ( '', [ "ki" ] )
    , ( '', [ "iš ?", "uš ?" ] )
    , ( '', [ "tu ?" ] )
    , ( '', [ "hu ?"] )
    , ( '', [ "me ?" ] )
    , ( '', [ "me ?" ] )
    , ( '', [ "ši" ] )
    , ( '', [ "še ?", "si ?" ] )
    , ( '', [ "ak", "ik"] )
    , ( '', [ "hal ?" ] )
    , ( '', [ "ú" ] )
    , ( '', [ "ni ?" ] )
    , ( '', [ "piš ?" ] )
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


-- Alphabet definition
--
-- The many letter variants are grouped into an alphabet with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the alphabet a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letter are separated by spaces, letters following another letter without
-- a space are grouped with that letter
alphabetPreset = "
                                                                                                                       
"

alphabetList : String -> List (Char, List Char)
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
        dedup letter (seen, dedupAlphabet) =
            if Set.member letter seen
            then
                (seen, dedupAlphabet)
            else
                if Set.member letter indexedLetters
                then
                    (Set.insert letter seen, dedupAlphabet ++ String.fromChar letter)
                else
                    (seen, dedupAlphabet ++ String.fromChar letter)

        (presentLetters, dedupedAlphabet) = List.foldl dedup (Set.empty, "") (String.toList alphabet)
        missingLetters = Set.diff elamLetters presentLetters
    in
        dedupedAlphabet
        ++ " "
        ++ String.join " " (map String.fromChar (Set.toList missingLetters))


-- When searching the corpus (and optionally when displaying it) we want to treat all
-- characters in an letter group as the same character. This function builds a
-- dictionary that maps all alternate versions of a letter to the main letter.
normalization : String -> Dict.Dict Char Char
normalization alphabet =
    let allLetters = Set.fromList letters
        ins group dict =
            case (String.toList group) of
                main :: extras -> List.foldl (insLetter main) (Dict.insert main main dict) extras
                _ -> dict
        insLetter main ext dict = Dict.insert ext main dict
    in List.foldl ins Dict.empty (String.words alphabet)


normalizer: Dict.Dict Char Char -> String -> String
normalizer normalization =
    let
        repl: Char -> Char
        repl letter = Maybe.withDefault letter (Dict.get letter normalization)
    in String.map repl


-- Linear Elam texts are written left-to-right (LTR) and right-to-left (RTL).
-- The majority is written RTL. We display them in their original direction, but
-- allow coercing the direction to one of the two for all panels.
type Dir = Original | LTR | RTL


fragments =
    [ { id = "A", dir = RTL, text =
        """
            
            
            
            
            
        """
      }
    , { id = "B", dir = LTR, text =
        """
            
            
            
        """
      }
    , { id = "C", dir = RTL, text =
        """
            
            
            
            
        """
      }
    , { id = "E", dir = LTR, text =
        """
            
            
            
            
        """
      }
    , { id = "O", dir = RTL, text =
        """
            XX
            XX
            X
            XXXX
            XXX
            X
            XX
            XX
        """
      }
    , { id = "Q", dir = LTR, text =
        """
            
        """
      }
    , { id = "neuA", dir = RTL, text =
        """
            XXX​
            ​​
            ​​
            X​​k 
            X ​
            ​ 
            X 
            X​XXXXY
            X
        """
      }
     , { id = "neuB", dir = RTL, text =
        """
            kkk
            
            X
        """
      }   , { id = "neuC", dir = RTL, text =
        """
            XXX
                    X
                       
        """
      }
    , { id = "neuD", dir = RTL, text =
        """
            XX
            XXX
            
            XX
            X
        """
      }
    , { id = "neuE", dir = RTL, text =
        """
            
            X
            
            
            X
            X
            
            X
        """
      }
    , { id = "neuF", dir = RTL, text =
        """
            Y
            Y
            XXY
            XY
        """
      }
    , { id = "neuG", dir = RTL, text =
        """
            Y
            YY
        """
      }
    , { id = "neuH", dir = RTL, text =
        """
            YXY
            YY
        """
      }
    , { id = "neuI.a", dir = RTL, text =
        """
            Y
            Y
            XXY
            XY
        """
      }
    , { id = "neuI.a", dir = RTL, text =
        """
            Y
            Y
        """
      }
    , { id = "neuI.b", dir = RTL, text =
        """
            
            YXY
            YY
        """
      }
    , { id = "neuI.c", dir = RTL, text =
        """
            YY
            YY
        """
      }
    , { id = "neuI.d", dir = RTL, text =
        """
            Y
            YY
        """
      }
    , { id = "neuJ.a", dir = RTL, text =
        """
            YY
        """
      }
    , { id = "neuJ.b", dir = RTL, text =
        """
            YY
        """
      }
    , { id = "neuJ.c", dir = RTL, text =
        """
            YY
            YY
        """
      }
    , { id = "neuJ.d", dir = RTL, text =
        """
            YY
            YY
        """
      }
    , { id = "neuK.a", dir = LTR, text =
        """
            YY
        """
      }
    , { id = "neuK.b", dir = LTR, text =
        """
            YY
            YX​XY
            Y
        """
      }
    , { id = "neuK.c", dir = LTR, text =
        """
            YX
            YX
            

        """
      }
    ]




main = Html.beginnerProgram { model = model, view = view, update = update }

type alias Pos = (String, Int, Int)
type alias Model =
    { dir : Dir
    , fixedBreak: Bool
    , selected : Maybe Pos
    , alphabet : String
    , normalizer: String -> String
    , sandbox: String
    , lumping : Bool
    , search: String
    }

model =
    { dir = Original
    , fixedBreak = True
    , selected = Nothing
    , alphabet = alphabetPreset
    , normalizer = normalizer (normalization alphabetPreset)
    , sandbox = ""
    , lumping = False
    , search = ""
    }

type Msg
    = Select (String, Int, Int)
    | SetBreaking Bool
    | SetDir Dir
    | SetLumping Bool
    | SetSandbox String
    | SetAlphabet String
    | AddChar String
    | SetSearch String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetSandbox str -> { model | sandbox = str }
        AddChar char -> { model | sandbox = model.sandbox ++ char }
        Select pos -> { model | selected = Just pos }
        SetBreaking breaking -> { model | fixedBreak = breaking }
        SetLumping lumping -> { model | lumping = lumping }
        SetDir dir -> { model | dir = dir }
        SetAlphabet new ->
            let newAlphabet = completeAlphabet new
            in { model | alphabet = newAlphabet, normalizer = normalizer (normalization newAlphabet) }
        SetSearch new ->
            { model | search = new }

dirStr dir = case dir of
    LTR -> "LTR"
    _ -> "RTL"

dirDecoder : Json.Decode.Decoder Dir
dirDecoder = Html.Events.targetValue `Json.Decode.andThen` (\valStr -> case valStr of
    "Original" -> Json.Decode.succeed Original
    "LTR" -> Json.Decode.succeed LTR
    "RTL" -> Json.Decode.succeed RTL
    _ -> Json.Decode.fail ("dir " ++ valStr ++ "unknown"))

boolDecoder : Json.Decode.Decoder Bool
boolDecoder = Html.Events.targetValue `Json.Decode.andThen` (\valStr -> case valStr of
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
            [ h2 [] [ text " Die Buchstaben " ]
            , ol [ dirAttr LTR, classList [ ("alphabet", True) ] ]
                ( List.map alphabetEntry (alphabetList model.alphabet)
                ++ List.map specialEntry specialChars
                )
            ]

        alphabetEntry (main, ext) =
            let
                shownExt = if model.lumping then [] else ext
                syls = Maybe.withDefault [] (Dict.get main syllables)
                letterEntry entryClass char = div [ classList [("elam", True), (entryClass, True)], onClick (AddChar (String.fromChar char)) ] [ text (String.fromChar char) ]
                syllableEntry syl = div [ class "syl" ] [ text syl ]
                letterCount = letterCounter (main :: ext) model.sandbox
            in
                li [ class "letter" ]
                    ( (if letterCount > 0 then [ div [ class "counter" ] [ text (toString letterCount) ] ] else [] )
                    ++ [ letterEntry "main" main ]
                    ++ ( if shownExt /= [] || List.length syls > 0
                         then [ div [class "menu"] (map (letterEntry "ext") shownExt ++ map syllableEntry syls) ]
                         else []
                       )
                    ++ (map (letterEntry "ext") shownExt)
                    ++ [ div [ class "clear" ] [] ]
                    )

        specialEntry { displayChar, char, description } =
            li [ class "letter" ]
                [ div [ classList [("elam", True), ("main", True)], onClick (AddChar (String.fromChar char)), title description ] [ text ((guessmarkDir LTR) displayChar) ] ]


        playground =
            [ h2 [] [ text " Spielplatz " ]
            , textarea
                [ class "elam"
                , dirAttr LTR
                , on "input" (Json.Decode.map SetSandbox Html.Events.targetValue)
                , onInput SetSandbox
                , value ((guessmarkDir LTR) model.sandbox)
                ] []
            ]


        settings =
            let dirOptAttrs val dir = [ value val, selected (dir == model.dir) ]
                breakOptAttrs val break = [ value val, selected (break == model.fixedBreak) ]
                lumpingOptAttrs val lumping = [ value val, selected (lumping == model.lumping) ]
            in  [ h2 [] [ text " Einstellungen " ]
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
                    , Html.select [ on "change" (Json.Decode.map SetBreaking boolDecoder) ]
                        [ option (breakOptAttrs "true" True) [ text "ursprünglich" ]
                        , option (breakOptAttrs "false" False) [ text "automatisch" ]
                        ]
                    ]
                , label []
                    [ text "Alphabet"
                    , Html.input [ class "elam", value model.alphabet, onInput SetAlphabet ] []
                    ]
                , label []
                    [ text "Zeichen vereinheitlichen"
                    , Html.select [ on "change" (Json.Decode.map SetLumping boolDecoder) ]
                        [ option (lumpingOptAttrs "false" False) [ text "ursprünglich" ]
                        , option (lumpingOptAttrs "true" True) [ text "nach Gruppen" ]
                        ]
                    ]
                , label []
                    [ text "Suche"
                    , Html.input [ class "elam", dirAttr LTR, value model.search, onInput SetSearch ] []
                    ]
                ]


        zeroWidthSpace = "​"
        searchRegex =
            let
                -- When copying strings from the fragments into the search field, irrelevant whitespace might
                -- get copied as well, we remove that from the search pattern
                cleaned = Regex.replace Regex.All (Regex.regex ("\\s|"++zeroWidthSpace)) (\_ -> "") (String.trim model.search)

                -- We want the regex to match all letters of a group, so both the pattern and the fragments
                -- are normalized before matching
                normalized = model.normalizer cleaned
            in
                if String.length normalized == 0
                then Nothing
                else RegexMaybe.regex normalized


        fragmentView fragment =
            let
                -- Normalize letters if this is enabled
                lumping text =
                    if model.lumping
                    then model.normalizer text
                    else text

                -- Insert a zero-width space after the "" separator so that long
                -- lines can be broken by the browser
                breakAfterSeparator = Regex.replace Regex.All (Regex.regex "[]") (\_ -> "" ++ zeroWidthSpace)
                textMod = String.trim >> lumping >> breakAfterSeparator >> guessmarkDir fragment.dir

                -- Find matches in the fragment
                onlyLetters = String.filter (\lt -> Set.member lt indexedLetters)
                matches =
                    case searchRegex of
                        Just regex -> Regex.find Regex.All regex (model.normalizer (onlyLetters fragment.text))
                        Nothing -> []

                highlight idx =
                    let
                        within match = idx >= match.index && idx < match.index + String.length match.match
                    in
                        List.any within matches

                charPos char (elems, idx) =
                    if
                        Set.member char indexedLetters
                    then
                        ((span (if highlight idx then [ class "highlight" ] else []) [ text (String.fromChar char) ]) :: elems, idx+1)
                    else
                        ((text (String.fromChar char)) :: elems, idx)

                line text (lines, idx) =
                    let
                        (elems, endIdx) = String.foldl charPos ([], idx) text
                        elemLine = li [ class "line", dirAttr fragment.dir ] (List.reverse elems)
                    in
                        (elemLine :: lines, endIdx)
                lines = List.reverse (fst (List.foldl line ([], 0) (String.lines (textMod fragment.text))))
            in
                div [ classList [ ("plate", True), ("fixedBreak", model.fixedBreak), ("elam", True) ], dirAttr fragment.dir ]
                [ h3 [] [ text fragment.id ]
                , ol [ class "fragment", dirAttr fragment.dir ] lines
                ]

        footer = div [ class "footer" ]
                [ text "Diese Seite wurde produziert mit "
                , a [ href "https://fontforge.github.io/en-US/" ]
                    [ text "FontForge" ]
                , text ", "
                , a [ href "http://elm-lang.org/" ]
                    [ text "Elm" ]
                , text " und ♥.  "
                , a [ href "fonts/Elamicon-Fonts.zip" ]
                    [ text "Elamicon-Schriften installieren."]
                , text " "
                , a [ href "https://github.com/sbalmer/elamicon/" ]
                    [ text "Das Projekt auf Github." ]
                ]
    in
        div [] (
            [ Html.node "style" [type' "text/css"] [ text "@import 'css/main.css'" ]
            , h1 [] [ text " Elamische Zeichensammlung " ]
            ] ++ alphabet
              ++ playground
              ++ settings ++
            [ h2 [] [ text " Textfragmente " ]
            ] ++ [ div [ dirAttr LTR ] (List.map fragmentView fragments) ]
              ++ [ footer ]
        )

