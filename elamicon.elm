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

")
elamLetters = Set.fromList letters

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedLetters = Set.fromList ([ '', 'X' ] ++ letters)
indexed char = Set.member char indexedLetters


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
    , { displayChar = "", char = '', description = "Markiert Bruchstellen" }
    ]


-- Syllabary definition
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letter are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
syllabaryPreset = "
                             
                                                                                                                                                                                                                        
          
"

syllabaryList : String -> List (Char, List Char)
syllabaryList syllabary =
    let
        letterGroup letterString =
            case (String.toList letterString) of
                main :: ext -> (main, ext)
                _ -> ('?', []) -- should not be reachable?
    in
        map letterGroup (String.words syllabary)

-- Sanitize the syllabary string to include all Elam letters but no duplicates
completeSyllabary syllabary =
    let
        dedup letter (seen, dedupSyllabary) =
            if Set.member letter seen
            then
                (seen, dedupSyllabary)
            else
                if Set.member letter indexedLetters
                then
                    (Set.insert letter seen, dedupSyllabary ++ String.fromChar letter)
                else
                    (seen, dedupSyllabary ++ String.fromChar letter)

        (presentLetters, dedupedSyllabary) = List.foldl dedup (Set.empty, "") (String.toList syllabary)
        missingLetters = Set.diff elamLetters presentLetters
    in
        dedupedSyllabary
        ++ " "
        ++ String.join " " (map String.fromChar (Set.toList missingLetters))


-- When searching the corpus (and optionally when displaying it) we want to treat all
-- characters in an letter group as the same character. This function builds a
-- dictionary that maps all alternate versions of a letter to the main letter.
normalization : String -> Dict.Dict Char Char
normalization syllabary =
    let allLetters = Set.fromList letters
        ins group dict =
            case (String.toList group) of
                main :: extras -> List.foldl (insLetter main) (Dict.insert main main dict) extras
                _ -> dict
        insLetter main ext dict = Dict.insert ext main dict
    in List.foldl ins Dict.empty (String.words syllabary)


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

X​



        """
      }
    , { id = "B", dir = LTR, text =
        """

​

        """
      }
    , { id = "C", dir = RTL, text =
        """
​
​
​
​


        """
      }
    , { id = "D", dir = RTL, text =
        """



k
        """
      }
    , { id = "E", dir = RTL, text =
        """




        """
      }
    , { id = "F", dir = RTL, text =
        """




        """
      }
    , { id = "G", dir = RTL, text =
        """

X

        """
      }
    , { id = "H", dir = RTL, text =
        """
X

k

        """
      }
    , { id = "I", dir = RTL, text =
        """




        """
      }
    , { id = "J", dir = RTL, text =
        """


        """
      }
    , { id = "K", dir = RTL, text =
        """


X
X

X
        """
      }
    , { id = "L", dir = RTL, text =
        """




        """
      }
    , { id = "M", dir = RTL, text =
        """




X
        """
      }
    , { id = "N", dir = RTL, text =
        """






        """
      }
    , { id = "O", dir = RTL, text =
        """







X
        """
      }
    , { id = "O.rs", dir = RTL, text =
        """
X
        """
      }
    , { id = "P", dir = LTR, text =
        """

        """
      }
    , { id = "Q", dir = LTR, text =
        """
​Xk​​​
        """
      }
    , { id = "R", dir = RTL, text =
        """


X
        """
      }
    , { id = "R.rs", dir = RTL, text =
        """

        """
      }
    , { id = "S", dir = RTL, text =
        """
X
        """
      }
    , { id = "T", dir = RTL, text =
        """

        """
      }
    , { id = "U", dir = RTL, text =
        """


        """
      }
    , { id = "V", dir = RTL, text =
        """

X
        """
      }
    , { id = "W", dir = RTL, text =
        """

        """
      }
    , { id = "KS1", dir = LTR, text =
        """




X
        """
      }
    , { id = "KS1.rs", dir = RTL, text =
        """

        """
      }
    , { id = "KS2", dir = LTR, text =
        """





        """
      }
    , { id = "KS2.rs", dir = LTR, text =
        """

        """
      }
    , { id = "KS3", dir = LTR, text =
        """






        """
      }
    , { id = "KS3.rs", dir = LTR, text =
        """

        """
      }
    , { id = "KS4", dir = RTL, text =
        """
XX
X
        """
      }
    , { id = "neuA", dir = RTL, text =
        """
            XX​
            ​​
            ​​
            X​​k 
            X ​
            ​ 
            X 
            X​XXXX
            X
        """
      }
     , { id = "neuB", dir = RTL, text =
        """
            kkk
            
            X
        """
      }
    , { id = "neuC", dir = RTL, text =
        """
            XXX
                    X
                       
        """
      }
    , { id = "neuC.2", dir = LTR, text =
        """
        
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
            
            
            XX
            X
        """
      }
    , { id = "neuG", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuH", dir = RTL, text =
        """
            X
            
        """
      }
    , { id = "neuI.a", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuI.b", dir = RTL, text =
        """
            
            X
            
        """
      }
    , { id = "neuI.c", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuI.d", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuJ.a", dir = RTL, text =
        """
            
        """
      }
    , { id = "neuJ.b", dir = RTL, text =
        """
            
        """
      }
    , { id = "neuJ.c", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuJ.d", dir = RTL, text =
        """
            
            
        """
      }
    , { id = "neuK.a", dir = LTR, text =
        """
            
        """
      }
    , { id = "neuK.b", dir = LTR, text =
        """
            
            X​X
            
        """
      }
    , { id = "neuK.c", dir = LTR, text =
        """
            X
            X
            

        """
      }
    , { id = "", dir = RTL, text =
        """

        """
      }
    ]



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
    , syllabary = syllabaryPreset
    , normalizer = normalizer (normalization syllabaryPreset)
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
            let newSyllabary = completeSyllabary new
            in { model | syllabary = newSyllabary, normalizer = normalizer (normalization newSyllabary) }
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
                ( List.map syllabaryEntry (syllabaryList model.syllabary)
                ++ List.map specialEntry specialChars
                )
            ]

        syllabaryEntry (main, ext) =
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
                        indexed char
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
                        matchText = model.normalizer (String.filter indexed text)
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

                        allMatches = reverseMatches ++ map (\m -> (m.index, String.length m.match)) matches

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
                        map result matches ++ results

                results = List.foldr addMatches [] fragments

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
                            [ dt [] [ text "" ]
                            , dd [] [ text "Suche nach 
 (in-ŝu-ŝi-na-ak)" ]
                            , dt [] [ text "([^])\\1" ]
                            , dd [] [ text "suche nach Silbenwiederholungen wie " ]
                            , dt [] [ text "([^]).\\1" ]
                            , dd [] [ text "Silbenwiederholungen mit einem beliebigen Zeichen dazwischen ()" ]
                            , dt [] [ text "[^]+" ]
                            , dd [] [ text "\"Worte\" wenn wir den vertikalen Strich als Worttrenner annehmen" ]
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
                        indexed char
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
                , text " und "
                , a [ href "https://unicode.org" ] [ text "♥" ]
                , text ".  "
                , a [ href "fonts/Elamicon-Fonts.zip" ]
                    [ text "Elamicon-Schriften installieren."]
                , text " "
                , a [ href "https://github.com/sbalmer/elamicon/" ]
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
            ] ++ [ div [ dirAttr LTR ] (List.map fragmentView fragments) ]
              ++ [ footer ]
        )

