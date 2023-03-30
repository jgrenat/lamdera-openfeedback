module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, button, div, h1, h2, li, p, text, ul)
import Html.Attributes exposing (class, href, rel, style)
import Html.Events exposing (onClick)
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , options = []
      , comments = []
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        SendVote label ->
            ( model, sendToBackend (VoteOption label) )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        OptionsList options ->
            ( { model | options = options }, Cmd.none )

        CommentsList comments ->
            ( { model | comments = comments }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.node "link" [ rel "stylesheet", href "/style.css" ] []
        , h1 [] [ text "OpenFeedback Clone" ]
        , div []
            [ ul [ class "options" ] (List.map viewOption model.options)
            ]
        , viewComments model
        ]
    }


viewOption : FrontendOption -> Html FrontendMsg
viewOption option =
    let
        votes =
            String.fromInt option.votes
    in
    li []
        [ button
            [ onClick (SendVote option.label)
            , class
                (if option.hasVoted then
                    "option--selected"

                 else
                    ""
                )
            ]
            [ text (option.label ++ " (" ++ votes ++ ")") ]
        ]


viewComments : Model -> Html FrontendMsg
viewComments model =
    div []
        [ h2 [] [ text "Comments" ]
        , ul [ class "comments" ]
            (List.map viewComment model.comments)
        ]


viewComment : Comment -> Html FrontendMsg
viewComment comment =
    li []
        [ div [ class "author" ] [ text "Jordane" ]
        , p [] [ text comment.content ]
        ]
