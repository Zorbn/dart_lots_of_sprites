import 'dart:typed_data';
import 'dart:web_gl';

import 'gl_shader.dart';
import 'sprite.dart';

class SpriteBatch {
  // Prevent different parts of the atlas bleeding into each other.
  static const padding = 0.01;

  final Float32List vertexList;
  final Float32List texCoordList;
  final Uint16List indexList;

  final Buffer vertexBuffer;
  final Buffer texCoordBuffer;
  final Buffer indexBuffer;

  final RenderingContext gl;
  final Sprite atlas;
  final GlShader shader;

  final int maxSprites;

  int _spriteCount;
  int _vertexIndex;
  int _indexIndex;
  int _texCoordIndex;

  SpriteBatch(this.gl, this.atlas, this.shader, this.maxSprites)
      : vertexBuffer = gl.createBuffer(),
        texCoordBuffer = gl.createBuffer(),
        indexBuffer = gl.createBuffer(),
        vertexList = Float32List(3 * 4 * maxSprites),
        texCoordList = Float32List(2 * 4 * maxSprites),
        indexList = Uint16List(6 * maxSprites),
        _spriteCount = 0,
        _vertexIndex = 0,
        _indexIndex = 0,
        _texCoordIndex = 0;

  void startBatch() {
    // Get rid of data from any previous batches.
    _spriteCount = 0;
    _vertexIndex = 0;
    _indexIndex = 0;
    _texCoordIndex = 0;
  }

  void endBatch() {
    // Bind vertex, index, and texture coordinate buffers.
    gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(WebGL.ARRAY_BUFFER, vertexList, WebGL.STATIC_DRAW);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    gl.bindBuffer(WebGL.ARRAY_BUFFER, texCoordBuffer);
    gl.bufferData(WebGL.ARRAY_BUFFER, texCoordList, WebGL.STATIC_DRAW);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, indexList, WebGL.STATIC_DRAW);
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);

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
    gl.drawElements(WebGL.TRIANGLES, _indexIndex, WebGL.UNSIGNED_SHORT, 0);

    // Unbind indices after drawing.
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);
  }

  void addSprite(
      double x, double y, int atlasX, int atlasY, int atlasW, int atlasH) {
    _spriteCount++;

    if (_spriteCount > maxSprites) {
      throw RangeError(
          "Can't add $_spriteCount sprites to a batch with a max length of $maxSprites");
    }

    var vertexCount = _vertexIndex ~/ 3;

    // Add vertices, assigning with plain indexing is faster than fancier methods.
    vertexList[_vertexIndex] = x - 0.5;
    vertexList[_vertexIndex + 1] = y + 0.5;
    vertexList[_vertexIndex + 2] = 0.0;
    vertexList[_vertexIndex + 3] = x - 0.5;
    vertexList[_vertexIndex + 4] = y - 0.5;
    vertexList[_vertexIndex + 5] = 0.0;
    vertexList[_vertexIndex + 6] = x + 0.5;
    vertexList[_vertexIndex + 7] = y - 0.5;
    vertexList[_vertexIndex + 8] = 0.0;
    vertexList[_vertexIndex + 9] = x + 0.5;
    vertexList[_vertexIndex + 10] = y + 0.5;
    vertexList[_vertexIndex + 11] = 0.0;

    _vertexIndex += 12;

    // Add indices.
    indexList[_indexIndex] = vertexCount + 3;
    indexList[_indexIndex + 1] = vertexCount + 2;
    indexList[_indexIndex + 2] = vertexCount + 1;
    indexList[_indexIndex + 3] = vertexCount + 3;
    indexList[_indexIndex + 4] = vertexCount + 1;
    indexList[_indexIndex + 5] = vertexCount + 0;

    _indexIndex += 6;

    // Normalize pixel coordinates to texture coordinates.
    var normX = atlasX / (atlas.image.width ?? 1) + padding;
    var normY = atlasY / (atlas.image.height ?? 1) + padding;
    var normW = atlasW / (atlas.image.width ?? 1) - padding;
    var normH = atlasH / (atlas.image.height ?? 1) - padding;

    // Add texture coordinates.
    texCoordList[_texCoordIndex] = normX;
    texCoordList[_texCoordIndex + 1] = normY;
    texCoordList[_texCoordIndex + 2] = normX;
    texCoordList[_texCoordIndex + 3] = normY + normH;
    texCoordList[_texCoordIndex + 4] = normX + normW;
    texCoordList[_texCoordIndex + 5] = normY + normH;
    texCoordList[_texCoordIndex + 6] = normX + normW;
    texCoordList[_texCoordIndex + 7] = normY;

    _texCoordIndex += 8;
  }
}
