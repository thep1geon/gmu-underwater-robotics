# GMU Underwater Robotics

The offical repo for all things underwater robotics for the GMU team.

## Contribution

If you are at all interested in contributing to the software side, don't hesistate 
to make a pull request or conact the software team. We're all learning together.

PLEASE adhere to the existing coding styles. Your change might not be accepted
if it does not adhere. Thanks :)

### Coding Styles

The coding style for the ROV will be discussed / voted on prior to any real work
being done.

## ROV
    
The meat and potatoes of this whole project. The specific coding language is still
being decided, but we are leaning towards Python.

The most important part of the ROV's code is to control the GPIO pins on the 
Raspberry pi. This can be accomplished in any language; so, if you have a language
suggestion, we'd love to hear it.

## Float

Will most likely be written in C, but this will be discussed later as well.

(More information will be coming eventually)

## Simulation

Hand crafted physics engine written in Zig with a few dependencies:

- OpenGL binding for Zig for the graphics
- Mach-GLFW for cross-platform windowing and input
- Zalgebra for linear algebra (basically glm for Zig)

:heart:

The purpose of the simulation is to test and pilot an ROV before fabrication 
makes a tangible ROV. This will also be helpful for prototyping and testing
if we don't have access to a pool.

# Info

We will not consider writing anything in Rust in Maverick's time as CSO.

Everything is subject to change at the discretion of the current CSO 
(Chief Software Officer) for the benefit of the team.

# LICENSE

Everything under the repo will be under the MIT license. Do what you want with
the code, just don't claim it as yours :)
