#include <stdio.h>

#include <GLFW/glfw3.h>
#include <GL/gl.h>

int main(void) {
    GLFWwindow* window;

    if (!glfwInit()) {
        return 1;
    }

    window = glfwCreateWindow(540, 540, "Simulation", 0, 0);
    if (!window) {
        glfwTerminate();
        return 1;
    }

    glfwMakeContextCurrent(window);

    glClearColor(0.5, 0.f, 0.5, 1.f);
    while (!glfwWindowShouldClose(window)) {
        glClear(0);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}
