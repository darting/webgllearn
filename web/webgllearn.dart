import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson5.dart';
import '../lib/compass.dart';
import 'dart:math';

Element counter;


void main() {
 
  CanvasElement canvas = query('#container');
  counter = query('#counter');
//  var screen = new Lesson5(canvas);
//  screen.render();
  

  Director.init(canvas);
  
  director.background = Color.parse(Color.Green);
  
  document.body.children.add(director.stats.container);
  
  director.replace(new TestScene());
  
}

class TestScene extends Scene {
  
  num speed = 200, sx, sy, scaleSpeed;
  ResourceManager resources;
  
  SpriteSheet animate;  
  
  enter() {
    sx = speed;
    sy = speed;
    scaleSpeed = 0.1;
    
    resources = new ResourceManager();
    resources.addImage("atlas", "atlas.png");
    resources.addTextureAtlas("walk", "walk2.json");
    resources.load().then((_) {
      var atlas = resources.getTextureAtlas("walk");
//      newChild(20000, false, atlas.getImage("walk__03"));
//      animate = new SpriteSheet(atlas.getImages("walk"), 12);
//      addChild(animate);
      newAnimation(5000, atlas.getImages("walk"));
    });
    
//    newChild(2, true);
//    newChild(3, false);
  }
  
  tick(num interval) {
//    if(animate != null)
//      animate.advanceTime(interval);
//    children.forEach((DisplayObject child) {
//      move(interval / 1000, child);
//      rotate(interval / 1000, child);
//      scaleChildren(interval / 1000, child);
//      if(child is SpriteSheet)
//        (child as SpriteSheet).advanceTime(interval);
//    });
//    counter.text = 'num: ' + children.length.toString() + '  tick: ' + interval.toString() + 'ms';
    printCallerStats(counter);
  }
  
  scaleChildren(num s, DisplayObject child) {
    num ss = child.scaleX + scaleSpeed;
    if(ss >= 2.0) scaleSpeed = -0.1;
    else if(ss < 0.5) scaleSpeed = 0.1;
    child.scaleX = child.scaleY = ss;
  }
  
  rotate(num s, DisplayObject child) {
    child.rotation += 0.1;
  }
  
  move(num s, child) {
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
  }
  
  newChild(int count, bool useImage, [Image image]) {
    var rng = new Random();
    for(var i = 0; i < count; i++){
      var sprite = new Sprite();
      if(useImage){
        sprite.fill = image;
        sprite.scaleX = sprite.scaleY = 0.3;
      }else {
        sprite.fill = new Color(rng.nextInt(256), rng.nextInt(256), rng.nextInt(256), rng.nextDouble());
        sprite.width = 32.0;//rng.nextDouble() * 50;
        sprite.height = 32.0;//rng.nextDouble() * 50;
      }
      sprite.x = rng.nextDouble() * director.width;
      sprite.y = rng.nextDouble() * director.height;
//      sprite.pivotX = 0.5;
//      sprite.pivotY = 0.5;
//      sprite.x = 100.0;
//      sprite.y = 100.0;
      addChild(sprite);
    }
  }
  
  newAnimation(int count, List<Image> images) {
    var rng = new Random();
    for(var i = 0; i < count; i++){
      var animate = new SpriteSheet(images, 12);
      animate.x = rng.nextDouble() * director.width;
      animate.y = rng.nextDouble() * director.height;
      animate.scaleX = animate.scaleY = 0.5;
      addChild(animate);
    }
  }
}













