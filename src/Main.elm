module Main exposing (main)

import Dict
import Grams
import Browser
import Browser.Dom as Dom
import Browser.Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Json.Decode
import List
import Markdown
import Markdown.Config exposing (..)
import Regex
import Script exposing (..)
import Scripts exposing (..)
import Specialchars exposing (..)
import Search
import Set
import String
import String exposing (fromInt)
import Syllabary
import Task
import Token
import Url
import WritingDirections exposing (..)
import RomanNumerals
import Generated.Build exposing (build)
import Sections.Glyphs
import State exposing (..)
import Browser.Navigation as Navigation

import Settings exposing (settings)

main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


-- Example "#elam&pos=example" -> "example"
posFromUrl url =
    case url.fragment of
        Nothing -> Nothing
        Just fragment ->
            let
                params = String.split "&" fragment
                prefix = "pos="
                posVal = String.dropLeft (String.length prefix)
                maybePos s = if String.startsWith prefix s
                    then Just (posVal s)
                    else Nothing
                found = List.filterMap maybePos params
            in
                List.head found


scrollToPos maybePos =
    case maybePos of
        Nothing -> Cmd.none
        Just pos -> Dom.getElement pos
            |> Task.andThen (\info -> Dom.setViewport info.element.x info.element.y)
            |> Task.attempt (\_ -> NoOp)


init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        script = Scripts.initialScript
        initialModel =
            { script = script
            , dir = Nothing
            , fixedBreak = True
            , selected = Nothing
            , normalizer = identity
            , normalize = False
            , removeChars = ""
            , syllabaryId = Nothing
            , syllabary = Syllabary.fromString ""
            , syllabaryString = ""
            , missingSyllabaryChars = ""
            , syllableMap = script.syllableMap
            , phoneticize = False
            , sandbox = ""
            , search = ""
            , searchBidirectional = True
            , showAllResults = False
            , linesplitSearch = False
            , selectedGroups = Set.empty
            , collapsed = Set.fromList [ "info", "gramStats", "playground", "syllabary", "settings", "search" ]
            , url = url
            , key = key
            }
        fragment =
            Maybe.withDefault "" url.fragment
        loadedModel =
            State.updateStateFromUrlFragment fragment initialModel
    in
       ( scriptUpdate loadedModel, Cmd.none )


scriptUpdate : Model -> Model
scriptUpdate model =
    let
        allGroups =
            Set.fromList (List.map .id model.script.groups)

        selectedGroups =
            Set.intersect allGroups model.selectedGroups

        selectedGroupsFailsafe =
            if Set.isEmpty selectedGroups then
                allGroups
            else
                selectedGroups

        initialSyllabary =
            case List.head model.script.syllabaries of
                Nothing -> emptySyllabary
                Just syl -> syl
    in
        switchSyllabary initialSyllabary
            { model
                | selectedGroups = selectedGroupsFailsafe
                , syllableMap = model.script.syllableMap
                , search = ""
                , searchBidirectional = model.script.searchBidirectionalPreset
            }


setSyllabary : String -> Model -> Model
setSyllabary new model =
    let
        syllabary = Syllabary.filter model.script.indexed <| Syllabary.fromString new
        tokensInScript = Set.fromList <| Token.fromNamed model.script.tokens
        tokensInSyllabary = Syllabary.allTokens syllabary
        missing = Set.diff tokensInScript tokensInSyllabary
    in
    { model
        | syllabary = syllabary
        , syllabaryString = new
        , normalizer = Syllabary.normalize syllabary
        , missingSyllabaryChars = String.fromList <| Set.toList missing
    }


switchSyllabary : SyllabaryDef -> Model -> Model
switchSyllabary new model =
    let
        updated =
            setSyllabary new.syllabary model
    in
    { updated
        | syllabaryId = Just new.id
    }

zeroWidthSpace =
    "\u{200B}"

updateUrlFromState : Model -> ( Model, Cmd Msg )
updateUrlFromState model =
    let
        fragment =
            State.urlFragmentFromState model
    in
    ( model, Navigation.replaceUrl model.key ("#" ++ fragment) )

