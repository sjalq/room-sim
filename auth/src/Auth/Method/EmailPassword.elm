module Auth.Method.EmailPassword exposing (..)

import Auth.Common exposing (..)
import Browser.Navigation exposing (Key)
import Task exposing (Task)
import Time
import Url exposing (Url)
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query


type alias LoginCredentials =
    { email : String
    , password : String
    }


type alias SignupCredentials =
    { email : String
    , password : String
    , name : Maybe String
    }


configuration :
    { initiateSignin :
        SessionId
        -> ClientId
        -> backendModel
        -> LoginCredentials
        -> Time.Posix
        -> ( backendModel, Cmd backendMsg )
    , initiateSignup :
        SessionId
        -> ClientId
        -> backendModel
        -> SignupCredentials
        -> Time.Posix
        -> ( backendModel, Cmd backendMsg )
    , onAuthCallbackReceived :
        SessionId
        -> ClientId
        -> Url
        -> AuthCode
        -> State
        -> Time.Posix
        -> (BackendMsg -> backendMsg)
        -> backendModel
        -> ( backendModel, Cmd backendMsg )
    }
    ->
        Method
            frontendMsg
            backendMsg
            { frontendModel | authFlow : Flow, authRedirectBaseUrl : Url }
            backendModel
configuration { initiateSignin, initiateSignup, onAuthCallbackReceived } =
    ProtocolEmailMagicLink
        { id = "EmailPassword"
        , initiateSignin =
            \sessionId clientId backendModel { username } time ->
                case username of
                    Just emailWithPassword ->
                        case String.split "::" emailWithPassword of
                            [ email, password ] ->
                                initiateSignin sessionId clientId backendModel { email = email, password = password } time

                            _ ->
                                ( backendModel, Cmd.none )

                    Nothing ->
                        ( backendModel, Cmd.none )
        , onFrontendCallbackInit = onFrontendCallbackInit
        , onAuthCallbackReceived = onAuthCallbackReceived
        , placeholder = \frontendMsg backendMsg frontendModel backendModel -> ()
        }


onFrontendCallbackInit frontendModel methodId origin key toBackend =
    case origin |> Url.Parser.parse (callbackUrl methodId <?> queryParams) of
        Just ( Just token, Just email ) ->
            ( { frontendModel | authFlow = Auth.Common.Pending }
            , toBackend <| Auth.Common.AuthCallbackReceived methodId origin token email
            )

        _ ->
            ( { frontendModel | authFlow = Errored <| ErrAuthString "Authentication failed. Please try again." }
            , Cmd.none
            )


callbackUrl methodId =
    Url.Parser.s "login" </> Url.Parser.s methodId </> Url.Parser.s "callback"


queryParams =
    Query.map2 Tuple.pair (Query.string "token") (Query.string "email")
