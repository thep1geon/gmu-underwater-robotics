# Simulation

Physics engine built from the bottom up with only a few dependenices. 
- zopengl (OpenGL bindings and loader for Zig)
- zglfw (GLFW bindings for Zig)
- zui (Dear ImGUI bindings for Zig)
- Zalgebra (linear algebra library for Zig)
This project has the   sole purpose of being used for GMU's PLUNGE Robotics team. 
But making it a more general physics engine is part of the plan.

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

- [ ] Make renderer more complete
    - [x] Go 3D
        - [x] Camera stuff and all that jazz
    - [x] Finish Vertex type integration
        - [x] Vertex type
        - [x] Move from float arrays to Vertex Array
    - [ ] Get an obj importer working
    - [ ] Mesh type
    - [x] Texture type
    - [x] Add some gui (cImGui or zgui :shrug:)
- [ ] Some actual physics
    - [ ] General
        - [ ] Body type
            - [ ] Material type
            - [ ] Properties type
        - [ ] Bodies that obey the laws of physics
        - [ ] The idea of a scene (a collection of bodies that interact with eachother)
        - [ ] Collision handler
            - [ ] Cube-cube
            - [ ] Cube-sphere
            - [ ] Sphere-sphere
            - [ ] Cube-point
            - [ ] Sphere-point
    - [ ] Rigid Body
    - [ ] Softbody
        - [ ] Jelly truck
    - [ ] Cloth?
    - [ ] Slime?
    - [ ] Fluid?
- [ ] Maybes
    - [ ] Camera
        - [ ] Multiple cameras
            - [ ] Camera type
            - [ ] Camera manager
        - [ ] Camera is a physics body and interacts with the world