newUrlFromState : Model -> ( Model, Cmd Msg )
newUrlFromState model =
    let
        fragment =
            State.urlFragmentFromState model
    in
    ( model, Navigation.replaceUrl model.key ("#" ++ fragment) )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScript script ->
            let
                scriptUpdatedModel =
                    scriptUpdate { model |
                        script = script,
                        dir = Nothing
                    }
            in
            newUrlFromState (scriptUpdate scriptUpdatedModel)

        SetSandbox str ->
            ( { model | sandbox = str }, Cmd.none )

        AddChar char ->
            ( { model
                | sandbox = model.sandbox ++ char
                , collapsed = Set.remove "playground" model.collapsed
              }
            , Cmd.none
            )

        Select pos ->
            ( { model | selected = Just pos }, Cmd.none )

        SetBreaking breaking ->
            ( { model | fixedBreak = breaking }, Cmd.none )

        SetNormalize normalize ->
            ( { model | normalize = normalize }, Cmd.none )

        SetRemoveChars chars ->
            ( { model | removeChars = chars }, Cmd.none )

        SetDir dir ->
            updateUrlFromState { model | dir = dir }

        ChooseSyllabary id ->
            ( case List.head <| List.filter (.id >> (==) id) model.script.syllabaries of
                Just syl ->
                    switchSyllabary syl model

                Nothing ->
                    model
            , Cmd.none
            )

        SetSyllabary new ->
            ( setSyllabary new model, Cmd.none )

        SetSyllableMap new ->
            ( { model | syllableMap = new }, Cmd.none )

        SetPhoneticize phoneticize ->
            ( { model | phoneticize = phoneticize }, Cmd.none )

        SetSearch new ->
            let
                charRange lower upper = List.map Char.fromCode (
                                            List.range (Char.toCode lower)
                                                       (Char.toCode upper))

                -- Set of characters used in regexes
                -- All latin chars are included to allow character classes.
                regexMeta = String.toList "()[]^$|-+*.?=!<>\\"
                allowedRegexChars = Set.fromList (regexMeta
                                               ++ ['⏎']
                                               ++ charRange '0' '9'
                                               ++ charRange 'a' 'z'
                                               ++ charRange 'A' 'Z')

                -- When copying strings from the fragments into the search
                -- field, irrelevant whitespace and markers might get copied
                -- as well. To prevent these search-breaking chars, we only
                -- keep indexed chars in the search pattern.
                -- This means that irrelevant chars vanish as they are typed!
                -- Maybe it would be better to just ignore the chars when
                -- searching but leave them alone in the search-field?
                indexedOrRegex c = model.script.indexed c
                                   || Set.member c allowedRegexChars
                cleanSearch = String.filter indexedOrRegex new
            in
            updateUrlFromState { model | search = cleanSearch, showAllResults = False }

        ShowAllResults ->
            ( { model | showAllResults = True }, Cmd.none )

        BidirectionalSearch new ->
            ( { model | searchBidirectional = new }, Cmd.none )

        LinesplitSearch new ->
            ( { model | linesplitSearch = new }, Cmd.none )

        SelectGroup group include ->
            updateUrlFromState { model
                | selectedGroups =
                    (if include then
                        Set.insert

                     else
                        Set.remove
                    )
                        group
                        model.selectedGroups
              }

        Toggle section ->
            ( { model
                | collapsed =
                    (if Set.member section model.collapsed then
                        Set.remove

                     else
                        Set.insert
                    )
                        section
                        model.collapsed
              }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Just f ->
                            -- Jump to the desired section
                            ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )
                        Nothing ->
                            -- Static files look like they're internal to this router.
                            -- Hand the link to the browser.
                            ( model, Browser.Navigation.load (Url.toString url) )
                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        UrlChanged url ->
            let
                modelWithNewUrl = { model | url = url }
                newModel = State.updateStateFromUrlFragment (Maybe.withDefault "" url.fragment) modelWithNewUrl
                scriptUpdatedModel =
                    if newModel.script /= model.script
                        then scriptUpdate newModel
                        else newModel
            in
                ( scriptUpdatedModel , scrollToPos (posFromUrl url) )

        NoOp ->
            (model, Cmd.none)


