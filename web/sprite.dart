import 'dart:html';
import 'dart:web_gl';

// Loads a Texture from an ImageElement and stores both.
class Sprite {
  final Texture texture;
  final ImageElement image;

  Sprite(RenderingContext gl, String filePath)
      : image = ImageElement(src: filePath),
        texture = gl.createTexture() {
    image.onLoad.listen((event) {
      gl.bindTexture(WebGL.TEXTURE_2D, texture);

      // Assign image to the texture.
      gl.texImage2D(
        WebGL.TEXTURE_2D,
        0,
        WebGL.RGBA,
        WebGL.RGBA,
        WebGL.UNSIGNED_BYTE,
        image,
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
    });
  }
}
