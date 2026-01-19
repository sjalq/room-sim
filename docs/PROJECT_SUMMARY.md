# Room Sim - Project Summary & Development Notes

## ⚠️ READ THIS BEFORE CONTINUING DEVELOPMENT

This document summarizes the entire development session, features implemented, and important discoveries made during the creation of the Room Sim project.

---

## Project Overview

**Room Sim** is an interactive 3D WebGL room simulation built with Elm and Lamdera. It features a fully functional 3D scene with camera controls, rendered entirely in the browser using pure functional programming without JavaScript ports.

### Repository Information
- **GitHub URL**: https://github.com/sjalq/room-sim
- **Based on**: Lamdera starter-project template
- **Created**: September 28, 2025
- **Primary Language**: Elm with WebGL

---

## Features Implemented

### 1. 3D Scene Components
- **Room**: Gray floor with three light gray walls (back, left, right)
- **Furniture**:
  - Brown wooden table (center of room)
  - Dark brown chair (positioned to the side at x=1.8)
  - Red ball that animates across the table
- **Lighting**: Basic ambient (0.3) and directional lighting system
- **Animation**: Ball rolls from left (-1.5) to right (1.5) across table over 3 seconds

### 2. Camera Controls (Industry Standard)
- **Left Click + Drag**: Orbit/rotate camera around the scene
- **Right Click + Drag**: Pan camera (view-relative, properly calculated)
- **Scroll Wheel**: Zoom in/out (distance range: 2-20 units)
- **Visual Feedback**:
  - Cursor changes to "grab" hand when hovering
  - "grabbing" when rotating
  - "move" cursor when panning

### 3. Technical Implementation
- **Pure Elm/WebGL**: No JavaScript ports used
- **Custom Geometry Generation**: All meshes created procedurally in Elm
- **Vertex/Fragment Shaders**: GLSL shaders embedded in Elm
- **Proper Matrix Transformations**: Camera, perspective, and model matrices
- **Camera-Relative Panning**: Calculates right and up vectors based on current view

---

## Project Structure

### Key Files Created/Modified

1. **src/WebGLScene.elm** (NEW - 560+ lines)
   - Contains all 3D rendering logic
   - Mesh generation functions (box, sphere, table, chair, ball)
   - Render functions with camera controls
   - GLSL vertex and fragment shaders

2. **src/Types.elm** (MODIFIED)
   - Added WebGL types: `Vertex`, `Uniforms`, `SceneMeshes`, `Camera`
   - Added drag state types: `DragState`, `AnimationState`, `BallAnimation`
   - Added camera control fields to `FrontendModel`

3. **src/Frontend.elm** (MODIFIED)
   - Mouse event handlers (MouseDown, MouseMove, MouseUp, MouseWheel)
   - Subscription management for drag states
   - Animation frame updates
   - Camera transformation calculations

4. **src/Pages/Default.elm** (MODIFIED)
   - WebGL canvas rendering
   - Mouse event decoders
   - Control instructions display
   - Title changed to "Room Sim"

5. **elm.json** (MODIFIED)
   - Added dependencies:
     - `elm-explorations/webgl: 1.1.3`
     - `elm-explorations/linear-algebra: 1.0.3`

---

## Important Discoveries & Fixes

### 1. Subscription Bug Fix
**Problem**: Mouse drag events weren't being captured
**Cause**: The `app` function was using `always Sub.none` instead of the actual `subscriptions` function
**Solution**: Changed to use proper subscriptions function, enabling animation and drag events

### 2. Camera-Relative Panning
**Problem**: Panning moved in world space, not relative to camera view
**Solution**: Calculate camera's right and up vectors using cross products:
```elm
forward = Vec3.normalize (Vec3.sub lookAtPoint cameraPos)
right = Vec3.normalize (Vec3.cross forward (vec3 0 1 0))
up = Vec3.normalize (Vec3.cross right forward)
```

