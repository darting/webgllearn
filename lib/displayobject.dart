part of compass;

class DisplayObject implements Dispose {
  Layer parent;
  
  double _x, _y, _width, _height, _pivotX, _pivotY, _skewX, _skewY, _scaleX, _scaleY, _rotation, _alpha;
  bool _dirty, _visible;
  Matrix3 _transform;
  
  DisplayObject() {
    x = y = width = height = rotation = pivotX = pivotY = 0.0;
    scaleX = scaleY = 1.0;
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
      
      var sr = sin(_rotation);
      var cr = cos(_rotation);
      
      _transform[0] = cr * _scaleX;
      _transform[1] = -sr * _scaleY;
      _transform[3] = sr * _scaleX;
      _transform[4] = cr * _scaleY;

      _transform[2] = _x - _transform[0] * _pivotX - _pivotY * _transform[1];
      _transform[5] = _y - _transform[4] * _pivotY - _pivotX * _transform[3];
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
  
  get pivotX => _pivotX;
  set pivotX(double val) {
    _pivotX = val;
    _dirty = true;
  }
  
  get pivotY => _pivotY;
  set pivotY(double val) {
    _pivotY = val;
    _dirty = true;
  }
  
  get scaleX => _scaleX;
  set scaleX(double val) {
    _scaleX = val;
    _dirty = true;
  }
  
  get scaleY => _scaleY;
  set scaleY(double val) {
    _scaleY = val;
    _dirty = true;
  }
  
  get rotation => _rotation;
  set rotation(double val) {
    _rotation = val % PI2;
    _dirty = true;
  }
}











