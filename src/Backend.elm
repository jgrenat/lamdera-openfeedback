module Backend exposing (..)

import Html
import Lamdera exposing (ClientId, SessionId, broadcast, onConnect, onDisconnect, sendToFrontend)
import Set exposing (Set)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.batch [ listenConnection, listenDisconnection ]
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { options =
            [ { label = "Drôle/original", votes = Set.empty }
            , { label = "Très enrichissant", votes = Set.empty }
            , { label = "Super intéressant", votes = Set.empty }
            , { label = "Très bon orateur", votes = Set.empty }
            , { label = "Pas clair", votes = Set.fromList [ "abcdef" ] }
            , { label = "J'aime les démos", votes = Set.empty }
            , { label = "Pas assez de démos", votes = Set.empty }
            , { label = "Pas assez technique", votes = Set.empty }
            ]
      , connectedUsers = Set.empty
      , comments = [ { content = "Bonjour, j'ai pas du tout aimé !" }, { content = "Moi je trouve ça plutôt cool !" } ]
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        UserConnected sessionId clientId ->
            ( { model | connectedUsers = Set.insert sessionId model.connectedUsers }
            , Cmd.batch
                [ sendOptionsToUser model.options sessionId
                , sendCommentsToUser model.comments sessionId
                ]
            )

        UserDisconnected sessionId _ ->
            ( { model | connectedUsers = Set.remove sessionId model.connectedUsers }, Cmd.none )


toFrontendOption : SessionId -> Option -> FrontendOption
toFrontendOption sessionId option =
    { label = option.label
    , votes = Set.size option.votes
    , hasVoted = Set.member sessionId option.votes
    }


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId _ msg model =
    case msg of
        VoteOption label ->
            let
                updatedOptions =
                    List.map
                        (\option ->
                            if option.label == label then
                                { option | votes = updateVotes sessionId option.votes }

                            else
                                option
                        )
                        model.options
            in
            ( { model | options = updatedOptions }
            , Set.toList model.connectedUsers
                |> List.map (sendOptionsToUser updatedOptions)
                |> Cmd.batch
            )


sendOptionsToUser : List Option -> SessionId -> Cmd BackendMsg
sendOptionsToUser options sessionId =
    List.map (toFrontendOption sessionId) options
        |> OptionsList
        |> sendToFrontend sessionId


sendCommentsToUser : List Comment -> SessionId -> Cmd BackendMsg
sendCommentsToUser comments sessionId =
    comments
        |> CommentsList
        |> sendToFrontend sessionId


updateVotes : SessionId -> Set Vote -> Set Vote
updateVotes sessionId votes =
    let
        hasVotedForOption =
            Set.member sessionId votes
    in
    if hasVotedForOption then
        Set.remove sessionId votes

    else
        Set.insert sessionId votes


listenConnection =
    onConnect UserConnected


listenDisconnection =
    onDisconnect UserDisconnected
