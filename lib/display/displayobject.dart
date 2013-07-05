part of compass;


abstract class DisplayObject2 {
  Vector2 position;
  Vector2 anchor;
  Vector2 scale;
  Rect hitArea;
  num width;
  num height;
  num rotation, rotationCache, _sr, _cr;
  num alpha, worldAlpha;
  int childIndex;
  bool visible;
  bool dirty;
  bool _interactive;
  Stage stage;
  DisplayObjectContainer parent;
  Matrix3 localTransform;
  Matrix3 worldTransform;
  RenderGroup renderGroup;
  WebGLBatch batch;
  
  DisplayObject2() {
    position = new Vector2.zero();
    anchor = new Vector2.zero();
    scale = new Vector2.zero();
    alpha = 1.0;
    visible = true;
    localTransform = new Matrix3.identity();
    worldTransform = new Matrix3.identity();
  }
  
  set interactive(val) {
    _interactive = val;
    if(stage != null) stage.dirty = true;
  }
  
  onAddedToStage();
  
  updateTransform() {
    if(rotation != rotationCache){
      rotationCache = rotation;
      _sr = sin(rotation);
      _cr = cos(rotation);
    }
    
    localTransform[0] = _cr * scale.x;
    localTransform[1] = -_sr * scale.y;
    localTransform[3] = _sr * scale.x;
    localTransform[4] = _cr * scale.y;
    
    localTransform[2] = position.x - localTransform[0] * anchor.x - anchor.y * localTransform[1];
    localTransform[5] = position.y - localTransform[4] * anchor.y - anchor.x * localTransform[3];
    
    var a00 = localTransform[0], a01 = localTransform[1], a02 = localTransform[2],
        a10 = localTransform[3], a11 = localTransform[4], a12 = localTransform[5],

        b00 = parent.worldTransform[0], b01 = parent.worldTransform[1], b02 = parent.worldTransform[2],
        b10 = parent.worldTransform[3], b11 = parent.worldTransform[4], b12 = parent.worldTransform[5];
    
    worldTransform[0] = b00 * a00 + b01 * a10;
    worldTransform[1] = b00 * a01 + b01 * a11;
    worldTransform[2] = b00 * a02 + b01 * a12 + b02;

    worldTransform[3] = b10 * a00 + b11 * a10;
    worldTransform[4] = b10 * a01 + b11 * a11;
    worldTransform[5] = b10 * a02 + b11 * a12 + b12;
    
    this.worldAlpha = this.alpha * this.parent.worldAlpha;
  }
  
  removeFromParent() {
    if(parent != null) parent.removeChild(this);
  }
}















