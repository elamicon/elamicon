import Html exposing (..)
import Html.App as Html
import Html.Events exposing (on, onClick, targetValue)
import Html.Attributes exposing (..)
import Dict
import String
import Json.Decode
import List exposing (map)

letters =
    [ { char = '', syllable = [] }
    , { char = '', syllable = [ "na" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "uk ?" ] }
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
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "ú" ] }
    , { char = '', syllable = [ "ni ?" ] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [] }
    , { char = '', syllable = [ "piš ?" ] }
    , { char = '', syllable = [] }
    ]

alphabet = List.map .char letters
letterMap = Dict.fromList (List.map2 (,) alphabet letters)

grouping = List.map2 (,) alphabet (List.repeat (List.length alphabet) [])

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
type alias Model = { dir : Dir, selected : Maybe Pos, grouping : List (Char, List Char) , sandbox: String }
model = { dir = Original, selected = Nothing, grouping = grouping, sandbox = "" }

type Msg = Select (String, Int, Int) | SetDir Dir | SetSandbox String | AddChar String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetSandbox str -> { model | sandbox = str }
        AddChar char -> { model | sandbox = model.sandbox ++ char }
        Select pos -> { model | selected = Just pos }
        SetDir dir -> { model | dir = dir }


dirStr dir = case dir of
    LTR -> "LTR"
    _ -> "RTL"

dirDecoder : Json.Decode.Decoder Dir
dirDecoder = Html.Events.targetValue `Json.Decode.andThen` (\valStr -> case valStr of
    "Original" -> Json.Decode.succeed Original
    "LTR" -> Json.Decode.succeed LTR
    "RTL" -> Json.Decode.succeed RTL
    _ -> Json.Decode.fail ("dir " ++ valStr ++ "unknown"))


view : Model -> Html Msg
view model =
    let effectiveDir original = if model.dir == Original then original else model.dir
        dirAttr original = dir (dirStr (effectiveDir original))

        alphabet =
            [ h2 [] [ text "Die Buchstaben" ]
            , ol [ dirAttr LTR, classList [ ("alphabet", True), ("dir", True) ] ] (List.map alphabetEntry model.grouping)
            ]

        alphabetEntry (main, ext) =
            let
                info = Maybe.withDefault { char = '?', syllable = [] } (Dict.get main letterMap)
                syllableEntry = \syl -> div [ class "syl" ] [ text syl ]
            in
                li [ class "letter", onClick (AddChar (String.fromChar main)) ] (
                div [ class "elam" ] [ text (String.fromChar main) ]
                :: (map syllableEntry info.syllable))


        -- HACK horrid workaround to throw off the differ.
        -- otherwise the textarea is not updated (this way it is recreated)
        updateTextareaWorkaround = List.repeat (String.length model.sandbox) (textarea [ Html.Attributes.style [ ("display", "none") ] ] [])


        playground =
            [ h2 [] [ text "Spielplatz" ]
            ] ++ updateTextareaWorkaround ++
            [ textarea
                [ class "elam"
                , id "playground"
                , on "change" (Json.Decode.map SetSandbox Html.Events.targetValue)
                ] [ text model.sandbox ]
            ] ++ updateTextareaWorkaround


        settings =
            [ h2 [] [ text "Einstellungen" ]
            , label []
                [ text "Schreibrichtung"
                , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                    [ option [ value "Original" ] [ text "urpsrünglich ⇔" ]
                    , option [ value "LTR" ] [ text "von links ⇒ nach rechts" ]
                    , option [ value "RTL" ] [ text "nach links ⇐ von rechts" ]
                    ]
                ]
            ]

        fragmentView fragment =
            let fragmentLine nr line = li [ class "line", dirAttr fragment.dir ] [ span [ class "elam" ] [ text line ] ]
            in div [ class "plate" ]
                [ h3 [] [ text fragment.id ]
                , ol [ type' "I", dirAttr fragment.dir ] (List.indexedMap fragmentLine fragment.lines)
                ]
    in
        div []
            ([ style
            , h1 [] [ text "Elamische Zeichensammlung" ]
            ] ++ alphabet
              ++ playground
              ++ settings ++
            [ h2 [] [ text "Textfragmente" ]
            ] ++ (List.map fragmentView fragments))














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


.alphabet .letter {
    text-align: center;
    height: 10em;
    vertical-align: top;
}

.elam {
    line-height: 1em;
    font-size: 300%;
}

.plate {
    vertical-align: top;
    padding: 0 1em;
    display: inline-block;
}

.fragment {
    font-size: 200%;
    line-height: 1em;
    display: inline-block;
}

.line {
    unicode-bidi: bidi-override; /* not inherited through display: block */
    border-top: 0.1em solid black;
    border-bottom: 0.1em solid black;
    margin: -0.05em 0; /* collapse the borders */
    padding: 0 0.5em;
    cursor: pointer;
}

h2 {
    clear: both;
}

.alphabet {
    padding: 0;
    list-style-type: none;
}

.alphabet li {
    margin: 0.1em;
    display: inline-block;
}

.alphabet div {
    padding: 0.3em;

    color: rgba(100, 100, 100, 0.8);
    background-color: #ddd;
    text-shadow: #ddd 0.03ex 0.03ex 0.05ex, #000 0 0 0;
}

#playground {
    width: 100%;
    height: 5em;
    font-size: 200%;
}

#char-equiv {
    width: 100%;
    font-size: 150%;
}

.highlight-neighbor {
    background-color: #ffa;
}

.highlight {
    background-color: yellow;
}

.selected {
    margin: -1px;
    border: 1px dotted gray;
}
    "]