# Simulation

Physics engine built from the bottom up with nothing but OpenGL, Mach-GLFW 
(GLFW bindings for Zig), and whatever linear algerba library I choose, for the 
sole purpose of being used for GMU's PLUNGE Robotics team.

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
