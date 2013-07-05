part of compass;

class DisplayObject extends EventDispatcher implements Dispose {
  Layer parent;
  
  double _x, _y, _width, _height;
  Matrix3 _transform;
  bool _dirty;
  
  DisplayObject() {
    x = 0.0;
    y = 0.0;
    width = 0.0;
    height = 0.0;
    _transform = new Matrix3.identity();
  }
  
  removeFromParent() {
    if(parent != null) parent.removeChild(this);
  }
  
  render(Renderer renderer) {
    
  }

  dispose() {
    // TODO implement this method
  }
  
  get transformationMatrix {
    if(_dirty) {
      _dirty = false;
      
      _transform[2] = _x;
      _transform[5] = _y;
    }
    return _transform;
  }
  
  get x => _x;
  set x(double val) {
    _x = val;
    _dirty = true;
  }
  
  get y => _y;
  set y(double val) {
    _y = val;
    _dirty = true;
  }
  
  get width => _width;
  set width(double val) {
    _width = val;
    _dirty = true;
  }
  
  get height => _height;
  set height(double val) {
    _height = val;
    _dirty = true;
  }
}











