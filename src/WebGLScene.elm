module WebGLScene exposing (init, meshes, render, renderWithControls, renderWithRotation, updateAnimation)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Time
import Types exposing (..)
import WebGL exposing (Mesh, Shader, Entity)
import WebGL.Settings
import WebGL.Settings.DepthTest


-- Initialize meshes


meshes : SceneMeshes
meshes =
    { table = tableMesh
    , chair = chairMesh
    , ball = ballMesh
    , floor = floorMesh
    , walls = wallMeshes
    }


init : BallAnimation
init =
    { startPosition = vec3 -1.5 0.6 0
    , endPosition = vec3 1.5 0.6 0
    , duration = 3000
    , currentTime = 0
    , state = Playing
    }


-- Create meshes


tableMesh : Mesh Vertex
tableMesh =
    let
        brown = vec3 0.5 0.3 0.1

        -- Table top
        topVertices =
            [ -- Top face
              { position = vec3 -1 0.5 -0.5, color = brown, normal = vec3 0 1 0 }
            , { position = vec3 1 0.5 -0.5, color = brown, normal = vec3 0 1 0 }
            , { position = vec3 1 0.5 0.5, color = brown, normal = vec3 0 1 0 }
            , { position = vec3 -1 0.5 0.5, color = brown, normal = vec3 0 1 0 }
            ]

        -- Table legs
        legPositions =
            [ vec3 -0.9 0 -0.4
            , vec3 0.9 0 -0.4
            , vec3 0.9 0 0.4
            , vec3 -0.9 0 0.4
            ]
    in
    WebGL.triangles
        (tableTopQuad topVertices ++
         List.concatMap (tableLeg brown) legPositions)


tableTopQuad : List Vertex -> List (Vertex, Vertex, Vertex)
tableTopQuad vertices =
    case vertices of
        [v1, v2, v3, v4] ->
            [ (v1, v2, v3)
            , (v1, v3, v4)
            ]
        _ ->
            []


tableLeg : Vec3 -> Vec3 -> List (Vertex, Vertex, Vertex)
tableLeg color pos =
    let
        x = Vec3.getX pos
        y = Vec3.getY pos
        z = Vec3.getZ pos
        w = 0.05
    in
    box (vec3 (x - w) y (z - w)) (vec3 (x + w) 0.5 (z + w)) color


chairMesh : Mesh Vertex
chairMesh =
    let
        darkBrown = vec3 0.3 0.2 0.1

        -- Chair seat
        seatVertices =
            box (vec3 -0.3 0.25 -0.3) (vec3 0.3 0.3 0.3) darkBrown

        -- Chair back
        backVertices =
            box (vec3 -0.3 0.3 0.25) (vec3 0.3 0.7 0.3) darkBrown

        -- Chair legs
        legPositions =
            [ vec3 -0.25 0 -0.25
            , vec3 0.25 0 -0.25
            , vec3 0.25 0 0.25
            , vec3 -0.25 0 0.25
            ]

        legs =
            List.concatMap
                (\p ->
                    let
                        x = Vec3.getX p
                        z = Vec3.getZ p
                    in
                    box (vec3 (x - 0.03) 0 (z - 0.03)) (vec3 (x + 0.03) 0.25 (z + 0.03)) darkBrown
                )
                legPositions
    in
    WebGL.triangles (seatVertices ++ backVertices ++ legs)


ballMesh : Mesh Vertex
ballMesh =
    sphere 0.1 16 8 (vec3 1 0 0)


floorMesh : Mesh Vertex
floorMesh =
    let
        gray = vec3 0.7 0.7 0.7
    in
    WebGL.triangles (box (vec3 -3 -0.01 -3) (vec3 3 0 3) gray)


wallMeshes : List (Mesh Vertex)
wallMeshes =
    let
        lightGray = vec3 0.9 0.9 0.9

        -- Back wall
        backWall = WebGL.triangles (box (vec3 -3 0 -3) (vec3 3 2 -2.9) lightGray)

        -- Left wall
        leftWall = WebGL.triangles (box (vec3 -3 0 -3) (vec3 -2.9 2 3) lightGray)

        -- Right wall
        rightWall = WebGL.triangles (box (vec3 2.9 0 -3) (vec3 3 2 3) lightGray)
    in
    [ backWall, leftWall, rightWall ]


