part of compass;


class RenderBatch implements Dispose {
  
  int _numSprites;
  Fill _fill;
  Matrix3 _modelViewMatrix;
  Buffer vertexBuffer, indexBuffer, uvBuffer, colorBuffer;
  List<double> verticies, uvs, colors;
  List<int> indices;
  GLRenderer renderer;
  
  RenderBatch(this.renderer) {
    _numSprites = 0;
    var gl = renderer.gl;
    
    verticies = [];
    uvs = [];
    colors = [];
    indices = [];
    
    vertexBuffer = gl.createBuffer();
    colorBuffer = gl.createBuffer();
    indexBuffer = gl.createBuffer();
    
  }
  
  reset() {
    _numSprites = 0;
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
    if(_numSprites + 1 > verticies.length / 8) expand();
    growVertexBuffer(sprite);
    _numSprites++;
  }
  
  expand() {
    RenderingContext gl = renderer.gl;
    
    final factor = 1;
    
    verticies.addAll(new Iterable.generate(8 * factor, (i) => 0.0));
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(verticies), DYNAMIC_DRAW);
    
    colors.addAll(new Iterable.generate(16 * factor, (i) => 0.0));
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
    gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(colors), DYNAMIC_DRAW);
    
    final index = _numSprites * 4;
    final arr = const [0, 1, 2, 0, 2, 3];
    indices.addAll(new Iterable.generate(6 * factor, (i) => index + arr[i % 6]));
   
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(indices), STATIC_DRAW);
  }
  
  growVertexBuffer(Sprite sprite) {
    var worldTransform, w0, w1, h0, h1, index;
    var a, b, c, d, tx, ty;
    
    
    index = _numSprites * 8;
    
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
    var w3 = w0 / w1;
    var h3 = h0 / h1;
    
    var left = -1.0 + tx / w1;
    var top = 1.0 - ty / h1; 
    
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
      var colorIndex = _numSprites * 16;
      for(var i = 0; i < 4; i++){
        colors[colorIndex + i] = color.red / 255.0;
        colors[colorIndex + i + 1] = color.green / 255.0;
        colors[colorIndex + i + 2] = color.blue / 255.0;
        colors[colorIndex + i + 3] = color.alpha;
        colorIndex += 3;
      }
    }
  }
  
  render() {
    if(_numSprites == 0) return;
    
    RenderingContext gl = renderer.gl;
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    gl.bufferSubData(ARRAY_BUFFER, 0, new Float32List.fromList(verticies));
//    gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(verticies), STATIC_DRAW);
    gl.vertexAttribPointer(renderer.vertexPositionAttribute, 2, FLOAT, false, 0, 0);
    
//    gl.bindBuffer(ARRAY_BUFFER, uvBuffer);
//    gl.vertexAttribPointer(renderer.textureCoordAttribute, 2, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
    gl.bufferSubData(ARRAY_BUFFER, 0, new Float32List.fromList(colors));
//    gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(colors), STATIC_DRAW);
    gl.vertexAttribPointer(renderer.colorAttribute, 4, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.drawElements(TRIANGLES, _numSprites * 6, UNSIGNED_SHORT, 0);
  }
}








