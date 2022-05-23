import 'dart:typed_data';
import 'dart:web_gl';

import 'gl_shader.dart';
import 'sprite.dart';

class SpriteBatch {
  // Prevent different parts of the atlas bleeding into each other.
  static const padding = 0.01;

  final List<double> vertexList = [];
  final List<double> texCoordList = [];
  final List<int> indexList = [];

  final Buffer vertexBuffer;
  final Buffer texCoordBuffer;
  final Buffer indexBuffer;

  final RenderingContext gl;
  final Sprite atlas;
  final GlShader shader;

  SpriteBatch(this.gl, this.atlas, this.shader)
      : vertexBuffer = gl.createBuffer(),
        texCoordBuffer = gl.createBuffer(),
        indexBuffer = gl.createBuffer();

  void startBatch() {
    // Get rid of data from any previous batches.
    vertexList.clear();
    texCoordList.clear();
    indexList.clear();
  }

  void endBatch() {
    // Bind vertex, index, and texture coordinate buffers.
    gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(WebGL.ARRAY_BUFFER, Float32List.fromList(vertexList),
        WebGL.STATIC_DRAW);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, Uint16List.fromList(indexList),
        WebGL.STATIC_DRAW);
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);

    gl.bindBuffer(WebGL.ARRAY_BUFFER, texCoordBuffer);
    gl.bufferData(WebGL.ARRAY_BUFFER, Float32List.fromList(texCoordList),
        WebGL.STATIC_DRAW);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    /*
     * Assign buffers to vertex shader attributes.
     */

    // Make vertexBuffer the bound ARRAY_BUFFER.
    gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
    // Bind current ARRAY_BUFFER to aPositionLoc.
    gl.vertexAttribPointer(shader.aPositionLoc, 3, WebGL.FLOAT, false, 0, 0);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    // Make texCoordBuffer the bound ARRAY_BUFFER.
    gl.bindBuffer(WebGL.ARRAY_BUFFER, texCoordBuffer);
    // Bind current ARRAY_BUFFER to aTexCoordLoc
    gl.vertexAttribPointer(shader.aTexCoordLoc, 2, WebGL.FLOAT, false, 0, 0);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    _drawBatch();
  }

  void _drawBatch() {
    // Activate texture 0, bind the previously loaded texture data to it.
    gl.activeTexture(WebGL.TEXTURE0);
    gl.bindTexture(WebGL.TEXTURE_2D, atlas.texture);
    // Bind indices to ELEMENT_ARRAY_BUFFER which will be drawn by drawElements.
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);

    shader.use(gl);

    // Draw!
    gl.drawElements(WebGL.TRIANGLES, indexList.length, WebGL.UNSIGNED_SHORT, 0);
  }

  void addSprite(
      double x, double y, int atlasX, int atlasY, int atlasW, int atlasH) {
    var vertexCount = vertexList.length ~/ 3;

    vertexList.addAll([
      x - 0.5, y + 0.5, 0.0, // Quad top left.
      x - 0.5, y - 0.5, 0.0, // Quad bottom left.
      x + 0.5, y - 0.5, 0.0, // Quad bottom right.
      x + 0.5, y + 0.5, 0.0, // Quad top right.
    ]);

    // Index the latest vertices, by basing new indices on the previous vertex count.
    indexList.addAll([
      vertexCount + 3,
      vertexCount + 2,
      vertexCount + 1,
      vertexCount + 3,
      vertexCount + 1,
      vertexCount + 0
    ]);

    // Normalize pixel coordinates to texture coordinates.
    var normX = atlasX / (atlas.image.width ?? 1) + padding;
    var normY = atlasY / (atlas.image.height ?? 1) + padding;
    var normW = atlasW / (atlas.image.width ?? 1) - padding;
    var normH = atlasH / (atlas.image.height ?? 1) - padding;

    texCoordList.addAll([
      normX, normY, //                 Texture top left.
      normX, normY + normH, //         Texture bottom left.
      normX + normW, normY + normH, // Texture bottom right.
      normX + normW, normY //          Texture top-right.
    ]);
  }
}
