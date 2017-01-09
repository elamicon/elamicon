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
import Grams

main = Html.program 
    { init = (initialModel, Cmd.none)
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

type alias Pos = (String, Int, Int)
type alias Model =
    { dir : Dir
    , fixedBreak: Bool
    , selected : Maybe Pos
    , syllabary : String
    , syllableMap : String
    , syllabizer : String -> String
    , syllabize: Bool
    , normalizer: String -> String
    , normalize : Bool
    , sandbox: String
    , search: String
    , reverseSearch: Bool
    , selectedGroups: Set.Set String
    }

initialModel =
    { dir = Original
    , fixedBreak = True
    , selected = Nothing
    , normalizer = Elam.normalizer (Elam.normalization Elam.syllabaryPreset)
    , normalize = False
    , syllabary = Elam.syllabaryPreset
    , syllableMap = Elam.syllableMap
    , syllabizer = Elam.syllabizer Elam.syllableMap
    , syllabize = False
    , sandbox = ""
    , search = ""
    , reverseSearch = True
    , selectedGroups = Set.fromList (List.map .short Elam.groups)
    }

type Msg
    = Select (String, Int, Int)
    | SetBreaking Bool
    | SetDir Dir
    | SetNormalize Bool
    | SetSandbox String
    | SetSyllabary String
    | SetSyllableMap String
    | SetSyllabize Bool
    | AddChar String
    | SetSearch String
    | ReverseSearch Bool
    | SelectGroup String Bool


update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    (case msg of
        SetSandbox str -> { model | sandbox = str }
        AddChar char -> { model | sandbox = model.sandbox ++ char }
        Select pos -> { model | selected = Just pos }
        SetBreaking breaking -> { model | fixedBreak = breaking }
        SetNormalize normalize -> { model | normalize = normalize }
        SetDir dir -> { model | dir = dir }
        SetSyllabary new ->
            let newSyllabary = Elam.completeSyllabary new
            in { model | syllabary = newSyllabary, normalizer = Elam.normalizer (Elam.normalization newSyllabary) }
        SetSyllableMap new ->
            { model | syllableMap = new, syllabizer = Elam.syllabizer new }
        SetSyllabize syllabize -> { model | syllabize = syllabize }
        SetSearch new ->
            { model | search = new }
        ReverseSearch new ->
            { model | reverseSearch = new }
        SelectGroup group include ->
            { model | selectedGroups = (if include then Set.insert else Set.remove) group model.selectedGroups
            }
    , Cmd.none
    )

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
        lineDirAttr nr original =
            Html.Attributes.dir (dirStr (
                case effectiveDir original of
                    BoustroR -> if nr % 2 == 0 then RTL else LTR
                    _ ->  effectiveDir original
            ))
        dirAttr original = lineDirAttr 0 original

        -- There are two "guess" marker characters that are used depending on direction
        guessmarkDir dir = Regex.replace Regex.All (Regex.regex "[]") (\_ -> if dir == LTR then "" else "")
        selectedFragments = List.filter (\f -> Set.member f.group model.selectedGroups) Elam.fragments

        syllabary =
            [ h2 [] [ text " Die Buchstaben " ]
            , ol [ dirAttr LTR, classList [ ("syllabary", True) ] ]
                ( List.map syllabaryEntry (Elam.syllabaryList model.syllabary)
                ++ List.map specialEntry Elam.specialChars
                )
            ]

        syllabaryEntry (main, ext) =
            let
                shownExt = if model.normalize then [] else ext
                syls = Maybe.withDefault [] (Dict.get main Elam.syllables)
                letterEntry entryClass char = div [ classList [("elam", True), (entryClass, True)], onClick (AddChar (String.fromChar char)) ] [ text (String.fromChar char) ]
                syllableEntry syl = div [ class "syl" ] [ text syl ]
            in
                li [ class "letter" ]
                    (  [ letterEntry "main" main ]
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

        gramStats strings =
            let
                cleanse = model.normalizer >> String.filter Elam.indexed
                tallyGrams = List.filter (List.isEmpty >> not) <| List.map Grams.tally <| Grams.read 7 <| List.map cleanse strings
                boringClass count = if count < 2 then [ class "boring" ] else []
                tallyEntry gram ts =
                    let
                        boringClass = if gram.count < 2 then [ class "boring" ] else []
                    in
                        tr boringClass
                            -- Use a span so that when the text is copied it
                            -- doesn't cause a new line like a div would.
                            [ td [ class "count" ] [ text <| toString gram.count ]
                            , td [] [ text gram.seq ]
                            ] :: ts
                ntally n tallyGram =
                    li [] [ table [ class "tallyGram" ] (List.foldr tallyEntry [] tallyGram) ]
            in 
                if List.isEmpty tallyGrams
                then div [] []
                else div [] 
                    [ h3 [] [ text "Statistik der Buchstabenfolgen" ]
                    , ul [ class "tallyGrams" ] (List.indexedMap ntally tallyGrams)
                    ]

        playground =
            [ h2 [] [ text " Spielplatz " ]
            , textarea
                [ class "elam"
                , dirAttr LTR
                , on "input" (Json.Decode.map SetSandbox Html.Events.targetValue)
                , onInput SetSandbox
                , value ((guessmarkDir LTR) model.sandbox)
                ] []
            , gramStats [model.sandbox]
            ]


        settings =
            let dirOptAttrs val dir = [ value val, selected (dir == model.dir) ]
                breakOptAttrs val break = [ value val, selected (break == model.fixedBreak) ]
                boolOptAttrs val sel = [ value val, selected sel ]
                groupSelectionEntry group = div [] [ label [] (
                    [ input [ type' "checkbox", checked (Set.member group.short model.selectedGroups), Html.Events.onCheck (SelectGroup group.short) ] []
                    , text group.name
                    ] ++ if group.recorded then [] else
                        [ span [ class "recordWarn", title "Undokumentierte Funde" ] [ text "⚠" ] ]) ]
                        
                groupSelection = List.map groupSelectionEntry Elam.groups
            in  [ h2 [] [ text " Einstellungen " ]
                , div [] [ label []
                    [ text "Schreibrichtung "
                    , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                        [ option (dirOptAttrs "Original" Original) [ text "ursprünglich ⇔" ]
                        , option (dirOptAttrs "LTR" LTR) [ text "alles ⇒ von links ⇒ nach rechts" ]
                        , option (dirOptAttrs "RTL" RTL) [ text "alles ⇐ nach links ⇐ von rechts" ]
                        ]
                    ] ]
                , div [] [ label []
                    [ text "Zeilenumbrüche "
                    , Html.select [ on "change" (Json.Decode.map SetBreaking boolDecoder) ]
                        [ option (breakOptAttrs "true" True) [ text "ursprünglich" ]
                        , option (breakOptAttrs "false" False) [ text "entfernen" ]
                        ]
                    ] ]
                , div [] [ label []
                    [ text "Alternative Zeichen "
                    , Html.select [ on "change" (Json.Decode.map SetNormalize boolDecoder) ]
                        [ option (boolOptAttrs "false" (not model.normalize)) [ text "belassen wie im Original" ]
                        , option (boolOptAttrs "true" model.normalize) [ text "normalisieren nach Syllabar" ]
                        ]
                    ] ]
                , div [] [ label []
                    [ text "Silben mit angenommenem Lautwert "
                    , Html.select [ on "change" (Json.Decode.map SetSyllabize boolDecoder) ]
                        [ option (boolOptAttrs "false" (not model.syllabize)) [ text "belassen wie im Original" ]
                        , option (boolOptAttrs "true" model.syllabize) [ text "ersetzen durch Silbenlautwert" ]
                        ]
                    ] ]
                , div [] [ label []
                    [ h4 [] [ text "Syllabar" ]
                    , Html.textarea [ class "elam", value model.syllabary, onInput SetSyllabary ] []
                    ] ]
                , div [] [ label []
                    [ h4 [] [ text "Angenommene Silbenlautwerte" ]
                    , Html.textarea [ class "elam", value model.syllableMap, onInput SetSyllableMap ] []
                    ] ]
                , div [ class "groups" ]
                    ( h4 [] [ text "Gruppen" ] :: groupSelection )
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

        zeroWidthSpace = "​"

        searchPattern =
            let
                -- When copying strings from the fragments into the search field, irrelevant whitespace
                -- and markers might get copied as well, we remove those from the search pattern.
                cleaned = Regex.replace Regex.All (Regex.regex ("[\\s"++zeroWidthSpace++"]")) (\_ -> "") (String.trim model.search)

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
                        addMatch (index, length) results =
                            let
                                guessmarkLTR = guessmarkDir LTR
                                slotIndex = index + 1
                                lastSlotIndex = index + length
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
                                
                                -- Finding the line nr of the match is somewhat involved because the
                                -- linebreaks are buried in the slots
                                posString atSlot =
                                    let
                                        countLines slotStr (lc, cc) =
                                            if Debug.log (toString slotStr) <| String.contains "\n" slotStr
                                            then Debug.log "lc" (lc+1, 1)
                                            else Debug.log "cc" (lc, cc+1)
                                        (lineNr, charNr) = List.foldl countLines (1, 1) <| List.take atSlot letterSlots
                                    in
                                        String.concat [ toString lineNr, ".", toString charNr ]
    
                                unique = Set.toList << Set.fromList
                                matchTitle = title <| String.join "–" <| posString slotIndex :: if length > 1 then [ posString lastSlotIndex ] else []
                                ref = href <| String.concat [ "#", fragment.id, toString index ]

                                afterText = String.concat (matchAppended :: List.take contextLen (List.drop (lastSlotIndex + 1) letterSlots))
                                item = li [ class "result" ]
                                    [ div [ class "id" ]
                                        [ Html.sup [ class "group" ] [ text fragment.group ]
                                        , text fragment.id
                                        ]
                                    , div [ class "match"]
                                        [ span [ class "before" ] [ text (guessmarkLTR beforeText) ]
                                        , a [ class "highlight", matchTitle, ref ] [ text (guessmarkLTR matchText) ]
                                        , span [ class "after" ] [ text (guessmarkLTR afterText) ]
                                        ]
                                    ]
                            in
                                { items = item :: results.items, raw = matchText :: results.raw }
                    in
                        List.foldr addMatch results matches
                searching = case searchPattern of
                                Pattern pat -> True
                                _ -> False
                results = List.foldr addMatches {items=[], raw=[]} selectedFragments
                stats = gramStats (if searching then results.raw else List.map .text selectedFragments)

            in
                [ h2 [] [ text " Frequenzanalyse " ]
                , stats
                , h2 [] [ text " Suche " ]
                , label []
                    [ text "Suchmuster "
                    , div [ class "searchInput"]
                        ([ Html.input [ class "elam", dirAttr LTR, value model.search, onInput SetSearch ] []
                        ] ++ if searchPattern == Invalid
                            then [ div [ class "invalidPattern" ] [ text "Ungültiges Suchmuster" ] ]
                            else []
                        )
                    , label []
                        [ input [ type' "checkbox", checked model.reverseSearch, Html.Events.onCheck ReverseSearch ] []
                        , text "auch in Gegenrichtung suchen"
                        ]
                    ]
                ]
                ++ case searchPattern of
                    Pattern pat -> if List.length results.items == 0
                                    then [ div [class "noresult" ] [ text "Nichts gefunden" ] ]
                                    else [ ol [ class "result" ] results.items ]
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
                normalize =
                    if model.normalize
                    then model.normalizer
                    else identity

                syllabize =
                    if model.syllabize
                    then model.syllabizer 
                    else identity

                -- Insert a zero-width space after the "" separator so that long
                -- lines can be broken by the browser
                breakAfterSeparator = Regex.replace Regex.All (Regex.regex "[]") (\l -> l.match ++ zeroWidthSpace)
                textMod = String.trim >> normalize >> breakAfterSeparator >> guessmarkDir (effectiveDir fragment.dir)

                -- Find matches in the fragment
                matches = searchMatches fragment.text


                        
                guessmarkClass char = 
                    if Set.member char (Set.fromList ['', ''])
                    then [ class "guessmark" ]
                    else []
                    
                -- Fold helper building a list element from a text line
                -- The tricky bit here is to keep indexed character position so
                -- we can track highlighted searches which may span across
                -- lines.
                line chars (lines, lineIdx) =
                    let
                        lineNr = List.length lines
                        charPos char (elems, idx) =
                            let
                                within (index, length) = (idx >= index) && (idx < index + length)
                                highlightClass =
                                      if List.any within matches
                                      then [ class "highlight" ]
                                      else []
                                titleAttr =
                                    [ title (String.concat [toString (lineNr+1), ".", toString (idx-lineIdx+1)]) ] 
                                idAttr =
                                    [ id <| String.concat [ fragment.id, toString idx ] ]
                            in
                                if
                                    Elam.indexed char
                                then
                                    ((a (highlightClass ++ titleAttr ++ idAttr) [ text (syllabize <| String.fromChar char) ]) :: elems, idx+1)
                                else
                                    ((span (guessmarkClass char) [ text (String.fromChar char) ]) :: elems, idx)
                        (elems, endIdx) = String.foldl charPos ([], lineIdx) chars
                        elemLine = li [ class "line", lineDirAttr lineNr fragment.dir ] (List.reverse elems)
                    in
                        (elemLine :: lines, endIdx)

                -- Build line entries from text
                lines = List.reverse (fst (List.foldl line ([], 0) (String.lines (textMod fragment.text))))
            in
                div [ classList [ ("plate", True), ("fixedBreak", model.fixedBreak), ("elam", True) ], dirAttr fragment.dir ]
                [ h3 [] [ sup [ class "group" ] [ text fragment.group ], span [ dir "LTR" ] [ text fragment.id ] ]
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
            ] ++ [ div [ dirAttr LTR ] (List.map fragmentView selectedFragments) ]
              ++ [ footer ]
        )

