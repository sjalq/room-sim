# ⚠️ START HERE - Essential Information Before Continuing

## Critical Context for Future Development Sessions

### What This Project Is
- **Room Sim**: A 3D WebGL room simulation in Elm/Lamdera
- **Repository**: https://github.com/sjalq/room-sim
- **Status**: Functional with basic features implemented

### Current State (as of last session)
✅ **Working Features**:
- 3D room with furniture rendering
- Full camera controls (orbit, pan, zoom)
- Ball animation across table
- Pure Elm implementation (no ports)

⚠️ **Important Notes**:
- This is NOT the starter-project - it's a separate repository
- Lamdera live was stopped at end of last session
- All changes have been committed and pushed to GitHub

### Before You Start Coding

1. **Read the full summary**: `/docs/PROJECT_SUMMARY.md` contains detailed information about:
   - All implemented features
   - Bug fixes and solutions
   - Project structure
   - Future development ideas

2. **Check current directory**:
   ```bash
   pwd  # Should be /home/schalk/git/room
   ```

3. **Verify git status**:
   ```bash
   git status  # Should be clean
   git remote -v  # Should point to room-sim repo
   ```

4. **Start Lamdera**:
   ```bash
   lamdera live
   ```
   Then visit http://localhost:8000

### Key Technical Details

**Camera Controls**:
- Left drag = Rotate
- Right drag = Pan (camera-relative)
- Scroll = Zoom
- All controls properly implemented with correct math

**File Structure**:
- `src/WebGLScene.elm` - All 3D rendering
- `src/Types.elm` - Type definitions
- `src/Frontend.elm` - Event handling
- `src/Pages/Default.elm` - UI rendering

**Dependencies Added**:
- elm-explorations/webgl: 1.1.3
- elm-explorations/linear-algebra: 1.0.3

### Common Tasks

**Add new 3D object**:
1. Create mesh function in WebGLScene.elm
2. Add to SceneMeshes type
3. Include in render function

**Modify camera behavior**:
- Camera logic is in Frontend.elm (update function)
- Rendering with camera is in WebGLScene.elm (renderWithControls)

**Load external models**:
- See PROJECT_SUMMARY.md section on "Loading 3D Models"
- JSON approach recommended

### Gotchas to Remember

1. **Subscriptions**: Must use actual `subscriptions` function, not `always Sub.none`
2. **Panning**: Must be camera-relative using cross products
3. **Zoom sensitivity**: Keep at 0.001 for smooth scrolling
4. **Prevent scroll**: WebGL canvas needs `preventDefaultOn "wheel"`

### Next Logical Steps

Consider implementing (in order of complexity):
1. Pause/reset ball animation
2. Add more furniture objects
3. JSON model loader
4. Texture support
5. Scene save/load
6. Touch controls for mobile

---

**Remember**: This is a working project. Test changes frequently with `lamdera live` and commit working states often!

*Created: September 28, 2025*
*Purpose: Quick reference for continuing development*