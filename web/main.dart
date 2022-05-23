import 'dart:html';
import 'dart:web_gl';

import 'gl_shader.dart';
import 'sprite.dart';
import 'sprite_batch.dart';

// Setup canvas and webGL context.
var canvas = querySelector('#canvas') as CanvasElement;
var gl = canvas.getContext3d()!;

// Basic vertex and fragment shaders which don't modify positions or colors.
var vertCode = '''
      attribute vec3 a_position;
      attribute vec2 a_texCoord;
      varying vec2 v_texCoord;
      void main(void) {
       gl_Position = vec4(a_position, 1.0);
       v_texCoord = a_texCoord;
      }
      ''';

var fragCode = '''
      precision mediump float;

      varying vec2 v_texCoord;
      uniform sampler2D u_texture;
      void main(void) {
       gl_FragColor = texture2D(u_texture, v_texCoord);
      }
      ''';

// Assets used by the sprite batch.
Sprite atlas = Sprite(gl, "texture.png");
GlShader shader = GlShader(gl, "default shader", vertCode, fragCode);

// The sprite batch itself.
SpriteBatch spriteBatch = SpriteBatch(gl, atlas, shader);

void main() {
  canvas.width = 570;
  canvas.height = 570;

  window.requestAnimationFrame(update);
}

void update(num time) {
  // Prepare the viewport for drawing.
  gl.clearColor(0.5, 0.5, 0.5, 0.9);
  gl.enable(WebGL.DEPTH_TEST);
  gl.clear(WebGL.COLOR_BUFFER_BIT);
  gl.viewport(0, 0, canvas.width!, canvas.height!);

  // Prepare to add sprites.
  spriteBatch.startBatch();
  // Add sprites.
  spriteBatch.addSprite(0, 0, 0, 0, 32, 32);
  spriteBatch.addSprite(0.5, 0.5, 32, 0, 32, 32);
  // Finish and draw the batch.
  spriteBatch.endBatch();

  window.requestAnimationFrame(update);
}