-- Helper functions for creating geometry


box : Vec3 -> Vec3 -> Vec3 -> List (Vertex, Vertex, Vertex)
box min max color =
    let
        x1 = Vec3.getX min
        y1 = Vec3.getY min
        z1 = Vec3.getZ min
        x2 = Vec3.getX max
        y2 = Vec3.getY max
        z2 = Vec3.getZ max

        vertices =
            -- Front face
            [ { position = vec3 x1 y1 z2, color = color, normal = vec3 0 0 1 }
            , { position = vec3 x2 y1 z2, color = color, normal = vec3 0 0 1 }
            , { position = vec3 x2 y2 z2, color = color, normal = vec3 0 0 1 }
            , { position = vec3 x1 y2 z2, color = color, normal = vec3 0 0 1 }

            -- Back face
            , { position = vec3 x2 y1 z1, color = color, normal = vec3 0 0 -1 }
            , { position = vec3 x1 y1 z1, color = color, normal = vec3 0 0 -1 }
            , { position = vec3 x1 y2 z1, color = color, normal = vec3 0 0 -1 }
            , { position = vec3 x2 y2 z1, color = color, normal = vec3 0 0 -1 }

            -- Top face
            , { position = vec3 x1 y2 z2, color = color, normal = vec3 0 1 0 }
            , { position = vec3 x2 y2 z2, color = color, normal = vec3 0 1 0 }
            , { position = vec3 x2 y2 z1, color = color, normal = vec3 0 1 0 }
            , { position = vec3 x1 y2 z1, color = color, normal = vec3 0 1 0 }

            -- Bottom face
            , { position = vec3 x1 y1 z1, color = color, normal = vec3 0 -1 0 }
            , { position = vec3 x2 y1 z1, color = color, normal = vec3 0 -1 0 }
            , { position = vec3 x2 y1 z2, color = color, normal = vec3 0 -1 0 }
            , { position = vec3 x1 y1 z2, color = color, normal = vec3 0 -1 0 }

            -- Right face
            , { position = vec3 x2 y1 z2, color = color, normal = vec3 1 0 0 }
            , { position = vec3 x2 y1 z1, color = color, normal = vec3 1 0 0 }
            , { position = vec3 x2 y2 z1, color = color, normal = vec3 1 0 0 }
            , { position = vec3 x2 y2 z2, color = color, normal = vec3 1 0 0 }

            -- Left face
            , { position = vec3 x1 y1 z1, color = color, normal = vec3 -1 0 0 }
            , { position = vec3 x1 y1 z2, color = color, normal = vec3 -1 0 0 }
            , { position = vec3 x1 y2 z2, color = color, normal = vec3 -1 0 0 }
            , { position = vec3 x1 y2 z1, color = color, normal = vec3 -1 0 0 }
            ]
    in
    [ -- Front
      (vertices |> List.drop 0 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 1 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 2 |> List.head |> Maybe.withDefault (dummyVertex))
    , (vertices |> List.drop 0 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 2 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 3 |> List.head |> Maybe.withDefault (dummyVertex))

    -- Back
    , (vertices |> List.drop 4 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 5 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 6 |> List.head |> Maybe.withDefault (dummyVertex))
    , (vertices |> List.drop 4 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 6 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 7 |> List.head |> Maybe.withDefault (dummyVertex))

    -- Top
    , (vertices |> List.drop 8 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 9 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 10 |> List.head |> Maybe.withDefault (dummyVertex))
    , (vertices |> List.drop 8 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 10 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 11 |> List.head |> Maybe.withDefault (dummyVertex))

    -- Bottom
    , (vertices |> List.drop 12 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 13 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 14 |> List.head |> Maybe.withDefault (dummyVertex))
    , (vertices |> List.drop 12 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 14 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 15 |> List.head |> Maybe.withDefault (dummyVertex))

    -- Right
    , (vertices |> List.drop 16 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 17 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 18 |> List.head |> Maybe.withDefault (dummyVertex))
    , (vertices |> List.drop 16 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 18 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 19 |> List.head |> Maybe.withDefault (dummyVertex))

    -- Left
    , (vertices |> List.drop 20 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 21 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 22 |> List.head |> Maybe.withDefault (dummyVertex))
    , (vertices |> List.drop 20 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 22 |> List.head |> Maybe.withDefault (dummyVertex),
       vertices |> List.drop 23 |> List.head |> Maybe.withDefault (dummyVertex))
    ]


