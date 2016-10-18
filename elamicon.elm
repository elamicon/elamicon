import Html exposing (..)
import Html.App as Html
import Html.Events exposing (on, onClick, onInput, targetValue)
import Html.Attributes exposing (..)
import Dict
import String
import Regex
import RegexMaybe
import Json.Decode
import List
import Set
import Elam exposing (Dir(..))

main = Html.beginnerProgram { model = model, view = view, update = update }

type alias Pos = (String, Int, Int)
type alias Model =
    { dir : Dir
    , fixedBreak: Bool
    , selected : Maybe Pos
    , syllabary : String
    , normalizer: String -> String
    , sandbox: String
    , lumping : Bool
    , search: String
    , reverseSearch: Bool
    }

model =
    { dir = Original
    , fixedBreak = True
    , selected = Nothing
    , syllabary = Elam.syllabaryPreset
    , normalizer = Elam.normalizer (Elam.normalization Elam.syllabaryPreset)
    , sandbox = ""
    , lumping = False
    , search = ""
    , reverseSearch = True
    }

type Msg
    = Select (String, Int, Int)
    | SetBreaking Bool
    | SetDir Dir
    | SetLumping Bool
    | SetSandbox String
    | SetSyllabary String
    | AddChar String
    | SetSearch String
    | ReverseSearch Bool


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetSandbox str -> { model | sandbox = str }
        AddChar char -> { model | sandbox = model.sandbox ++ char }
        Select pos -> { model | selected = Just pos }
        SetBreaking breaking -> { model | fixedBreak = breaking }
        SetLumping lumping -> { model | lumping = lumping }
        SetDir dir -> { model | dir = dir }
        SetSyllabary new ->
            let newSyllabary = Elam.completeSyllabary new
            in { model | syllabary = newSyllabary, normalizer = Elam.normalizer (Elam.normalization newSyllabary) }
        SetSearch new ->
            { model | search = new }
        ReverseSearch new ->
            { model | reverseSearch = new }

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

type SearchPattern = None
    | Invalid
    | Pattern Regex.Regex

