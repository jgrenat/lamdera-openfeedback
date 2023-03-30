module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Url exposing (Url)


type alias Comment =
    { content : String
    }


type alias FrontendModel =
    { key : Key
    , options : List FrontendOption
    , comments : List Comment
    }


type alias Vote =
    SessionId


type alias Option =
    { label : String, votes : Set Vote }


type alias FrontendOption =
    { label : String, votes : Int, hasVoted : Bool }


type alias BackendModel =
    { options : List Option
    , connectedUsers : Set SessionId
    , comments : List Comment
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | SendVote String


type ToBackend
    = VoteOption String


type BackendMsg
    = UserConnected SessionId ClientId
    | UserDisconnected SessionId ClientId


type ToFrontend
    = OptionsList (List FrontendOption)
    | CommentsList (List Comment)