dummyVertex : Vertex
dummyVertex =
    { position = vec3 0 0 0, color = vec3 0 0 0, normal = vec3 0 0 0 }


sphere : Float -> Int -> Int -> Vec3 -> Mesh Vertex
sphere radius stacks slices color =
    let
        vertices =
            List.concatMap (\stack ->
                List.map (\slice ->
                    let
                        theta = (toFloat stack / toFloat stacks) * pi
                        phi = (toFloat slice / toFloat slices) * 2 * pi
                        x = radius * sin theta * cos phi
                        y = radius * cos theta
                        z = radius * sin theta * sin phi
                        pos = vec3 x y z
                        normal = Vec3.normalize pos
                    in
                    { position = pos, color = color, normal = normal }
                ) (List.range 0 slices)
            ) (List.range 0 stacks)

        indices =
            List.concatMap (\stack ->
                List.concatMap (\slice ->
                    let
                        first = stack * (slices + 1) + slice
                        second = first + slices + 1
                    in
                    [ (first, second, first + 1)
                    , (second, second + 1, first + 1)
                    ]
                ) (List.range 0 (slices - 1))
            ) (List.range 0 (stacks - 1))

        getVertex i =
            vertices
                |> List.drop i
                |> List.head
                |> Maybe.withDefault dummyVertex

        triangles =
            List.map (\(i1, i2, i3) ->
                (getVertex i1, getVertex i2, getVertex i3)
            ) indices
    in
    WebGL.triangles triangles


-- Animation update


updateAnimation : Float -> BallAnimation -> BallAnimation
updateAnimation deltaTime animation =
    case animation.state of
        Playing ->
            let
                newTime = animation.currentTime + deltaTime
            in
            if newTime >= animation.duration then
                { animation
                    | currentTime = animation.duration
                    , state = Stopped
                }
            else
                { animation | currentTime = newTime }

        Stopped ->
            animation


getBallPosition : BallAnimation -> Vec3
getBallPosition animation =
    let
        t = animation.currentTime / animation.duration
        x = Vec3.getX animation.startPosition + (Vec3.getX animation.endPosition - Vec3.getX animation.startPosition) * t
        y = Vec3.getY animation.startPosition
        z = Vec3.getZ animation.startPosition
    in
    vec3 x y z


-- Rendering


render : Camera -> BallAnimation -> SceneMeshes -> List Entity
render camera animation sceneMeshes =
    let
        perspective =
            Mat4.makePerspective 45 (800 / 600) 0.01 100

        view =
            Mat4.makeLookAt camera.position camera.lookAt camera.up

        lightDir =
            vec3 0.5 -0.7 0.5

        -- Table at origin
        tableUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        -- Chair positioned to the side
        chairUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.makeTranslate (vec3 1.8 0 0)
            , lightDirection = lightDir
            }

        -- Ball with animation
        ballPosition = getBallPosition animation
        ballUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.makeTranslate ballPosition
            , lightDirection = lightDir
            }

        -- Floor
        floorUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        -- Walls
        wallUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        settings =
            [ WebGL.Settings.DepthTest.default ]
    in
    [ WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.floor floorUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.table tableUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.chair chairUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.ball ballUniforms
    ] ++ List.map (\wall ->
        WebGL.entityWith settings vertexShader fragmentShader wall wallUniforms
    ) sceneMeshes.walls


renderWithRotation : Camera -> BallAnimation -> SceneMeshes -> { x : Float, y : Float } -> List Entity
renderWithRotation camera animation sceneMeshes rotation =
    let
        -- Calculate camera position based on rotation
        radius = 5
        cameraX = radius * sin rotation.y * cos rotation.x
        cameraY = radius * sin rotation.x + 2
        cameraZ = radius * cos rotation.y * cos rotation.x

        rotatedCamera =
            { camera
                | position = vec3 cameraX cameraY cameraZ
            }

        perspective =
            Mat4.makePerspective 45 (800 / 600) 0.01 100

        view =
            Mat4.makeLookAt rotatedCamera.position rotatedCamera.lookAt rotatedCamera.up

        lightDir =
            vec3 0.5 -0.7 0.5

        -- Table at origin
        tableUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        -- Chair positioned to the side
        chairUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.makeTranslate (vec3 1.8 0 0)
            , lightDirection = lightDir
            }

        -- Ball with animation
        ballPosition = getBallPosition animation
        ballUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.makeTranslate ballPosition
            , lightDirection = lightDir
            }

        -- Floor
        floorUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        -- Walls
        wallUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        settings =
            [ WebGL.Settings.DepthTest.default ]
    in
    [ WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.floor floorUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.table tableUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.chair chairUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.ball ballUniforms
    ] ++ List.map (\wall ->
        WebGL.entityWith settings vertexShader fragmentShader wall wallUniforms
    ) sceneMeshes.walls


