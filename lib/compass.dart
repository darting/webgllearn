library compass;

import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';
import 'package:xml/xml.dart';

part 'geom/circle.dart';
part 'geom/point.dart';
part 'geom/rectangle.dart';
part 'geom/vector.dart';
part 'color.dart';
part 'state.dart';
part 'interactionmanager.dart';
part 'eventdispatcher.dart';
part 'displayobject.dart';
part 'sprite.dart';
part 'fill.dart';
part 'layer.dart';
part 'scene.dart';
part 'renderbatch.dart';
part 'renderer.dart';
part 'director.dart';
part 'interfaces.dart';
part 'label.dart';
part 'resourcemanager.dart';
part 'eventstreamsubscription.dart';


Director director;

const double PI2 = PI * 2;



const VERTEX_SHADER_COLOR =  """
attribute vec2 aVertexPosition;
attribute vec4 aColor;

varying vec4 vColor;

void main(void) {
    gl_Position = vec4(aVertexPosition, 1.0, 1.0);
    vColor = aColor;
}
""";

const FRAGMENT_SHADER_COLOR  = """
precision mediump float;

uniform sampler2D uSampler;

varying vec4 vColor;

void main(void) {
    gl_FragColor = vColor;
}
""";



const VERTEX_SHADER_TEXTURE =  """
attribute vec2 aVertexPosition;
attribute vec2 aTextureCoord;

varying vec2 vTextureCoord;

void main(void) {
    gl_Position = vec4(aVertexPosition, 1.0, 1.0);
    vTextureCoord = aTextureCoord;
}
""";

const FRAGMENT_SHADER_TEXTURE  = """
precision mediump float;

uniform sampler2D uSampler;

varying vec2 vTextureCoord;

void main(void) {
    gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
}
""";