type SearchPattern
    = None
    | Invalid
    | Pattern Regex.Regex
    | Fuzzy Int String


view : Model -> Browser.Document Msg
view model =
    let
        effectiveDir original =
            case model.dir of
                Nothing ->
                    original

                Just dir ->
                    dir

        lineDirAttr nr original =
            Html.Attributes.dir
                (dirStr
                    (case effectiveDir original of
                        BoustroR ->
                            if modBy 2 nr == 0 then
                                RTL

                            else
                                LTR

                        _ ->
                            effectiveDir original
                    )
                )

        dirAttr original =
            lineDirAttr 0 original

        selectedFragments =
            List.filter (\f -> Set.member f.group model.selectedGroups) model.script.fragments

        notAlphanum = Maybe.withDefault Regex.never (Regex.fromString "\\W+")

        charId idString posNr =
            let
                cleanId = Regex.replace notAlphanum (\_ -> "_") idString
                nrString = String.fromInt posNr
            in
                cleanId ++ "." ++ nrString

        charLink fragmentId index =
            String.concat
                [ "#", model.script.id
                , "&pos=", charId fragmentId index ]

        -- Normalize letters if this is enabled
        normalize =
            if model.normalize then
                model.normalizer

            else
                identity

        phoneticReplacements = sylDict model.syllableMap

        -- Build filter that removes undesired chars
        removeCharSet =
            Set.fromList <| String.toList model.removeChars

        keepChar c =
            Set.member c removeCharSet |> not

        charFilter =
            String.filter keepChar

        -- When the search splits along lines, make the newlines count
        linesplitInsertion =
            if model.linesplitSearch
                then String.join "⏎\n" << String.split "\n"
                else identity

        -- When splitting by line, the linebreak is made to count as char
        indexed =
            if model.linesplitSearch
            then \c -> c == '⏎' || model.script.indexed c
            else model.script.indexed

        -- Process fragment text for display
        cleanse =
            String.trim >> linesplitInsertion >> normalize >> charFilter

        cleanedFragments =
            List.map (\f -> { f | text = cleanse f.text }) selectedFragments

        decorate decorationAccessor title =
            let
                ( decorLeft, decorRight ) =
                    decorationAccessor model.script.decorations
            in
            decorLeft ++ " " ++ title ++ " " ++ decorRight

        collapsibleTitle section title decorationAccessor =
            let
                collapsed =
                    Set.member section model.collapsed

                attrs =
                    [ classList
                        [ ( "collapsible", True )
                        , ( "collapsed", collapsed )
                        ]
                    , onClick (Toggle section)
                    ]

                ( decorUp, decorDown ) =
                    model.script.decorations.collapse

                toggle =
                    if collapsed then
                        decorUp

                    else
                        decorDown
            in
            [ h2 attrs
                [ text (decorate decorationAccessor title)
                , span [ class "toggle" ] [ text toggle ]
                ]
            ]

        -- build is called lazily when the section is expanded
        ifExpanded : String -> (() -> List a) -> List a
        ifExpanded section build =
            if Set.member section model.collapsed then
                []

            else
                build ()

        charpicker =
            collapsibleTitle "charpicker" "Character Picker" .signs
                ++ ifExpanded "charpicker" (\_ -> Sections.Glyphs.html model)

        gramStats strings =
            let
                -- Keep only indexed chars and split at wildcard chars. Because
                -- combinations with the wildcard char are not interesting.
                onlyIndexed = charFilter
                            >> model.normalizer
                            >> String.filter indexed
                            >> String.split (String.fromChar wildcardChar)
                            >> (++)
                gramStrings = List.foldr onlyIndexed [] strings

                tallyGrams =
                    List.filter (List.isEmpty >> not) <| List.map Grams.tally <| Grams.read 7 gramStrings

                tallyEntry gram ts =
                    let
                        -- Grams that only occur once are considered "boring"
                        -- and deemphasized in the view.
                        boringClass =
                            if gram.count < 2 then
                                [ class "boring" ]

                            else
                                []
                    in
                    tr boringClass
                        [ td [ class "count" ] [ text <| String.fromInt gram.count ]
                        , td [] [ text gram.seq ]
                        ]
                        :: ts

                ntally n tallyGram =
                    li [] [ table [ class "tallyGram" ] (List.foldr tallyEntry [] tallyGram) ]
            in
            if List.isEmpty tallyGrams then
                div [] []

            else
                div []
                    [ h3 [] [ text "N-gram statistics" ]
                    , ul [ class "tallyGrams" ] (List.indexedMap ntally tallyGrams)
                    ]

        markdownOptions =
            { defaultOptions
                | rawHtml =
                    Sanitize
                        { defaultSanitizeOptions
                            | allowedHtmlElements = defaultSanitizeOptions.allowedHtmlElements ++ [ "sub", "sup" ]
                        }
            }

        info =
            collapsibleTitle "info" "Intro & Sources" .info
                ++ ifExpanded "info" (\_ -> Markdown.toHtml (Just markdownOptions) (model.script.description ++ model.script.sources))

        playground =
            collapsibleTitle "playground" "Sandbox" .sandbox
                ++ ifExpanded "playground"
                    (\_ ->
                        [ textarea
                            [ class "sandbox"
                            , dirAttr LTR
                            , on "input" (Json.Decode.map SetSandbox Html.Events.targetValue)
                            , onInput SetSandbox
                            , value (guessMarkDir LTR model.sandbox)
                            ]
                            []
                        , gramStats [ model.sandbox ]
                        ]
                    )

        syllabarySettings =
            let
                syllabaryButton syl =
                    let
                        classes =
                            classList [ ( "active", Just syl.id == model.syllabaryId ) ]

                        handler =
                            onClick (ChooseSyllabary syl.id)

                        attrs =
                            [ type_ "button", handler, classes ]
                    in
                    li [] [ button attrs [ text syl.name ] ]

                syllabarySelection =
                    ol [ class "syllabarySelection" ] (List.map syllabaryButton model.script.syllabaries)

                groupSelectionEntry group =
                    div []
                        [ label []
                            [ input [ type_ "checkbox", checked (Set.member group.id model.selectedGroups), Html.Events.onCheck (SelectGroup group.id) ] []
                            , text group.name
                            , small [] [ text (" " ++ group.extra) ]
                            ]
                        ]

                groupSelection =
                    List.map groupSelectionEntry model.script.groups
            in
            collapsibleTitle "syllabary" "Syllabary" .syllabary
                ++ ifExpanded "syllabary"
                    (\_ ->
                        [ div []
                            [ label []
                                [ h4 [] [ text "Syllabary (current state of decipherment)" ]
                                , Html.textarea [ value model.syllableMap, onInput SetSyllableMap ] []
                                ]
                            ]
                        , div []
                            ([ h4 [] [ text "Dynamic Syllabary (editable grouping)" ]
                             , syllabarySelection
                             , Html.textarea [ value model.syllabaryString, onInput SetSyllabary ] []
                             ]
                                ++ (if not (String.isEmpty model.missingSyllabaryChars) then
                                        [ div [] [ text "The following signs are not listed in the selected syllabary: ", text model.missingSyllabaryChars ] ]

                                    else
                                        []
                                   )
                            )
                        , div [ class "groups" ]
                            (h4 [] [ text "Groups" ] :: groupSelection)
                        ]
                    )

        -- We want the regex to match all letters of a group, so both the pattern
        -- and the fragments are normalized before matching
        searchPattern =
            let
                normalized =
                    model.normalizer model.search

                fuzziness =
                    String.uncons normalized
            in
            case fuzziness of
                Nothing ->
                    None

                Just ( head, tail ) ->
                    case head |> String.fromChar |> String.toInt of
                        Just fuzz ->
                            Fuzzy fuzz tail

                        Nothing ->
                            case Regex.fromString normalized of
                                Just pattern ->
                                    Pattern pattern

                                Nothing ->
                                    Invalid

        search =
            let
                applyBidirectional =
                    if model.searchBidirectional then
                        Search.bidirectional

                    else
                        identity
            in
            case searchPattern of
                Pattern pat ->
                    Just <| model.normalizer >> applyBidirectional (Search.regex pat)

                Fuzzy fuzz query ->
                    Just <| model.normalizer >> applyBidirectional (Search.fuzzy fuzz query)

                _ ->
                    Nothing

        searchView =
            let
                maxResults =
                    if model.showAllResults then
                        0

                    else
                        100

                contextLen =
                    3

                results =
                    Maybe.map (Search.extract indexed maxResults contextLen cleanedFragments) search

                buildResultLine result =
                    let
                        -- half-width space
                        hwspace =
                            "\u{2009}"

                        -- half-width non-breaking space
                        hwnbspace =
                            "\u{202F}"

                        ( startLineNr, startCharNr ) =
                            result.start

                        ( endLineNr, endCharNr ) =
                            result.end

                        matchTitle =
                            String.concat <|
                                [ RomanNumerals.fromInteger startLineNr
                                , hwnbspace
                                , fromInt startCharNr
                                ]
                                    ++ (if startLineNr /= endLineNr || startCharNr /= endCharNr then
                                            (if startLineNr /= endLineNr then
                                                [ hwnbspace, "–", hwspace,
                                                  RomanNumerals.fromInteger endLineNr, hwnbspace ]

                                             else
                                                [ "–" ]
                                            )
                                                ++ [ fromInt endCharNr ]

                                        else
                                            []
                                       )

                        fragment =
                            result.fragment

                        index =
                            Tuple.first result.location

                        ref =
                            href (charLink fragment.id index)

                        -- Remove spaces and ensure the guessmarks are oriented left
                        removeWhitespace = String.words >> String.concat
                        fixGuessmarkDir = guessMarkDir LTR
                        typeset =
                            removeWhitespace >> fixGuessmarkDir
                    in
                    li [ class "result" ]
                        [ div [ class "id" ]
                            [ Html.sup [ class "group" ] [ text fragment.group ]
                            , text (fragment.id ++ " ")
                            , span [ class "pos" ] [ text matchTitle ]
                            ]
                        , div [ class "match" ]
                            [ span [ class "before" ] [ text (typeset result.before) ]
                            , a [ class "highlight", ref ] [ text (typeset result.match) ]
                            , span [ class "after" ] [ text (typeset result.after) ]
                            ]
                        ]

                resultLines : List (Html Msg)
                resultLines =
                    case results of
                        Just res ->
                            List.map buildResultLine res.items

                        Nothing ->
                            []

                statsBase =
                    \_ ->
                        case results of
                            Just res ->
                                res.raw

                            Nothing ->
                                List.map .text selectedFragments

                stats =
                    \_ -> [ gramStats (statsBase ()) ]

                searchExamplesList examples =
                    let
                        def ( t, e ) =
                            [ dt [] [ text t ], dd [] [ text e ] ]
                    in
                    dl [] (List.concatMap def examples)
            in
            collapsibleTitle "gramStats" "Frequency Analysis" .grams
                ++ ifExpanded "gramStats" stats
                ++ collapsibleTitle "search" "Search" .search
                ++ ifExpanded "search"
                    (\_ ->
                         label [] (
                            [ text "Search "
                            , div [ class "searchInput" ]
                                ( Html.input [ dirAttr LTR, value model.search, onInput SetSearch ] []
                                  :: (if searchPattern == Invalid then
                                            [ div [ class "invalidPattern" ] [ text "Invalid pattern" ] ]
                                      else
                                            []
                                     )
                                )
                            , label []
                                [ input [ type_ "checkbox", checked model.searchBidirectional, Html.Events.onCheck BidirectionalSearch ] []
                                , text "also search in reverse direction"
                                ]
                            , label []
                                [ input [ type_ "checkbox", checked model.linesplitSearch, Html.Events.onCheck LinesplitSearch ] []
                                , text "split search at new lines"
                                ]
                            ]
                            ++ (if model.linesplitSearch then
                                    [ div [] [ text "Use the character [⏎] to search across lines. Just copy the ⏎ character to the search-input to use it. For example, write ", span [ class "searchCodeExample" ] [ text "line⏎?break" ], text " to allow (but not require) the word linebreak to be split across lines."] ]

                                else
                                    []
                               )
                        )
                        :: (case results of
                                Just res ->
                                    if List.length res.items == 0 then
                                        [ div [ class "noresult" ] [ text "No results" ] ]

                                    else
                                        ol [ class "result" ] resultLines
                                            :: (if res.more then
                                                    [ text (String.concat [ "Only showing ", fromInt maxResults, " of ", fromInt (List.length res.raw), " results. " ])
                                                    , button [ type_ "button", onClick ShowAllResults ] [ text "Show all!" ]
                                                    ]

                                                else
                                                    []
                                                )

                                Nothing ->
                                    [ div [ class "searchExamples" ]
                                        [ h3 [] [ text "Examples of search patterns" ]
                                        , searchExamplesList model.script.searchExamples
                                        ]
                                    ]
                            )
                    )

        fragmentView fragment =
            let
                -- Insert a zero-width space after the "" separator so that long
                -- lines can be broken by the browser
                seperatorMatch =
                    Maybe.withDefault Regex.never (
                        Regex.fromString ("[" ++ model.script.seperatorChars ++ "]"))

                breakAfterSeparator =
                    Regex.replace seperatorMatch (\l -> l.match ++ zeroWidthSpace)

                textMod = String.trim
                       >> breakAfterSeparator
                       >> guessMarkDir (effectiveDir fragment.dir)

                -- Find matches in the fragment
                matches =
                    case search of
                        Just s ->
                            s (String.filter indexed fragment.text)

                        Nothing ->
                            []

                guessmarkClass char =
                    if Set.member char guessMarkers then
                        [ class "guessmark" ]

                    else
                        []

                -- Depending on the tablet's writing direction and the chosen
                -- normalization of writing direction, we set dir = LTR or RTL.
                -- For fragments written top-down we use the "tdr" class and
                -- set writing-mode in CSS.
                fragmentAttrs =
                    [ classList
                        [ ( "fragment", True )
                        , ( "tdr", effectiveDir fragment.dir == TDR )
                        ]
                    , dirAttr fragment.dir
                    ]

                -- Fold helper building a list element from a text line
                -- The tricky bit here is to keep indexed character position so
                -- we can track highlighted searches which may span across
                -- lines.
                line chars ( prevLines, lineIdx ) =
                    let
                        lineNr =
                            List.length prevLines

                        charPos char ( tailElems, idx, prevPhoneticReplaced ) =
                            let
                                within ( index, length ) =
                                    (idx >= index) && (idx < index + length)

                                highlightClass =
                                    if List.any within matches then
                                        [ class "highlight" ]

                                    else
                                        []

                                (phoneticStr, phoneticReplaced) =
                                        case Dict.get char phoneticReplacements of
                                            Just replacement ->
                                                (replacement, True)
                                            Nothing ->
                                                (String.fromChar char, False)

                                idStr = "Line " ++ String.fromInt (lineNr + 1) ++ " position " ++ String.fromInt (idx - lineIdx + 1)

                                phoneticTitleStr =
                                    if phoneticReplaced then
                                        " Phonetic: " ++ phoneticStr
                                    else
                                        ""

                                charAttrs =
                                    [ title (idStr ++ phoneticTitleStr)
                                    , id (charId fragment.id idx)
                                    ]

                                joiner =
                                    if model.phoneticize && prevPhoneticReplaced && phoneticReplaced then
                                        text "-"
                                    else
                                        text ""

                                showText =
                                    if model.phoneticize then
                                        phoneticStr
                                    else
                                        String.fromChar char

                            in
                            if indexed char then
                                (
                                    (span
                                        (highlightClass ++ charAttrs)
                                        [text showText]
                                    ) :: joiner :: tailElems
                                , idx + 1
                                , phoneticReplaced
                                )
                            else
                                (
                                    (span
                                        (guessmarkClass char)
                                        [text showText]
                                    ) :: tailElems
                                , idx
                                , prevPhoneticReplaced
                                )

                        ( elems, endIdx, _ ) =
                            String.toList chars |> List.foldl charPos ( [], lineIdx, False )

                        elemLine =
                            li [ class "line", lineDirAttr lineNr fragment.dir ] (List.reverse elems)
                    in
                    ( elemLine :: prevLines, endIdx )

                -- Build line entries from text
                lines =
                    List.reverse (Tuple.first (List.foldl line ( [], 0 ) (String.lines (textMod fragment.text))))

                thumb =
                    case fragment.plate of
                        Nothing ->
                            []

                        Just url ->
                            [ a [ href url, target "_blank", class "img" ] [ img [ src (url ++ ".thumb") ] [] ] ]

                fragmentLink =
                    -- Make the title element a link if the fragment has one.
                    -- Note on title text: it is always written LTR.
                    -- But the ordering of the title text and thumb depends on
                    -- the writing direction of the plate. The text comes
                    -- first. As such, we inherit the writing direction to get
                    -- the elements order: first title, then thumb. But
                    -- the title text we override to LTR.
                    case fragment.link of
                        Nothing ->
                         span [ dir "LTR"
                              ]

                        Just link ->
                            a [ dir "LTR"
                              , href (Maybe.withDefault "" fragment.link )
                              ]

                fragmentTitle =
                    [ fragmentLink
                        [ sup [ class "group" ] [ text fragment.source ]
                        , text fragment.id
                        ]
                    ]

            in
            div [ classList [ ( "plate", True ), ( "fixedBreak", model.fixedBreak ), ( model.script.id, True ) ], dirAttr fragment.dir ]
                [ h3 [] (fragmentTitle ++ thumb)
                , ol fragmentAttrs lines
                ]

        overviewLink =
            case model.script.inscriptionOverviewLink of
                Nothing -> []
                Just link ->
                    [ p []
                        [ text "For an overview, see "
                        , a [ href link ]
                            [ text "text corpus with concordance list" ]
                        , text "."
                        ]
                    ]

        fragmentsView =
            [ h2 [] [ text (decorate .inscriptions "Inscriptions") ] ]
            ++ overviewLink ++
            [ div [ dirAttr LTR ] (List.map fragmentView cleanedFragments)
            , contact
            ]

        contact =
            div [ class "footer" ]
                [ h2 [] [ text "Resources" ]
                , text "Visit "
                , a [ href "https://center-for-decipherment.ch/" ]
                    [ text "center-for-decipherment.ch" ]
                , text " for more information and read the "
                , a [ href "https://center-for-decipherment.ch/tool-introduction" ]
                    [ text " tool introduction" ]
                , text " on how to use this tool."
                , br [] []
                , text "For criticism, specific questions, and possibilities for collaboration, please contact "
                , strong [] [ text "m.maeder[ätt]geass.ch" ]
                , text ". "
                , text "We can help you with tips on how to contribute to the decipherments."
                , br [] []
                , br [] []
                , text " Thank you for your interest and have fun puzzling over the inscriptions. Your GEAS"
                , text " team, Institut für Sprachwissenschaft, Universität Bern."
                , br [] []
                , a [ href ("fonts/GEAS-Fonts.zip") ]
                    [ text ("Download the GEAS truetype font collection.") ]
                , text " "
                ]

        footer =
            div [ class "footer" ]
                [ text "This site was last updated "
                , text build
                , text ". It is built with "
                , a [ href "https://fontforge.github.io/" ]
                    [ text "FontForge" ]
                , text ", "
                , a [ href "https://inkscape.org" ]
                    [ text "Inkscape" ]
                , text ", and "
                , a [ href "http://elm-lang.org/" ]
                    [ text "Elm" ]
                , text ". We use the "
                , a [ href "http://www.unicode.org/faq/private_use.html" ] [ text "Unicode Private Use Area ♥" ]
                , text ". "
                , br [] []
                , a [ href "https://github.com/elamicon/elamicon/" ]
                    [ text "The project on Github." ]
                ]

        showWhenCorpus elms = if cleanedFragments == [] then [] else elms
    in
        { title = model.script.headline
        , body =
            [ div [ class model.script.id ] (
                [ settings model
                , h1 [ class "secondary" ] [ text (decorate .headline model.script.headline) ]
                , h1 [] [ text (decorate .title model.script.title) ]
                ]
                ++ info
                ++ charpicker
                ++ playground
                ++ syllabarySettings
                ++ showWhenCorpus searchView
                ++ showWhenCorpus fragmentsView
                ++ [ small [] [ footer ] ]
            )]
        }
