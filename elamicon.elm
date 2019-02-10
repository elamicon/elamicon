import Html exposing (..)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Html.Attributes exposing (..)
import Dict
import String
import Regex
import RegexMaybe
import Json.Decode
import List
import Array
import Set

import Search
import Grams
import AstralString

import ScriptDefs exposing (..)
import Scripts exposing (..)
import WritingDirections exposing (..)

main = Html.program
    { init = (initialModel, Cmd.none)
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

type alias Pos = (String, Int, Int)
type alias Model =
    { script : Script
    , dir : Maybe Dir
    , fixedBreak: Bool
    , selected : Maybe Pos
    , syllabaryId : Maybe String
    , syllabary : String
    , missingSyllabaryChars: String
    , syllableMap : String
    , syllabizer : String -> String
    , syllabize: Bool
    , normalizer: String -> String
    , normalize : Bool
    , removeChars : String
    , sandbox: String
    , search: String
    , bidirectionalSearch: Bool
    , selectedGroups: Set.Set String
    , collapsed: Set.Set String
    , showAllResults: Bool
    }

initialScript = Scripts.initialScript

initialModel = updateScript initialScript
    { script = initialScript
    , dir = Nothing
    , fixedBreak = True
    , selected = Nothing
    , normalizer = identity
    , normalize = False
    , removeChars = ""
    , syllabaryId = Nothing
    , syllabary = ""
    , missingSyllabaryChars = ""
    , syllableMap = initialScript.syllableMap
    , syllabizer = Scripts.syllabizer initialScript.syllableMap
    , syllabize = False
    , sandbox = ""
    , search = ""
    , showAllResults = False
    , bidirectionalSearch = True
    , selectedGroups = Set.empty
    , collapsed = Set.fromList [ "gramStats", "syllabary", "playground", "settings", "search" ]
    }

type Msg
    = Select (String, Int, Int)
    | SetScript Script
    | SetBreaking Bool
    | SetDir (Maybe Dir)
    | SetNormalize Bool
    | SetSandbox String
    | ChooseSyllabary String
    | SetSyllabary String
    | SetSyllableMap String
    | SetSyllabize Bool
    | SetRemoveChars String
    | AddChar String
    | SetSearch String
    | ShowAllResults
    | BidirectionalSearch Bool
    | SelectGroup String Bool
    | Toggle String

updateScript : Script -> Model -> Model
updateScript new model =
    let
        selectedGroups = Set.fromList (List.map .short new.groups)
    in
        switchSyllabary new.initialSyllabary
            { model
            | script = new
            , selectedGroups = selectedGroups
            , search = ""
            }



setSyllabary : String -> Model -> Model
setSyllabary new model =
    let
        (deduped, missing) = Scripts.dedupe model.script.tokens model.script.indexed new
        newNormalizer = Scripts.normalizer (Scripts.normalization model.script.tokens deduped)
    in  { model
        | syllabary = deduped
        , normalizer = newNormalizer
        , missingSyllabaryChars = missing
        }


switchSyllabary : SyllabaryDef -> Model -> Model
switchSyllabary new model =
    let
        (deduped, missing) = Scripts.dedupe model.script.tokens model.script.indexed new.syllabary
        newNormalizer = Scripts.normalizer (Scripts.normalization model.script.tokens deduped)
        updated = setSyllabary new.syllabary model
    in  { updated
        | syllabaryId = Just new.id
        }


zeroWidthSpace = "​"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (case msg of
        SetScript script -> updateScript script model
        SetSandbox str -> { model | sandbox = str }
        AddChar char ->
            { model
            | sandbox = model.sandbox ++ char
            ,collapsed = Set.remove "playground" model.collapsed
            }
        Select pos -> { model | selected = Just pos }
        SetBreaking breaking -> { model | fixedBreak = breaking }
        SetNormalize normalize -> { model | normalize = normalize }
        SetRemoveChars chars -> { model | removeChars = chars }
        SetDir dir -> { model | dir = dir }
        ChooseSyllabary id ->
            case List.head <| List.filter (.id >> (==) id) model.script.syllabaries of
                Just syl -> switchSyllabary syl model
                Nothing -> model
        SetSyllabary new -> setSyllabary new model
        SetSyllableMap new ->
            { model | syllableMap = new, syllabizer = Scripts.syllabizer new }
        SetSyllabize syllabize -> { model | syllabize = syllabize }

        SetSearch new ->
            let
                -- When copying strings from the fragments into the search field, irrelevant whitespace
                -- and markers might get copied as well, we remove those from the search pattern.
                unwanted = Regex.regex ("[\\s"++zeroWidthSpace++"]")
                cleanSearch =  Regex.replace Regex.All unwanted (\_ -> "") new
            in
                { model | search = cleanSearch, showAllResults = False }

        ShowAllResults -> { model | showAllResults = True }
        BidirectionalSearch new ->
            { model | bidirectionalSearch = new }
        SelectGroup group include ->
            { model | selectedGroups = (if include then Set.insert else Set.remove) group model.selectedGroups
            }
        Toggle section ->
            { model | collapsed =
                (if Set.member section model.collapsed
                then Set.remove else Set.insert)
                    section
                    model.collapsed
            }
    , Cmd.none
    )

dirStr dir = case dir of
    RTL -> "RTL"
    _ -> "LTR"

scriptDecoder : Json.Decode.Decoder Script
scriptDecoder = Html.Events.targetValue |> Json.Decode.andThen (\valStr ->
    case List.head <| List.filter (.id >> (==) valStr) scripts of
    Just script -> Json.Decode.succeed(script)
    Nothing     -> Json.Decode.fail ("script " ++ valStr ++ "unknown"))

dirDecoder : Json.Decode.Decoder (Maybe Dir)
dirDecoder = Html.Events.targetValue |> Json.Decode.andThen (\valStr -> case valStr of
    "Original" -> Json.Decode.succeed Nothing
    "LTR" -> Json.Decode.succeed (Just LTR)
    "RTL" -> Json.Decode.succeed (Just RTL)
    _ -> Json.Decode.fail ("dir " ++ valStr ++ "unknown"))


boolDecoder : Json.Decode.Decoder Bool
boolDecoder = Html.Events.targetValue |> Json.Decode.andThen (\valStr -> case valStr of
    "true" -> Json.Decode.succeed True
    "false" -> Json.Decode.succeed False
    _ -> Json.Decode.fail ("dir " ++ valStr ++ "unknown"))

type SearchPattern = None
    | Invalid
    | Pattern Regex.Regex
    | Fuzzy Int String


-- Thirty-two numerals ought to be enough for everybody (Marcus Licinius Crassus)
romanNumerals = Array.fromList
    [ "", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ"
    , "Ⅹ", "Ⅺ", "Ⅻ", "Ⅻ", "ⅩⅢ", "ⅩⅣ", "ⅩⅤ", "ⅩⅥ", "ⅩⅦ",  "ⅩⅧ", "ⅩⅨ"
    , "ⅩⅩ", "ⅩⅪ", "ⅩⅫ", "ⅩⅫ", "ⅩⅩⅢ", "ⅩⅩⅣ", "ⅩⅩⅤ", "ⅩⅩⅥ", "ⅩⅩⅦ",  "ⅩⅩⅧ", "ⅩⅩⅨ"
    , "ⅩⅩⅩ", "ⅩⅩⅪ", "ⅩⅩⅫ"
    ]
roman num = Maybe.withDefault "" <| Array.get num romanNumerals

view : Model -> Html Msg
view model =
    let effectiveDir original = case model.dir of
            Nothing -> original
            Just dir -> dir
        lineDirAttr nr original =
            Html.Attributes.dir (dirStr (
                case effectiveDir original of
                    BoustroR -> if nr % 2 == 0 then RTL else LTR
                    _ ->  effectiveDir original
            ))
        dirAttr original = lineDirAttr 0 original
        scriptClass = class model.script.id

        -- There are two "guess" marker characters that are used depending on direction
        guessmarkDir dir = Regex.replace Regex.All (Regex.regex "[]") (\_ -> if dir == LTR then "" else "")
        selectedFragments = List.filter (\f -> Set.member f.group model.selectedGroups) model.script.fragments

        -- Normalize letters if this is enabled
        normalize =
            if model.normalize
            then model.normalizer
            else identity

        -- Build filter that removes undesired chars
        removeCharSet = Set.fromList <| AstralString.toList model.removeChars
        keepChar c = Set.member c removeCharSet |> not
        charFilter = AstralString.filter keepChar

        -- Process fragment text for display
        cleanse = String.trim >> normalize >> charFilter
        cleanedFragments = List.map (\f -> { f | text = cleanse f.text }) selectedFragments


        collapsible section =
            [ classList
                [ ("collapsible", True)
                , ("collapsed", Set.member section model.collapsed)
                ]
            , onClick (Toggle section)
            ]

        -- build is called lazily when the section is expanded
        ifExpanded : String -> (() -> List a) -> List a
        ifExpanded section build =
            if Set.member section model.collapsed
            then []
            else build ()

        syllabary =
            [ h2 (collapsible "syllabary") [ text " Die Buchstaben " ]
            ] ++ ifExpanded "syllabary" syllabaryView

        syllabaryView =
            \_ ->
                [ ol [ dirAttr LTR, classList [ ("syllabary", True) ] ]
                    ( List.map syllabaryEntry (Scripts.syllabaryList (charFilter model.syllabary))
                    ++ List.map specialEntry model.script.specialChars
                    )
                ]

        syllabaryEntry (main, ext) =
            let
                shownExt = if model.normalize then [] else ext
                syls = Maybe.withDefault [] (Dict.get main model.script.syllables)
                letterEntry entryClass char = div [ classList [(model.script.id, True), (entryClass, True)], onClick (AddChar char) ] [ text char ]
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
                [ div [ classList [(model.script.id, True), ("main", True)], onClick (AddChar char), title description ] [ text ((guessmarkDir LTR) displayChar) ] ]

        gramStats strings =
            let
                cleanse = charFilter >> model.normalizer >> AstralString.filter model.script.indexed
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
            [ h2 (collapsible "playground") [ text " Spielplatz " ]
            ] ++ ifExpanded "playground" (\_ ->
            [ textarea
                [ class model.script.id
                , dirAttr LTR
                , on "input" (Json.Decode.map SetSandbox Html.Events.targetValue)
                , onInput SetSandbox
                , value ((guessmarkDir LTR) model.sandbox)
                ] []
            , gramStats [model.sandbox]
            ])


        settings =
            let dirOptAttrs val dir = [ value val, selected (dir == model.dir) ]
                breakOptAttrs val break = [ value val, selected (break == model.fixedBreak) ]
                boolOptAttrs val sel = [ value val, selected sel ]
                syllabaryButton syl =
                    let
                        classes = classList [("active", Just syl.id == model.syllabaryId)]
                        handler = onClick (ChooseSyllabary syl.id)
                        attrs = [ type_ "button", handler, classes ]
                    in
                        li [] [ button attrs [ text syl.name ] ]
                syllabarySelection = ol [ class "syllabarySelection" ] (List.map syllabaryButton model.script.syllabaries)
                groupSelectionEntry group = div [] [ label [] (
                    [ input [ type_ "checkbox", checked (Set.member group.short model.selectedGroups), Html.Events.onCheck (SelectGroup group.short) ] []
                    , text group.name
                    ] ++ if group.recorded then [] else
                        [ span [ class "recordWarn", title "Undokumentierte Funde" ] [ text "⚠" ] ]) ]

                groupSelection = List.map groupSelectionEntry model.script.groups
            in  [ h2 (collapsible "settings") [ text " Einstellungen " ]
                ] ++ ifExpanded "settings" (\_ ->
                [ div [] [ label []
                    [ text "Schreibrichtung "
                    , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                        [ option (dirOptAttrs "Original" Nothing) [ text "ursprünglich ⇔" ]
                        , option (dirOptAttrs "LTR" (Just LTR)) [ text "alles ⇒ von links ⇒ nach rechts" ]
                        , option (dirOptAttrs "RTL" (Just RTL)) [ text "alles ⇐ nach links ⇐ von rechts" ]
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
                , div [] [ label [] (
                    [ text "Diese Zeichen "
                    , Html.input [ class model.script.id, value model.removeChars, onInput SetRemoveChars ] []
                    , text " aus dem Textkorpus entfernen."
                    ]
                    ++
                    if not (String.isEmpty model.removeChars)
                    then [ small [] [ text "Vorsicht: Wenn Zeichen entfernt werden, verschiebt sich die Nummerierung innerhalb der Zeilen." ] ]
                    else []
                    )]
                , div [] (
                    [ h4 [] [ text "Syllabar" ]
                    , syllabarySelection
                    , Html.textarea [ class model.script.id, value model.syllabary, onInput SetSyllabary ] []
                    ]
                    ++ if not (String.isEmpty model.missingSyllabaryChars)
                        then [ div [] [ text "Die folgenden Zeichen sind nicht im Syllabar aufgeführt: ", text model.missingSyllabaryChars ] ]
                        else []
                    )
                , div [] [ label []
                    [ h4 [] [ text "Angenommene Silbenlautwerte" ]
                    , Html.textarea [ scriptClass, value model.syllableMap, onInput SetSyllableMap ] []
                    ] ]
                , div [ class "groups" ]
                    ( h4 [] [ text "Gruppen" ] :: groupSelection )
                ])


        -- We want the regex to match all letters of a group, so both the pattern
        -- and the fragments are normalized before matching
        searchPattern =
            let
                normalized = model.normalizer model.search
                fuzziness = String.uncons normalized
            in
                case fuzziness of
                    Nothing -> None
                    Just (head, tail) ->
                        case head |> String.fromChar |> String.toInt of
                            Ok fuzz -> Fuzzy fuzz tail
                            Err _ -> case RegexMaybe.regex normalized of
                                Just pattern -> Pattern pattern
                                Nothing -> Invalid

        search =
            let
                applyBidirectional = if model.bidirectionalSearch then Search.bidirectional else identity
            in
                case searchPattern of
                    Pattern pat -> Just <| model.normalizer >> applyBidirectional (Search.regex pat)
                    Fuzzy fuzz query -> Just <| model.normalizer >> applyBidirectional (Search.fuzzy fuzz query)
                    _           -> Nothing

        searchView =
            let
                maxResults = if model.showAllResults then 0 else 100
                contextLen = 3
                results = Maybe.map (Search.extract model.script maxResults contextLen cleanedFragments) search

                buildResultLine result =
                    let
                        hwspace = " " -- half-width space
                        hwnbspace = " " -- half-width non-breaking space
                        (startLineNr, startCharNr) = result.start
                        (endLineNr, endCharNr) = result.end
                        matchTitle = String.concat <|
                            [ roman startLineNr
                            , hwnbspace
                            , toString startCharNr
                            ] ++
                            if startLineNr /= endLineNr || startCharNr /= endCharNr
                            then
                                (if startLineNr /= endLineNr
                                then [ hwnbspace, "–", hwspace, roman endLineNr, hwnbspace ]
                                else ["–"]) ++
                                [ toString endCharNr ]
                            else []

                        fragment = result.fragment
                        index = Tuple.first result.location
                        ref = href <| String.concat [ "#", fragment.id, toString index ]

                        -- Remove spaces and ensure the guessmarks are oriented left
                        typeset = String.words >> String.concat >> guessmarkDir LTR
                    in
                        li [ class "result" ]
                            [ div [ class "id" ]
                                [ Html.sup [ class "group" ] [ text fragment.group ]
                                , text (fragment.id ++ " ")
                                , span [ class "pos"] [ text matchTitle ]
                                ]
                            , div [ class "match"]
                                [ span [ class "before" ] [ text (typeset result.before) ]
                                , a [ class "highlight", ref ] [ text (typeset result.match) ]
                                , span [ class "after" ] [ text (typeset result.after) ]
                                ]
                            ]
                resultLines : List (Html Msg)
                resultLines =
                    case results of
                        Just res -> List.map buildResultLine res.items
                        Nothing  -> []
                statsBase = \_ ->
                    case results of
                        Just res -> res.raw
                        Nothing  -> List.map .text selectedFragments
                stats = \_ -> [ gramStats (statsBase ()) ]
            in
                [ h2 (collapsible "gramStats") [ text " Frequenzanalyse " ]
                ] ++ ifExpanded "gramStats" stats ++
                [ h2 (collapsible "search") [ text " Suche " ]
                ] ++ ifExpanded "search" (\_ -> [ label []
                    [ text "Suchmuster "
                    , div [ class "searchInput"]
                        ([ Html.input [ scriptClass, dirAttr LTR, value model.search, onInput SetSearch ] []
                        ] ++ if searchPattern == Invalid
                            then [ div [ class "invalidPattern" ] [ text "Ungültiges Suchmuster" ] ]
                            else []
                        )
                    , label []
                        [ input [ type_ "checkbox", checked model.bidirectionalSearch, Html.Events.onCheck BidirectionalSearch ] []
                        , text "auch in Gegenrichtung suchen"
                        ]
                    ]
                ]
                ++ case results of
                    Just res ->
                        if List.length res.items == 0
                        then [ div [class "noresult" ] [ text "Nichts gefunden" ] ]
                        else
                            [ ol [ class "result" ] resultLines ]
                            ++
                                if res.more
                                then
                                    [ text (String.concat [ "Nur ", toString maxResults, " von ", toString (List.length res.raw), " Resultaten werden angezeigt. "])
                                    , button [ type_ "button", onClick ShowAllResults ] [ text "Alle Resultate anzeigen!" ]
                                    ]
                                else []
                    Nothing -> [ div [ class "searchExamples" ]
                        [ h3 [] [ text "Suchbeispiele" ]
                        , dl []
                            [ dt [] [ text "?[]" ]
                            , dd [] [ text "Suche nach Varianten von  (in-šu-uš oder in-šu-ši mit optionalem NAP)" ]
                            , dt [] [ text "[]" ]
                            , dd [] [ text "Suche nach  und erlaube einen Platzhalter anstelle des NAP" ]
                            , dt [] [ text "([^])\\1" ]
                            , dd [] [ text "Suche nach Silbenwiederholungen wie " ]
                            , dt [] [ text "([^]).\\1" ]
                            , dd [] [ text "Silbenwiederholungen mit einem beliebigen Zeichen dazwischen ()" ]
                            , dt [] [ text "[^]+" ]
                            , dd [] [ text "\"Worte\", wenn wir den vertikalen Strich als Worttrenner annehmen" ]
                            , dt [] [ text "[]" ]
                            , dd [] [ text "Alle Stellen anzeigen, wo  oder  steht" ]
                            ]
                        ]
                    ]
                )

        fragmentView fragment =
            let
                syllabize =
                    if model.syllabize
                    then model.syllabizer
                    else identity

                -- Insert a zero-width space after the "" separator so that long
                -- lines can be broken by the browser
                breakAfterSeparator = Regex.replace Regex.All (Regex.regex "[]") (\l -> l.match ++ zeroWidthSpace)
                textMod = String.trim >> breakAfterSeparator >> guessmarkDir (effectiveDir fragment.dir)

                -- Find matches in the fragment
                matches =
                    case search of
                        Just s -> s (AstralString.filter model.script.indexed fragment.text)
                        Nothing -> []

                guessmarks = Set.fromList <| AstralString.toList model.script.guessMarkers
                guessmarkClass char =
                    if Set.member char guessmarks
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
                                    model.script.indexed char
                                then
                                    ((a (highlightClass ++ titleAttr ++ idAttr) [ text (syllabize char) ]) :: elems, idx+1)
                                else
                                    ((span (guessmarkClass char) [ text  char ]) :: elems, idx)
                        (elems, endIdx) = AstralString.toList chars |> List.foldl charPos ([], lineIdx)
                        elemLine = li [ class "line", lineDirAttr lineNr fragment.dir ] (List.reverse elems)
                    in
                        (elemLine :: lines, endIdx)

                -- Build line entries from text
                lines = List.reverse (Tuple.first (List.foldl line ([], 0) (String.lines (textMod fragment.text))))
            in
                div [ classList [ ("plate", True), ("fixedBreak", model.fixedBreak), (model.script.id, True) ], dirAttr fragment.dir ]
                [ h3 [] [ sup [ class "group" ] [ text fragment.group ], span [ dir "LTR" ] [ text fragment.id ] ]
                , ol [ class "fragment", dirAttr fragment.dir ] lines
                ]

        contact = div [ class "footer" ]
                [ h2 [] [ text "Kontakt mit dem Forschungsteam" ]
                , text "Für detaillierte Informationen zum Elamicon: Online Corpus of Linear Elamite Inscriptions (OCLEI), Hintergründe und Möglichkeiten zur Zusammenarbeit mit dem Entzifferungsteam der Universität Bern wendet euch bitte an " 
                , strong [] [ text "michael.maeder[ätt]isw.unibe.ch" ], text ". "
                , text "Wir können euch Tipps geben, wie ihr zur Entzifferung der elamischen Strichschrift (Linear Elamite) beitragen könnt und auch sagen, was wir bisher herausgefunden haben."
                , br [] [], br [] [], text " Herzlichen Dank fürs Interesse und viel Spass beim Tüfteln. Euer Team vom \"Linear Elamite Decipherment Project\", Institut für Sprachwissenschaft der Universität Bern."
                , br [] [], a [ href "https://center-for-decipherment.ch/" ]
                    [ text "center-for-decipherment.ch" ]
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
                , text ".  ", br [] []
                , a [ href "fonts/Elamicon-Fonts.zip" ]
                    [ text "Elamicon-Schriften installieren."]
                , text " ", br [] []
                , a [ href "https://github.com/elamicon/elamicon/" ]
                    [ text "Das Projekt auf Github." ]
                ]

        scriptOpt script = option
            [ value script.id, selected (model.script.id == script.id) ]
            [ text script.name ]
    in
        div [ class model.script.id ] (
            [ div []
                [ label []
                    [ text "Skript "
                    , Html.select
                        [ on "change" (Json.Decode.map SetScript scriptDecoder) ]
                        (List.map scriptOpt Scripts.scripts)
                    ]
                ]
            , h1 [ class "secondary" ] [ text " Online Corpus of Linear Elamite Inscriptions OCLEI " ]
            , h1 [] [ text " Elamicon " ]
            ] ++ syllabary
              ++ playground
              ++ settings
              ++ searchView ++
            [ h2 [] [ text " Textfragmente " ]
            ] ++ [ div [ dirAttr LTR ] (List.map fragmentView cleanedFragments) ]
              ++ [ contact, small [] [ footer ] ]
        )
