library compass;

import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:async';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';

part 'displayobject.dart';
part 'stage.dart';
part 'renderers.dart';
part 'quad.dart';
part 'color.dart';
part 'state.dart';






const VERTEX_SHADER_CODE =  """
attribute vec2 aVertexPosition;
attribute vec4 aColor;

uniform mat4 uMVMatrix;

varying vec4 vColor;

void main(void) {
    gl_Position = uMVMatrix * vec4(aVertexPosition, 1.0, 1.0);
    vColor = aColor;
}
""";

const FRAGMENT_SHADER_CODE  = """
precision mediump float;

uniform sampler2D uSampler;

varying vec4 vColor;

void main(void) {
    gl_FragColor = vColor;
}
""";



getVertexShaderSource(bool hasTexture) {
  int textureFlags = hasTexture ? 1 : 0;
  
  return """
  #define hasTexture = ${textureFlags}
  
  attribute vec2 aVertexPosition;
  attribute vec2 aTextureCoord;
  attribute float aColor;

  uniform mat4 uMVMatrix;

  #if hasTexture
  varying vec2 vTextureCoord;
  #endif

  varying float vColor;

  void main(void) {
    gl_Position = uMVMatrix * vec4(aVertexPosition, 1.0, 1.0);
  
    #if hasTexture
    vTextureCoord = aTextureCoord;
    #endif
  
    vColor = aColor;
  }
  """;
}
















