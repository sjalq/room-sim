module Types exposing (AdminPageModel, AdminRoute(..), AnimationState(..), BackendModel, BackendMsg(..), BallAnimation, BrowserCookie, Camera, ConnectionId, DragState(..), Email, EmailPasswordAuthMsg(..), EmailPasswordAuthResult(..), EmailPasswordAuthToBackend(..), EmailPasswordCredentials, EmailPasswordFormModel, EmailPasswordFormMsg(..), FrontendModel, FrontendMsg(..), LoginState(..), PollData, PollingStatus(..), PollingToken, Preferences, Role(..), Route(..), SceneMeshes, SceneObject, ToBackend(..), ToFrontend(..), Uniforms, User, UserFrontend, Vertex)

import Auth.Common
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Http
import Lamdera
import Json.Decode as Decode
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Time
import Url exposing (Url)
import WebGL exposing (Mesh, Shader)



{- Represents a currently connection to a Lamdera client -}


type alias ConnectionId =
    Lamdera.ClientId



{- Represents the browser cookie Lamdera uses to identify a browser -}


type alias BrowserCookie =
    Lamdera.SessionId


type Route
    = Default
    | Admin AdminRoute
    | Examples
    | NotFound


type AdminRoute
    = AdminDefault
    | AdminLogs
    | AdminFetchModel



-- | AdminFusion


type alias AdminPageModel =
    { logs : List String
    , isAuthenticated : Bool
    , remoteUrl : String
    }


type alias FrontendModel =
    { key : Key
    , currentRoute : Route
    , adminPage : AdminPageModel
    , authFlow : Auth.Common.Flow
    , authRedirectBaseUrl : Url
    , login : LoginState
    , currentUser : Maybe UserFrontend
    , pendingAuth : Bool

    -- , fusionState : Fusion.Value
    , preferences : Preferences
    , emailPasswordForm : EmailPasswordFormModel
    , profileDropdownOpen : Bool
    , loginModalOpen : Bool

    -- WebGL Scene fields
    , meshes : SceneMeshes
    , camera : Camera
    , ballAnimation : BallAnimation
    , animationTime : Float
    , dragState : DragState
    , cameraRotation : { x : Float, y : Float }
    , cameraDistance : Float
    , cameraPan : { x : Float, y : Float }
    }


type alias EmailPasswordFormModel =
    { email : String
    , password : String
    , confirmPassword : String
    , name : String
    , isSignupMode : Bool
    , error : Maybe String
    }


type alias BackendModel =
    { logs : List String
    , pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth
    , sessions : Dict Lamdera.SessionId Auth.Common.UserInfo
    , users : Dict Email User
    , emailPasswordCredentials : Dict Email EmailPasswordCredentials
    , pollingJobs : Dict PollingToken (PollingStatus PollData)
    }


type alias EmailPasswordCredentials =
    { email : String
    , passwordHash : String
    , passwordSalt : String
    , createdAt : Int
    }


type EmailPasswordAuthMsg
    = EmailPasswordFormMsg EmailPasswordFormMsg
    | EmailPasswordLoginRequested String String
    | EmailPasswordSignupRequested String String (Maybe String)


type EmailPasswordFormMsg
    = EmailPasswordFormEmailChanged String
    | EmailPasswordFormPasswordChanged String
    | EmailPasswordFormConfirmPasswordChanged String
    | EmailPasswordFormNameChanged String
    | EmailPasswordFormToggleMode
    | EmailPasswordFormSubmit


type EmailPasswordAuthToBackend
    = EmailPasswordLoginToBackend String String
    | EmailPasswordSignupToBackend String String (Maybe String)


