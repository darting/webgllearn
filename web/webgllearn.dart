import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson5.dart';
import '../lib/compass.dart';
import 'dart:math';

SpanElement counter;

void main() {
 
  CanvasElement canvas = query('#container');
  counter = query('#counter');
//  var screen = new Lesson5(canvas);
//  screen.render();
  

  Director.init(canvas);
  
  document.body.children.add(director.stats.container);
  
  director.replace(new TestScene());
  
}

class TestScene extends Scene {
  
  num speed = 200, sx, sy;
  
  enter() {
    sx = speed;
    sy = speed;
    
    newChild(2000);
  }
  
  tick(num interval) {
    children.forEach((DisplayObject child) {
      var s = (interval / 1000);
      
      
      var dx = s * sx;
      var dy = s * sy;
      if(child.x + child.width + dx > director.width.toDouble()){ 
        sx = -speed;
        child.x = director.width.toDouble() - child.width;
      }else if(child.x + dx < 0){
        sx = speed;
        child.x = 0.0;
      }else{
        child.x += dx;
      }
      if(child.y + child.height + dy > director.height.toDouble()){ 
        sy = -speed;
        child.y = director.height.toDouble() - child.height;
      }else if(child.y + dy < 0){
        sy = speed;
        child.y = 0.0;
      }else{
        child.y += dy;
      }
    });
    counter.text = 'num: ' + children.length.toString() + '  tick: ' + interval.toString() + 'ms';
    return;
    if(interval < 33){
      newChild(10);
    }
  }
  
  newChild(int count) {
    var rng = new Random();
    for(var i = 0; i < count; i++){
      var sprite = new Sprite();
      sprite.fill = new Color(rng.nextInt(256), rng.nextInt(256), rng.nextInt(256));
//      sprite.fill = new Image("bunny.png");
      sprite.x = rng.nextDouble() * director.width;
      sprite.y = rng.nextDouble() * director.height;
      sprite.width = rng.nextDouble() * 50;
      sprite.height = rng.nextDouble() * 50;
      addChild(sprite);
    }
  }
}