renderWithControls : Camera -> BallAnimation -> SceneMeshes -> { x : Float, y : Float } -> Float -> { x : Float, y : Float } -> List Entity
renderWithControls camera animation sceneMeshes rotation distance pan =
    let
        -- Calculate camera position based on rotation and distance
        cameraX = distance * sin rotation.y * cos rotation.x
        cameraY = distance * sin rotation.x + 2
        cameraZ = distance * cos rotation.y * cos rotation.x

        -- Calculate camera right and up vectors for proper panning
        cameraPos = vec3 cameraX cameraY cameraZ
        lookAtPoint = vec3 0 0.3 0

        -- Forward vector (from camera to lookAt)
        forward = Vec3.normalize (Vec3.sub lookAtPoint cameraPos)

        -- Right vector (perpendicular to forward and world up)
        right = Vec3.normalize (Vec3.cross forward (vec3 0 1 0))

        -- Up vector (perpendicular to forward and right)
        up = Vec3.normalize (Vec3.cross right forward)

        -- Apply panning in camera space
        panOffset =
            Vec3.add
                (Vec3.scale pan.x right)
                (Vec3.scale pan.y up)

        rotatedCamera =
            { camera
                | position = Vec3.add cameraPos panOffset
                , lookAt = Vec3.add lookAtPoint panOffset
            }

        perspective =
            Mat4.makePerspective 45 (800 / 600) 0.01 100

        view =
            Mat4.makeLookAt rotatedCamera.position rotatedCamera.lookAt rotatedCamera.up

        lightDir =
            vec3 0.5 -0.7 0.5

        -- Table at origin
        tableUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        -- Chair positioned to the side
        chairUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.makeTranslate (vec3 1.8 0 0)
            , lightDirection = lightDir
            }

        -- Ball with animation
        ballPosition = getBallPosition animation
        ballUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.makeTranslate ballPosition
            , lightDirection = lightDir
            }

        -- Floor
        floorUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        -- Walls
        wallUniforms =
            { perspective = perspective
            , view = view
            , model = Mat4.identity
            , lightDirection = lightDir
            }

        settings =
            [ WebGL.Settings.DepthTest.default ]
    in
    [ WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.floor floorUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.table tableUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.chair chairUniforms
    , WebGL.entityWith settings vertexShader fragmentShader sceneMeshes.ball ballUniforms
    ] ++ List.map (\wall ->
        WebGL.entityWith settings vertexShader fragmentShader wall wallUniforms
    ) sceneMeshes.walls


-- Shaders


vertexShader : Shader Vertex Uniforms { vColor : Vec3, vNormal : Vec3 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec3 color;
        attribute vec3 normal;

        uniform mat4 perspective;
        uniform mat4 view;
        uniform mat4 model;

        varying vec3 vColor;
        varying vec3 vNormal;

        void main() {
            gl_Position = perspective * view * model * vec4(position, 1.0);
            vColor = color;
            vNormal = mat3(model) * normal;
        }
    |]


fragmentShader : Shader {} Uniforms { vColor : Vec3, vNormal : Vec3 }
fragmentShader =
    [glsl|
        precision mediump float;

        uniform vec3 lightDirection;

        varying vec3 vColor;
        varying vec3 vNormal;

        void main() {
            vec3 normal = normalize(vNormal);
            vec3 lightDir = normalize(-lightDirection);

            float diff = max(dot(normal, lightDir), 0.0);
            vec3 ambient = 0.3 * vColor;
            vec3 diffuse = diff * vColor;

            gl_FragColor = vec4(ambient + diffuse, 1.0);
        }
    |]