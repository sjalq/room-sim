module Pages.Default exposing (..)

import Components.Button
import Components.Header
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode
import Theme
import Types exposing (..)
import WebGL
import WebGLScene


init : FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
init model =
    ( model, Cmd.none )


view : FrontendModel -> Theme.Colors -> Html FrontendMsg
view model colors =
    div [ Attr.style "background-color" colors.primaryBg, Attr.class "min-h-screen" ]
        [ div [ Attr.class "container mx-auto px-4 md:px-6 py-4 md:py-8" ]
            [ Components.Header.pageHeader colors "Room Sim" Nothing
            , div [ Attr.class "mt-4 text-center text-sm", Attr.style "color" colors.secondaryText ]
                [ text "🖱️ Left Click + Drag: Rotate | Right Click + Drag: Pan | Scroll: Zoom"
                ]
            , div [ Attr.class "mt-4 md:mt-6 text-center" ]
                [ WebGL.toHtml
                    [ Attr.width 800
                    , Attr.height 600
                    , Attr.style "border" "2px solid #333"
                    , Attr.style "box-shadow" "0 4px 6px rgba(0, 0, 0, 0.1)"
                    , Attr.style "cursor" (getCursorStyle model.dragState)
                    , Events.on "mousedown" mouseDownDecoder
                    , Events.preventDefaultOn "wheel" (Decode.map (\msg -> (msg, True)) wheelDecoder)
                    , Events.preventDefaultOn "contextmenu" (Decode.succeed (NoOpFrontendMsg, True))
                    ]
                    (WebGLScene.renderWithControls model.camera model.ballAnimation model.meshes
                        model.cameraRotation model.cameraDistance model.cameraPan)
                ]
            ]
        ]


getCursorStyle : DragState -> String
getCursorStyle dragState =
    case dragState of
        NotDragging ->
            "grab"
        Rotating _ ->
            "grabbing"
        Panning _ ->
            "move"


mouseDownDecoder : Decode.Decoder FrontendMsg
mouseDownDecoder =
    Decode.map3 MouseDown
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)
        (Decode.field "button" Decode.int)


wheelDecoder : Decode.Decoder FrontendMsg
wheelDecoder =
    Decode.map MouseWheel
        (Decode.field "deltaY" Decode.float)