### 3. Zoom Sensitivity
**Problem**: Mouse wheel zoom was too jumpy
**Solution**: Reduced zoom speed from 0.1 to 0.001 (100x slower)

### 4. Page Scroll Prevention
**Problem**: Page would scroll when using mouse wheel over canvas
**Solution**: Used `Events.preventDefaultOn "wheel"` to prevent default scroll behavior

### 5. Panning Direction
**Problem**: Panning felt unnatural
**Solution**: Inverted both X and Y axes for "grab and drag" feel

---

## Git History & Repository Management

### Important Note on Repository Creation
1. Initially, changes were mistakenly pushed to the starter-project template
2. Reverted those changes using `git push origin 96ab404:master --force-with-lease`
3. Created new repository `room-sim` with fresh git history
4. Removed unrelated file (kirk-incident-rifle-timeline.md) that appeared in directory

### Current Git Status
- Repository properly initialized as standalone project
- All WebGL features committed with descriptive message
- Clean separation from starter-project template

---

## Future Development Ideas Discussed

### 1. Loading 3D Models
Several approaches were explored for loading external 3D models:

#### Direct Loading Options:
- **Runtime OBJ Parser**: Parse OBJ files directly in Elm
- **JSON Model Format**: Convert models to JSON, load via HTTP
- **GLTF Loader**: More complex but industry standard
- **Custom Format**: Simple text-based format for easy parsing

#### Recommended Approach:
JSON-based format with HTTP loading for best balance of simplicity and performance

### 2. Google Earth Data Integration
Discussed methods for importing real-world 3D data:

#### Photogrammetry Pipeline:
1. Google Earth Studio for screenshots
2. Process through Meshroom/COLMAP
3. Simplify in Blender
4. Convert to Elm vertex arrays

#### Alternative Data Sources:
- Google Maps Elevation API for terrain
- OpenStreetMap building footprints
- Google's Photorealistic 3D Tiles API (new)

### 3. Asset Placement System
Conceptualized a system for placing 3D assets:
- Scene item records with position/rotation/scale
- Grid snapping for precise placement
- Save/load scene layouts as JSON
- Visual placement mode with click-to-place

---

## Development Environment

### Requirements
- **Lamdera**: For running the project (`lamdera live`)
- **Elm**: 0.19.1
- **Browser**: Modern browser with WebGL support
- **Port**: Default runs on http://localhost:8000

### Commands
```bash
# Run locally
lamdera live

# Compile
lamdera make src/Frontend.elm

# Git operations
git add -A
git commit -m "message"
git push origin main
```

---

## Known Issues & Limitations

1. **Ball Animation**: Runs continuously, no pause/reset controls
2. **Mobile Support**: Controls are desktop-only (mouse/keyboard)
3. **Performance**: No LOD system for complex scenes
4. **Model Loading**: Currently all geometry is hardcoded
5. **Textures**: Using solid colors only, no texture mapping

---

## Next Steps for Development

1. **Add Model Loading**: Implement JSON model loader
2. **Texture Support**: Add UV mapping and texture loading
3. **Mobile Controls**: Touch gestures for phone/tablet
4. **Scene Editor**: GUI for placing/rotating objects
5. **Save/Load**: Persist scene configurations
6. **Physics**: Basic collision detection
7. **Shadows**: Implement shadow mapping

---

## Important Code Patterns

### Adding New Objects
1. Create mesh generation function in WebGLScene.elm
2. Add to SceneMeshes type in Types.elm
3. Include in render function with appropriate uniforms

### Adding New Controls
1. Add message type to FrontendMsg in Types.elm
2. Create decoder in Pages/Default.elm
3. Handle in update function in Frontend.elm
4. Update subscriptions if needed

---

## Contact & Collaboration

This project was developed with assistance from Claude (Anthropic) and represents a functional example of:
- Pure functional 3D graphics
- Elm's WebGL capabilities
- Camera control implementation
- Lamdera project structure

For questions or contributions, please refer to the GitHub repository.

---

*Last Updated: September 28, 2025*
*Document Created: End of initial development session*