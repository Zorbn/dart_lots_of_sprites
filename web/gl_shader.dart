import 'dart:web_gl';

class GlShader {
  final Program _shaderProgram;

  int aPositionLoc;
  int aTexCoordLoc;

  GlShader(RenderingContext gl, String name, String vertCode, String fragCode)
      : _shaderProgram = gl.createProgram(),
        aPositionLoc = 0,
        aTexCoordLoc = 0 {
    // Create and compile the vertex shader.
    var vertShader = gl.createShader(WebGL.VERTEX_SHADER);
    gl.shaderSource(vertShader, vertCode);
    gl.compileShader(vertShader);

    // Print compilation info, will show errors if there are any.
    print(
        "INFO: Compiling $name's vertex shader...\n${gl.getShaderInfoLog(vertShader)}");

    // Repeat for the fragment shader.
    var fragShader = gl.createShader(WebGL.FRAGMENT_SHADER);
    gl.shaderSource(fragShader, fragCode);
    gl.compileShader(fragShader);

    print(
        "INFO: Compiling $name's fragment shader...\n${gl.getShaderInfoLog(fragShader)}");

    // Create a single shader program, made up of a vertex and fragment shader.
    gl.attachShader(_shaderProgram, vertShader);
    gl.attachShader(_shaderProgram, fragShader);
    gl.linkProgram(_shaderProgram);

    // Store the location of a_position
    aPositionLoc = gl.getAttribLocation(_shaderProgram, "a_position");
    gl.enableVertexAttribArray(aPositionLoc);

    // Store the location of a_texCoord
    aTexCoordLoc = gl.getAttribLocation(_shaderProgram, "a_texCoord");
    gl.enableVertexAttribArray(aTexCoordLoc);
  }

  // Wrapper causing the context to begin using this shader.
  void use(RenderingContext gl) {
    gl.useProgram(_shaderProgram);
  }
}
