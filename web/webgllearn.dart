import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson5.dart';
import '../lib/compass.dart';
import 'dart:math';


void main() {
 
  CanvasElement canvas = query('#container');
  
//  var screen = new Lesson5(canvas);
//  screen.render();
  
  
  var stage = new Stage(canvas);
  document.body.children.add(stage.stats.container);
  
  var rng = new Random();
  for(var i = 0; i < 1000; i++) {
    var d = new Quad(rng.nextInt(50), rng.nextInt(50), new Color(rng.nextInt(256), rng.nextInt(256), rng.nextInt(256)).toInt());
    d.position.x = rng.nextInt(canvas.width*2).toDouble();
    d.position.y = rng.nextInt(canvas.height*2).toDouble();
    stage.addChild(d);
  }
  stage.run();
}













