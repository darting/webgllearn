import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson5.dart';
import '../lib/compass.dart';
import 'dart:math';

SpanElement counter;
ResourceManager resources;

void main() {
 
  CanvasElement canvas = query('#container');
  counter = query('#counter');
//  var screen = new Lesson5(canvas);
//  screen.render();
  

  Director.init(canvas);
  
  director.background = Color.parse(Color.Green);
  
  document.body.children.add(director.stats.container);
  
  resources = new ResourceManager();
  resources.addImage("bunny", "bunny.png");
  resources.addTextureAtlas("walk", "walk2.json");
  resources.addTextureAtlas("bird", "bird.json");
  resources.load().then((_) {
    director.replace(new TestAnimationScene());
  });
}

class TestAnimationScene extends Scene {
  var animate;
  enter(){
    var atlas = resources.getTextureAtlas("bird");
    var rng = new Random();
    animate = new SpriteSheet(atlas.getImages("flight"), 12);
    animate.x = 400.0;
    animate.y = 200.0;
    addChild(animate);
    director.juggler.add(animate);
  }
}

class TestScene extends Scene {
  num speed = 200, sx, sy, scaleSpeed;
  SpriteSheet animate;  
  
  enter() {
    sx = speed;
    sy = speed;
    scaleSpeed = 0.1;

    var atlas = resources.getTextureAtlas("bird");
//    newChild(1, true, atlas.getImage("flight_00"));
    newChild(16500, true, resources.getImage("bunny"));
//    newAnimation(1000, atlas.getImages("walk"));
  }
  
  advanceTime(num interval) {
//    if(animate != null)
//      animate.advanceTime(interval);
    children.forEach((DisplayObject child) {
      move(interval / 1000, child);
      rotate(interval / 1000, child);
//      scaleChildren(interval / 1000, child);
//      if(child is SpriteSheet)
//        (child as SpriteSheet).advanceTime(interval);
    });
    counter.text = 'num: ' + children.length.toString() + '  tick: ' + interval.toString() + 'ms';
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
        sprite.width = 26.0;
        sprite.height = 37.0;
      }else {
        sprite.fill = new Color(rng.nextInt(256), rng.nextInt(256), rng.nextInt(256));
        sprite.width = rng.nextDouble() * 50;
        sprite.height = rng.nextDouble() * 50;
      }
      sprite.x = rng.nextDouble() * director.width;
      sprite.y = rng.nextDouble() * director.height;
      sprite.pivotX = 0.5;
      sprite.pivotY = 1.0;
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
      director.juggler.add(animate);
    }
  }
}













