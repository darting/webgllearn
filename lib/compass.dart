library compass;

import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';

part 'display/displayobject.dart';
part 'display/displayobjectcontainer.dart';
part 'display/quad.dart';
part 'geom/circle.dart';
part 'geom/point.dart';
part 'geom/rectangle.dart';
part 'geom/vector.dart';
part 'color.dart';
part 'stage.dart';
part 'renderers.dart';
part 'state.dart';
part 'interactionmanager.dart';
part 'rendergroup.dart';
part 'webglrenderer.dart';
part 'webglbatch.dart';
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


Director director;



const VERTEX_SHADER_CODE =  """
attribute vec2 aVertexPosition;
attribute vec4 aColor;

varying vec4 vColor;

void main(void) {
    gl_Position = vec4(aVertexPosition, 1.0, 1.0);
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