view : Model -> Html Msg
view model =
    let effectiveDir original = if model.dir == Original then original else model.dir
        dirAttr original = dir (dirStr (effectiveDir original))

        -- There are two "guess" marker characters that are used depending on direction
        guessmarkDir original = Regex.replace Regex.All (Regex.regex "[]") (\_ -> if effectiveDir original == LTR then "" else "")

        letterCounter letters = String.toList >> List.filter (\candidate -> Set.member candidate (Set.fromList letters)) >> List.length

        syllabary =
            [ h2 [] [ text " Die Buchstaben " ]
            , ol [ dirAttr LTR, classList [ ("syllabary", True) ] ]
                ( List.map syllabaryEntry (Elam.syllabaryList model.syllabary)
                ++ List.map specialEntry Elam.specialChars
                )
            ]

        syllabaryEntry (main, ext) =
            let
                shownExt = if model.lumping then [] else ext
                syls = Maybe.withDefault [] (Dict.get main Elam.syllables)
                letterEntry entryClass char = div [ classList [("elam", True), (entryClass, True)], onClick (AddChar (String.fromChar char)) ] [ text (String.fromChar char) ]
                syllableEntry syl = div [ class "syl" ] [ text syl ]
                letterCount = letterCounter (main :: ext) model.sandbox
            in
                li [ class "letter" ]
                    ( (if letterCount > 0 then [ div [ class "counter" ] [ text (toString letterCount) ] ] else [] )
                    ++ [ letterEntry "main" main ]
                    ++ ( if shownExt /= [] || List.length syls > 0
                         then [ div [class "menu"] (List.map (letterEntry "ext") shownExt ++ List.map syllableEntry syls) ]
                         else []
                       )
                    ++ (List.map (letterEntry "ext") shownExt)
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
                    [ text "Schreibrichtung "
                    , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                        [ option (dirOptAttrs "Original" Original) [ text "ursprünglich ⇔" ]
                        , option (dirOptAttrs "LTR" LTR) [ text "alles ⇒ von links ⇒ nach rechts" ]
                        , option (dirOptAttrs "RTL" RTL) [ text "alles ⇐ nach links ⇐ von rechts" ]
                        ]
                    ]
                , label []
                    [ text "Zeilenumbrüche "
                    , Html.select [ on "change" (Json.Decode.map SetBreaking boolDecoder) ]
                        [ option (breakOptAttrs "true" True) [ text "ursprünglich" ]
                        , option (breakOptAttrs "false" False) [ text "entfernen" ]
                        ]
                    ]
                , label []
                    [ text "Syllabar"
                    , Html.input [ class "elam", type' "text", value model.syllabary, onInput SetSyllabary ] []
                    ]
                , label []
                    [ text "Alternative Zeichen "
                    , Html.select [ on "change" (Json.Decode.map SetLumping boolDecoder) ]
                        [ option (lumpingOptAttrs "false" False) [ text "belassen" ]
                        , option (lumpingOptAttrs "true" True) [ text "vereinheitlichen nach Gruppen" ]
                        ]
                    ]
                ]

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

        searchPattern =
            let
                -- When copying strings from the fragments into the search field, irrelevant whitespace might
                -- get copied as well, we remove that from the search pattern
                cleaned = Regex.replace Regex.All (Regex.regex ("\\s|"++zeroWidthSpace)) (\_ -> "") (String.trim model.search)

                -- We want the regex to match all letters of a group, so both the pattern and the fragments
                -- are normalized before matching
                normalized = model.normalizer cleaned
            in
                if
                    String.length normalized == 0
                then
                    None
                else
                    case RegexMaybe.regex normalized of
                        Just pattern -> Pattern pattern
                        Nothing -> Invalid



        zeroWidthSpace = "​"
        searchMatches : String -> List (Int, Int)
        searchMatches text  =
            case searchPattern of
                Pattern pat ->
                    let
                        find = Regex.find Regex.All pat
                        matchText = model.normalizer (String.filter Elam.indexed text)
                        matches = find matchText
                        matchTextLen = String.length matchText
                        revertMatch match =
                            let
                                matchLen = String.length match.match
                            in
                                (matchTextLen - match.index - matchLen, matchLen)

                        reverseMatches =
                            if
                                model.reverseSearch
                            then
                                List.map revertMatch (find (String.reverse matchText))
                            else
                                []

                        allMatches = reverseMatches ++ List.map (\m -> (m.index, String.length m.match)) matches

                    in
                        List.sortBy fst (Set.toList (Set.fromList allMatches))
                _ -> []


        searchView =
            let
                addMatches fragment results =
                    let
                        letterSlots = letterSplit fragment.text
                        matches = searchMatches fragment.text
                        result (index, length) =
                            let
                                slotIndex = index + 1
                                contextLen = 3
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

                                afterText = String.concat (matchAppended :: List.take contextLen (List.drop (slotIndex+length) letterSlots))
                            in
                                li [ class "result" ]
                                    [ div [ class "id" ] [ text fragment.id ]
                                    , div [ class "match"]
                                        [ span [ class "before" ] [ text beforeText ]
                                        , span [ class "highlight" ] [ text matchText ]
                                        , span [ class "after" ] [ text afterText ]
                                        ]
                                    ]
                    in
                        List.map result matches ++ results

                results = List.foldr addMatches [] Elam.fragments

            in
                [ h2 [] [ text " Suche " ]
                , label []
                    [ text "Suchmuster "
                    , div [ class "searchInput"]
                        ([ Html.input [ class "elam", dirAttr LTR, value model.search, onInput SetSearch ] []
                        ] ++ if searchPattern == Invalid
                            then [ div [ class "invalidPattern" ] [ text "Ungültiges Suchmuster" ] ]
                            else []
                        )
                    , label [ class "inline" ]
                        [ input [ type' "checkbox", checked model.reverseSearch, Html.Events.onCheck ReverseSearch ] []
                        , text "auch in Gegenrichtung suchen"
                        ]
                    ]
                ]
                ++ case searchPattern of
                    Pattern pat -> if List.length results == 0
                                    then [ div [class "noresult" ] [ text "Nichts gefunden" ] ]
                                    else [ ol [ class "result" ] results ]
                    _ -> [ div [ class "searchExamples" ]
                        [ h3 [] [ text "Suchbeispiele" ]
                        , dl []
                            [ dt [] [ text "[]?[]" ]
                            , dd [] [ text "Suche nach Varianten von  (in-šu mit optionalem NAP)" ]
                            , dt [] [ text "[][]" ]
                            , dd [] [ text "Suche nach Varianten von  und erlaube auch Platzhalter" ]
                            , dt [] [ text "([^])\\1" ]
                            , dd [] [ text "Suche nach Silbenwiederholungen wie " ]
                            , dt [] [ text "([^]).\\1" ]
                            , dd [] [ text "Silbenwiederholungen mit einem beliebigen Zeichen dazwischen ()" ]
                            , dt [] [ text "[^]+" ]
                            , dd [] [ text "\"Worte\", wenn wir den vertikalen Strich als Worttrenner annehmen" ]
                            , dt [] [ text "[]" ]
                            , dd [] [ text "Alle Stellen anzeigen, wo  oder  steht" ]
                            ]
                        ]
                    ]


        fragmentView fragment =
            let
                -- Normalize letters if this is enabled
                lumping text =
                    if model.lumping
                    then model.normalizer text
                    else text

                -- Insert a zero-width space after the "" separator so that long
                -- lines can be broken by the browser
                breakAfterSeparator = Regex.replace Regex.All (Regex.regex "[]") (\l -> l.match ++ zeroWidthSpace)
                textMod = String.trim >> lumping >> breakAfterSeparator >> guessmarkDir fragment.dir

                -- Find matches in the fragment
                matches = searchMatches fragment.text

                highlight idx =
                    let
                        within (index, length) = (idx >= index) && (idx < index + length)
                    in
                        List.any within matches

                charPos char (elems, idx) =
                    if
                        Elam.indexed char
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
                , a [ href "https://fontforge.github.io/" ]
                    [ text "FontForge" ]
                , text ", "
                , a [ href "http://elm-lang.org/" ]
                    [ text "Elm" ]
                , text " und "
                , a [ href "https://unicode.org" ] [ text "♥" ]
                , text ".  "
                , a [ href "fonts/Elamicon-Fonts.zip" ]
                    [ text "Elamicon-Schriften installieren."]
                , text " "
                , a [ href "https://github.com/elamicon/elamicon/" ]
                    [ text "Das Projekt auf Github." ]
                ]
    in
        div [] (
            [ h1 [] [ text " Elamische Zeichensammlung " ]
            ] ++ syllabary
              ++ playground
              ++ settings
              ++ searchView ++
            [ h2 [] [ text " Textfragmente " ]
            ] ++ [ div [ dirAttr LTR ] (List.map fragmentView Elam.fragments) ]
              ++ [ footer ]
        )

