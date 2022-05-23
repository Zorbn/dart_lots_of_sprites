import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

void main() {
  // Setup canvas and webGL context.
  var canvas = querySelector('#canvas') as CanvasElement;
  var gl = canvas.getContext3d()!;

  canvas.width = 570;
  canvas.height = 570;

  /*
   * Data buffers.
   */

  // Create vertex data.
  var vertices = Float32List.fromList([
    -0.5, 0.5, 0.0, //  Quad top left.
    -0.5, -0.5, 0.0, // Quad bottom left.
    0.5, -0.5, 0.0, //  Quad bottom right.
    0.5, 0.5, 0.0, //   Quad top right.
  ]);

  // Create a vertex buffer and assign the vertex data to it.
  var vertexBuffer = gl.createBuffer();
  gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
  gl.bufferData(WebGL.ARRAY_BUFFER, vertices, WebGL.STATIC_DRAW);
  gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

  // Create index data.
  var indices = Uint16List.fromList([3, 2, 1, 3, 1, 0]);

  // Create an index buffer and assign the index data to it.
  var indexBuffer = gl.createBuffer();
  gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, indices, WebGL.STATIC_DRAW);
  gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);

  // Create texture coordinate data.
  var texCoords = Float32List.fromList([
    0.0, 0.0, //   Texture top left.
    0.0, 1.0, //   Texture bottom left.
    1, 1.0, //     Texture bottom right.
    1.0, 0.0 //    Texture top-right.
  ]);

  // Create a texture coordinate buffer and assign the data to it.
  var texCoordBuffer = gl.createBuffer();
  gl.bindBuffer(WebGL.ARRAY_BUFFER, texCoordBuffer);
  gl.bufferData(WebGL.ARRAY_BUFFER, texCoords, WebGL.STATIC_DRAW);
  gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

  /*
   * Vertex and fragment shaders.
   */

  // A simple vertex shader.
  var vertCode = '''
      attribute vec3 a_position;
      attribute vec2 a_texCoord;
      varying vec2 v_texCoord;
      void main(void) {
       gl_Position = vec4(a_position, 1.0);
       v_texCoord = a_texCoord;
      }
      ''';

  // Create and compile the shader from the above code.
  var vertShader = gl.createShader(WebGL.VERTEX_SHADER);
  gl.shaderSource(vertShader, vertCode);
  gl.compileShader(vertShader);

  print("Compiling vertex shader...\n${gl.getShaderInfoLog(vertShader)}");

  // A simple fragment shader.
  var fragCode = '''
      precision mediump float;

      varying vec2 v_texCoord;
      uniform sampler2D u_texture;
      void main(void) {
       gl_FragColor = texture2D(u_texture, v_texCoord);
      }
      ''';

  // Create and compile the shader from the above code.
  var fragShader = gl.createShader(WebGL.FRAGMENT_SHADER);
  gl.shaderSource(fragShader, fragCode);
  gl.compileShader(fragShader);

  print("Compiling fragment shader...\n${gl.getShaderInfoLog(fragShader)}");

  // Create a single shader program, made up of a vertex and fragment shader.
  var shaderProgram = gl.createProgram();
  gl.attachShader(shaderProgram, vertShader);
  gl.attachShader(shaderProgram, fragShader);
  gl.linkProgram(shaderProgram);
  // Use this shader program for rendering.
  gl.useProgram(shaderProgram);

  /*
   * Assign buffers to vertex shader attributes.
   */

  // Get the location of a_position
  var aPositionLoc = gl.getAttribLocation(shaderProgram, "a_position");
  gl.enableVertexAttribArray(aPositionLoc);
  // Make vertexBuffer the bound ARRAY_BUFFER.
  gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
  // Bind current ARRAY_BUFFER to aPositionLoc.
  gl.vertexAttribPointer(aPositionLoc, 3, WebGL.FLOAT, false, 0, 0);

  // Get the location of a_texCoord
  var aTexCoordLoc = gl.getAttribLocation(shaderProgram, "a_texCoord");
  gl.enableVertexAttribArray(aTexCoordLoc);
  // Make texCoordBuffer the bound ARRAY_BUFFER.
  gl.bindBuffer(WebGL.ARRAY_BUFFER, texCoordBuffer);
  // Bind current ARRAY_BUFFER to aTexCoordLoc
  gl.vertexAttribPointer(aTexCoordLoc, 2, WebGL.FLOAT, false, 0, 0);

  /*
   * Setup a texture.
   */

  final texture = gl.createTexture();

  // In webGL, textures can be loaded as image elements.
  final element = ImageElement();

  // Wait until the texture is loaded to continue.
  element.onLoad.listen((event) {
    gl.bindTexture(WebGL.TEXTURE_2D, texture);

    // Assign image to the texture.
    gl.texImage2D(
      WebGL.TEXTURE_2D,
      0,
      WebGL.RGBA,
      WebGL.RGBA,
      WebGL.UNSIGNED_BYTE,
      element,
    );

    // Use "nearest" filter, meaning the texture will not be smoothed.
    gl.texParameteri(
      WebGL.TEXTURE_2D,
      WebGL.TEXTURE_MAG_FILTER,
      WebGL.NEAREST,
    );
    gl.texParameteri(
      WebGL.TEXTURE_2D,
      WebGL.TEXTURE_MIN_FILTER,
      WebGL.NEAREST,
    );

    gl.bindTexture(WebGL.TEXTURE_2D, null);

    // Activate texture 0, bind the previously loaded texture data to it.
    gl.activeTexture(WebGL.TEXTURE0);
    gl.bindTexture(WebGL.TEXTURE_2D, texture);

    // Prepare the viewport for drawing.
    gl.clearColor(0.5, 0.5, 0.5, 0.9);
    gl.enable(WebGL.DEPTH_TEST);
    gl.clear(WebGL.COLOR_BUFFER_BIT);
    gl.viewport(0, 0, canvas.width!, canvas.height!);

    // Bind indices to ELEMENT_ARRAY_BUFFER which will be drawn by drawElements.
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);

    // Draw!
    gl.drawElements(WebGL.TRIANGLES, indices.length, WebGL.UNSIGNED_SHORT, 0);
  });

  // Begin loading the texture.
  element.src = "texture.png";
}