type EmailPasswordAuthResult
    = EmailPasswordSignupWithHash BrowserCookie ConnectionId String String (Maybe String) String String


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | UrlRequested UrlRequest
    | NoOpFrontendMsg
    | DirectToBackend ToBackend
    | AnimationFrame Time.Posix
    | MouseDown Float Float Int
    | MouseMove Float Float
    | MouseUp
    | MouseWheel Float
      --- Admin
    | Admin_RemoteUrlChanged String
    | Auth0SigninRequested
    | EmailPasswordAuthMsg EmailPasswordAuthMsg
    | Logout
    | ToggleDarkMode
    | ToggleProfileDropdown
    | ToggleLoginModal
    | CloseLoginModal
    | EmailPasswordAuthError String
    | ConsoleLogClicked
    | ConsoleLogReceived String
    | CopyToClipboard String
    | ClipboardResult (Result String String)



--- Fusion
-- | Admin_FusionPatch Fusion.Patch.Patch
-- | Admin_FusionQuery Fusion.Query


type ToBackend
    = NoOpToBackend
    | A00_WebSocketReceive String
      -- Admin
    | Admin_FetchLogs
    | Admin_ClearLogs
    | Admin_FetchRemoteModel String
    | AuthToBackend Auth.Common.ToBackend
    | EmailPasswordAuthToBackend EmailPasswordAuthToBackend
    | GetUserToBackend
    | LoggedOut
    | SetDarkModePreference Bool



--- Fusion
-- | Fusion_PersistPatch Fusion.Patch.Patch
-- | Fusion_Query Fusion.Query


type BackendMsg
    = NoOpBackendMsg
    | Log String
    | GotRemoteModel (Result Http.Error BackendModel)
    | AuthBackendMsg Auth.Common.BackendMsg
    | EmailPasswordAuthResult EmailPasswordAuthResult
    | GotJobTime PollingToken Int
      -- example to show polling mechanism
    | GotCryptoPriceResult PollingToken (Result Http.Error String)
    | StoreTaskResult PollingToken (Result String String)


type ToFrontend
    = NoOpToFrontend
    | A00_WebSocketSend String
      -- Admin page
    | Admin_Logs_ToFrontend (List String)
    | AuthToFrontend Auth.Common.ToFrontend
    | AuthSuccess Auth.Common.UserInfo
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
    | UserDataToFrontend UserFrontend
    | PermissionDenied ToBackend



-- | Admin_FusionResponse Fusion.Value


type alias Email =
    String


type alias User =
    { email : Email
    , name : Maybe String
    , preferences : Preferences
    }


type alias UserFrontend =
    { email : Email
    , isSysAdmin : Bool
    , role : String
    , preferences : Preferences
    }


type LoginState
    = JustArrived
    | NotLogged Bool
    | LoginTokenSent
    | LoggedIn Auth.Common.UserInfo



-- Role types


type Role
    = SysAdmin
    | UserRole
    | Anonymous



-- Polling types


type alias PollingToken =
    String


type PollingStatus a
    = Busy
    | BusyWithTime Int
    | Ready (Result String a)


type alias PollData =
    String



-- USER RELATED TYPES


type alias Preferences =
    { darkMode : Bool
    }


-- WebGL Types


type alias Vertex =
    { position : Vec3
    , color : Vec3
    , normal : Vec3
    }


type alias Uniforms =
    { perspective : Mat4
    , view : Mat4
    , model : Mat4
    , lightDirection : Vec3
    }


type alias SceneMeshes =
    { table : Mesh Vertex
    , chair : Mesh Vertex
    , ball : Mesh Vertex
    , floor : Mesh Vertex
    , walls : List (Mesh Vertex)
    }


type alias Camera =
    { position : Vec3
    , lookAt : Vec3
    , up : Vec3
    }


type alias SceneObject =
    { mesh : Mesh Vertex
    , position : Vec3
    , rotation : Vec3
    , scale : Vec3
    , color : Vec3
    }


type AnimationState
    = Playing
    | Stopped


type DragState
    = NotDragging
    | Rotating { startX : Float, startY : Float, currentX : Float, currentY : Float }
    | Panning { startX : Float, startY : Float, currentX : Float, currentY : Float }


type alias BallAnimation =
    { startPosition : Vec3
    , endPosition : Vec3
    , duration : Float
    , currentTime : Float
    , state : AnimationState
    }
