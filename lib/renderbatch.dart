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
  }
  
  reset() {
    _numSprites = 0;
    _fill = null;
  }
  
  dispose() {
    // TODO implement this method
  }
  
  isStateChange(Sprite sprite) {
    if(_numSprites == 0) return false;
    if(_numSprites + 1 > 8192) return true;
    if(_fill == null) return false;
    return _fill.equals(sprite.fill);
  }
  
  add(Sprite sprite) {
    if(_numSprites == 0) _fill = sprite.fill;
    if(_numSprites + 1 > verticies.length / 8) expand();
    growVertexBuffer(sprite);
    _numSprites++;
  }
  
  expand() {
    RenderingContext gl = renderer.gl;
    
    final factor = 16;
    verticies.addAll(new Iterable.generate(8 * factor, (i) => 0.0));
    if(vertexBuffer == null) {
      vertexBuffer = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
      gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(verticies), STATIC_DRAW);
    }
    
    colors.addAll(new Iterable.generate(4 * factor, (i) => 0.0));
    if(colorBuffer == null) {
      colorBuffer = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
      gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(colors), STATIC_DRAW);
    }
    
    final arr = const [0, 1, 2, 0, 2, 3];
    indices.addAll(new Iterable.generate(4 * factor, (i) => arr[i % 6]));
   
    indexBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, indexBuffer);
    gl.bufferData(ARRAY_BUFFER, new Uint16List.fromList(indices), STATIC_DRAW);
  }
  
  growVertexBuffer(Sprite sprite) {
    var worldTransform, width, height, w0, w1, h0, h1, index, index2, index3;
    var a, b, c, d, tx, ty;
    
    width = sprite.width;
    height = sprite.height;
    w0 = width; //width * (1 - aX);
    w1 = 0; //width * -aX;
    
    h0 = height; //height * (1 - aY);
    h1 = 0; //height * -aY;
    
    index = _numSprites * 8;
    
    worldTransform = sprite.transformationMatrix;
    a = worldTransform[0];
    b = worldTransform[3];
    c = worldTransform[1];
    d = worldTransform[4];
    tx = worldTransform[2];
    ty = worldTransform[5];
    
    verticies[index + 0 ] = a * w1 + c * h1 + tx; 
    verticies[index + 1 ] = d * h1 + b * w1 + ty;
    
    verticies[index + 2 ] = a * w0 + c * h1 + tx; 
    verticies[index + 3 ] = d * h1 + b * w0 + ty; 
    
    verticies[index + 4 ] = a * w0 + c * h0 + tx; 
    verticies[index + 5 ] = d * h0 + b * w0 + ty; 
    
    verticies[index + 6] =  a * w1 + c * h0 + tx; 
    verticies[index + 7] =  d * h0 + b * w1 + ty; 
    
    if(sprite.fill is Color) {
      var color = sprite.fill as Color;
      var colorIndex = _numSprites * 4;
      colors[colorIndex] = color.red.toDouble();
      colors[colorIndex + 1] = color.green.toDouble(); 
      colors[colorIndex + 2] = color.blue.toDouble();
      colors[colorIndex + 3] = color.alpha;
    }
  }
  
  render() {
    if(_numSprites == 0) return;
    
    RenderingContext gl = renderer.gl;
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
//    gl.bufferSubData(ARRAY_BUFFER, 0, new Float32List.fromList(verticies));
//    gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(verticies), STATIC_DRAW);
    gl.vertexAttribPointer(renderer.vertexPositionAttribute, 2, FLOAT, false, 0, 0);
    
//    gl.bindBuffer(ARRAY_BUFFER, uvBuffer);
//    gl.vertexAttribPointer(renderer.textureCoordAttribute, 2, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
//    gl.bufferSubData(ARRAY_BUFFER, 0, new Float32List.fromList(colors));
//    gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(colors), STATIC_DRAW);
    gl.vertexAttribPointer(renderer.colorAttribute, 1, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.drawElements(TRIANGLES, _numSprites * 6, UNSIGNED_SHORT, 0);
  }
}








