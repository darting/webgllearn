part of compass;


class RenderBatch implements Dispose {
  
  int _numSprites;
  Fill _fill;
  Matrix3 _modelViewMatrix;
  Buffer vertexBuffer, indexBuffer, uvBuffer, colorBuffer;
  Float32List verticies, uvs, colors;
  Uint16List indices;
  GLRenderer renderer;
  bool dirty;
  List<Sprite> _sprites;
  
  RenderBatch(this.renderer) {
    _numSprites = 0;
    verticies = new Float32List(0);
    uvs = new Float32List(0);
    colors = new Float32List(0);
    indices = new Uint16List(0);
    dirty = false;
    
    _sprites = [];
    
    var gl = renderer.gl;
    vertexBuffer = gl.createBuffer();
    colorBuffer = gl.createBuffer();
    indexBuffer = gl.createBuffer();
  }
  
  reset() {
    _numSprites = 0;
    _sprites.clear();
    _fill = null;
  }
  
  dispose() {
    // TODO implement this method
  }
  
  isStateChanged(Sprite sprite) {
    if(_numSprites == 0) return false;
    if(_numSprites + 1 > 8192) return true;
    if(_fill == null) return false;
    if(_fill is Color && sprite.fill is Color) return false;
    return !_fill.equals(sprite.fill);
  }
  
  add(Sprite sprite) {
    if(_numSprites == 0) _fill = sprite.fill;
    _sprites.add(sprite);
    _numSprites++;
    dirty = true;
  }
  
  refresh() {
    if(_numSprites != verticies.length / 8){
      print("grow");
      growBuffer();
    }
    
    for(var i = 0; i < _numSprites; i++){
      updateBuffer(i, _sprites[i]);
    }
  }
  
  updateBuffer(int no, Sprite sprite) {
    var worldTransform, w0, w1, h0, h1, index;
    var a, b, c, d, tx, ty;
    
    index = no * 8;
    
    worldTransform = sprite.transformationMatrix;
    a = worldTransform[0];
    b = worldTransform[3];
    c = worldTransform[1];
    d = worldTransform[4];
    tx = worldTransform[2];
    ty = worldTransform[5];
    
    w0 = sprite.width;
    h0 = sprite.height;
    w1 = renderer.canvas.width;
    h1 = renderer.canvas.height;
    var w3 = w0 / w1 * 2;
    var h3 = h0 / h1 * 2;
    
    var left = -1.0 + tx * 2/ w1;
    var top = 1.0 - ty * 2 / h1; 
    
    verticies[index + 0 ] = left;
    verticies[index + 1 ] = top - h3;
    
    verticies[index + 2 ] = left + w3;
    verticies[index + 3 ] = top - h3;
    
    verticies[index + 4 ] = left + w3;
    verticies[index + 5 ] = top;
    
    verticies[index + 6] = left;
    verticies[index + 7] = top;
    
    if(sprite.fill is Color) {
      var color = sprite.fill as Color;
      var colorIndex = no * 16;
      for(var i = 0; i < 4; i++){
        colors[colorIndex + i] = color.red / 255.0;
        colors[colorIndex + i + 1] = color.green / 255.0;
        colors[colorIndex + i + 2] = color.blue / 255.0;
        colors[colorIndex + i + 3] = color.alpha;
        colorIndex += 3;
      }
    }
  }
  
  growBuffer() {
    final RenderingContext gl = renderer.gl;
    verticies = new Float32List(_numSprites * 8);
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, verticies, DYNAMIC_DRAW);
    
    colors = new Float32List(_numSprites * 16);
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
    gl.bufferData(ARRAY_BUFFER, colors, DYNAMIC_DRAW);
    
    indices = new Uint16List(_numSprites * 6); 
    for (var i = 0; i < _numSprites; i++){
      var index2 = i * 6;
      var index3 = i * 4;
      indices[index2 + 0] = index3 + 0;
      indices[index2 + 1] = index3 + 1;
      indices[index2 + 2] = index3 + 2;
      indices[index2 + 3] = index3 + 0;
      indices[index2 + 4] = index3 + 2;
      indices[index2 + 5] = index3 + 3;
    };
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, indices, STATIC_DRAW);
  }
  
  render() {
    if(_numSprites == 0) return;

    if(dirty){
      dirty = false;
      refresh();
    }
    
    RenderingContext gl = renderer.gl;
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    gl.bufferSubData(ARRAY_BUFFER, 0, verticies);
    gl.vertexAttribPointer(renderer.vertexPositionAttribute, 2, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
    gl.bufferSubData(ARRAY_BUFFER, 0, colors);
    gl.vertexAttribPointer(renderer.colorAttribute, 4, FLOAT, false, 0, 0);

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.drawElements(TRIANGLES, _numSprites * 6, UNSIGNED_SHORT, 0);
  }
}








