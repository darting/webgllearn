part of compass;

class Sprite extends DisplayObject {
  Fill _fill;
  Rectangle frame;
  
  Sprite() {
    frame = new Rectangle.zero();
  }
  
  get fill => _fill;
  set fill(Fill val) {
    _fill = val;
    if(val is Image) {
      val.onReady.once(_handleImage);
      
//      if(val.loaded){
//        _handleImage(val);
//      }else{
//        val.imageData.onLoad.listen((e) => _handleImage(val));
//      }
    }
  }
  
  _handleImage(Image image) {
    if(frame.isEmpty){
      frame.setTo(0, 0, image.imageData.naturalWidth.toDouble(), image.imageData.naturalHeight.toDouble());
    }
  }
  
  render(Renderer renderer) {
    renderer.render(this);
  }
}

class SpriteSheet extends Sprite {
  
}













