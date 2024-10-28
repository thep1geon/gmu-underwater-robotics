# Simulation

Physics engine built from the bottom up with nothing but OpenGL, Mach-GLFW 
(GLFW bindings for Zig), and Zalgebra for linear algebra, for the 
sole purpose of being used for GMU's PLUNGE Robotics team. But making it a more
general physics engine is part of the plan.

## Why

The main goal of this project is to program and test an ROV before actually 
having one.

### Why from scratch?

Building it from the bottom allows us (me) to have the most control over what
happens and what gets implemented. Using existing programs could make it difficult
to fit our needs.


### Why Zig?

Originally the project was started in C but after much thought (15 minutes), the
executive decision to rewrite what we had (a triangle) in Zig was made. Zig is
very similar to C with "a sane standard libary" and plenty of other user-friendly
features that C simply lacks. Portablity was also a concern. Zig offers the abilty
to cross-compile out of the box, while cross-compiling C is more difficult.

## TODO
Generalized roadmap to give this project some direction

Lowkey could turn this into a game engine at some point :blush:

[ ] Maybes
    [ ] Mulitple cameras / camera switcher
    [ ] Camera is a physics body and interacts with the world
[ ] Make renderer more complete
    [x] Go 3D
    [ ] Finish Vertex type integration
        [ ] Vertex type
        [ ] Move from float arrays to Vertex Array
    [ ] Get an obj importer working
    [ ] Mesh type
    [ ] Texture type
[ ] Some actual physics
    [ ] General
        [ ] Body type
        [ ] Bodies that obey the laws of physics
        [ ] Collision handler
            [ ] Cube-cube
            [ ] Cube-sphere
            [ ] Sphere-sphere
            [ ] Cube-point
            [ ] Sphere-point
    [ ] Rigid Body
    [ ] Softbody
        [ ] Jelly truck
    [ ] Cloth?
    [ ] Slime?
    [ ] Fluid?
