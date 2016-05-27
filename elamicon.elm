import Html exposing (Html, h1, h2, div, text, ol, ul, li, node)
import Html.App as Html
import Html.Events exposing (onClick)
import Html.Attributes as Attrs exposing (class, classList, href)
import Dict
import String
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
        [ ""
        , ""
        ]
      }
    , { id = "B", dir = LTR, lines =
        [ ""
        , ""
        ]
      }
    ]

main = Html.beginnerProgram { model = model, view = view, update = update }

type alias Pos = (String, Int, Int)
type alias Model = { dir : Dir, selected : Maybe Pos, grouping : List (Char, List Char) }
model = { dir = Original, selected = Nothing, grouping = grouping }

type Msg = Select (String, Int, Int)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Select pos ->
            { model | selected = Just pos }


effectiveDir original selected = if selected == Original then original else selected
dirStr dir = case dir of
    LTR -> "LTR"
    _ -> "RTL"
dirAttr original selected = Attrs.dir (dirStr (effectiveDir original selected))



view : Model -> Html Msg
view model =
    div []
    [ style
    , h1 [] [ text "Elamische Zeichensammlung" ]
    , h2 [] [ text "Die Buchstaben" ]
    , ol [ dirAttr LTR model.dir, classList [ ("alphabet", True), ("dir", True) ] ] (List.map alphabetEntry model.grouping)
    , h1 [] [ text "Textfragmente" ]
    , ul [] (List.map fragmentView fragments)
    ]

alphabetEntry : (Char, List Char) -> Html.Html a
alphabetEntry (main, ext) =
    let
        info = Maybe.withDefault { char = '?', syllable = [] } (Dict.get main letterMap)
        syllableEntry = \syl -> div [ class "syl" ] [ text syl ]
    in
        li [ class "letter" ] (
        div [ class "elam" ] [ text (String.fromChar main) ]
        :: (map syllableEntry info.syllable))

fragmentView fragment = li []
    [ text fragment.id
    , ol [ Attrs.type' "I" ] (List.indexedMap fragmentLine fragment.lines)
    ]
fragmentLine nr line = li [ class "elam" ] [ text line ]














style = Html.node "style" [Attrs.type' "text/css"]
    [ Html.text "
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
    display: block;
    unicode-bidi: bidi-override; /* not inherited through display: block */
    border-top: 0.05em solid black;
    border-bottom: 0.05em solid black;
    margin: -0.025em 0; /* collapse the borders */
    padding: 0;
    cursor: pointer;
}

.rtl { direction: rtl; }
.ltr { direction: ltr; }
.rtl-override { direction: rtl; }
.ltr-override { direction: ltr; }

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