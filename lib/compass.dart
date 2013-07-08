library compass;

import 'dart:html' as html;
import 'dart:json' as json;
import 'dart:web_gl' as webgl;
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
part 'eventsubscription.dart';
part 'resource.dart';
part 'animatable.dart';


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


String _replaceFilename(String url, String filename) {
  RegExp regex = new RegExp(r"^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))", multiLine:false, caseSensitive:false);
  Match match = regex.firstMatch(url);
  String path = match.group(1);
  return (path == null) ? filename : "$path$filename";
}

String _getFilenameWithoutExtension(String filename) {

  RegExp regex = new RegExp(r"(.+?)(\.[^.]*$|$)", multiLine:false, caseSensitive:false);
  Match match = regex.firstMatch(filename);
  return match.group(1);
}


bool _ensureBool(bool value) {
  if (value is bool) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a bool.");
  }
}

int _ensureInt(int value) {
  if (value is int) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not an int.");
  }
}

num _ensureNum(num value) {
  if (value is num) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a number.");
  }
}

String _ensureString(String value) {
  if (value is String) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a string.");
  }
}


var callerStatsMap = new Map<String, CallerStats>();
class CallerStats {
  String name;
  int count = 0;
  int total = 0;
  Stopwatch watch;
  CallerStats(this.name) {
    if(callerStatsMap.containsKey(name)){
      callerStatsMap[name].count += 1;
    }else{
      count = 1;
      callerStatsMap[name] = this;
    }
    watch = new Stopwatch();
    watch.start();
  }
  
  stop(){
    watch.stop();
    callerStatsMap[name].total += watch.elapsedMilliseconds;
  }
}

printCallerStats(counter) {
  counter.children.clear();
  var list = [];
  callerStatsMap.forEach((String k, CallerStats v) {
    list.add(v);
  });
  list.sort((a, b) {
    if(a.total < b.total) return 1;
    else if(a.total == b.total) return 0;
    return -1;
  });
  list.forEach((CallerStats v) {
    var li = new html.LIElement();
    li.innerHtml = '${v.name} >> ${formatCallerStats("count", v.count, "")}  |  ${formatCallerStats("total", v.total, "ms")}   |   ${formatCallerStats("avg", (v.total / v.count).toStringAsFixed(3), "ms")}';
    counter.children.add(li);
  });
}

formatCallerStats(k, v, b) => '[<b>$k</b>: <font color="red">$v</font>$b]';







