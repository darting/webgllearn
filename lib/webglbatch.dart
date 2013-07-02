part of compass;

class WebGLBatch {
  WebGLRenderer renderer;
  int size, dynamicSize;
  int blendMode;
  Buffer vertexBuffer, indexBuffer, uvBuffer, colorBuffer;
  Float32List verticies, uvs, colors;
  Uint16List indices;
  bool dirty, dirtyColors;
  List<DisplayObject> displayObjects;
  
  WebGLBatch(this.renderer) {
    size = 0;
    dynamicSize = 1;
    blendMode = BLEND;
    displayObjects = [];
    RenderingContext gl = renderer.gl;
    vertexBuffer = gl.createBuffer();
    indexBuffer = gl.createBuffer();
    uvBuffer = gl.createBuffer();
    colorBuffer = gl.createBuffer();
  }
  
  clean() {
    verticies.clear();
    uvs.clear();
    colors.clear();
    indices.clear();
    dynamicSize = 1;
    size = 0;
  }
  
  grow() {
    RenderingContext gl = renderer.gl;
    if(size == 1)
      dynamicSize = 1;
    else
      dynamicSize = (size * 1.5).toInt();
    
    verticies = new Float32List(dynamicSize * 8);
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, verticies, DYNAMIC_DRAW);
    
    uvs = new Float32List(dynamicSize * 8);
    gl.bindBuffer(ARRAY_BUFFER, uvBuffer);
    gl.bufferData(ARRAY_BUFFER, uvs, DYNAMIC_DRAW);
    
    colors = new Float32List(dynamicSize * 4);
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
    gl.bufferData(ARRAY_BUFFER, colors, DYNAMIC_DRAW);
    dirtyColors = true;

    indices = new Uint16List(dynamicSize * 6);
    var len = indices.length / 6;
    for(var i = 0; i < len; i++){
      var i1 = i * 6;
      var i2 = i * 4;
      indices[i1 + 0] = i2 + 0;
      indices[i1 + 1] = i2 + 1;
      indices[i1 + 2] = i2 + 2;
      indices[i1 + 3] = i2 + 0;
      indices[i1 + 4] = i2 + 2;
      indices[i1 + 5] = i2 + 3;
    }
    gl.bindBuffer(ARRAY_BUFFER, indexBuffer);
    gl.bufferData(ARRAY_BUFFER, indices, STATIC_DRAW);
  }
  
  update() {
    RenderingContext gl = renderer.gl;
    var worldTransform, width, height, aX, aY, w0, w1, h0, h1, index, index2, index3;
    var a, b, c, d, tx, ty;
    var indexRun = 0;
    displayObjects.forEach((DisplayObject displayObject) {
      if(displayObject.visible){
        width = displayObject.width;
        height = displayObject.height;
        aX = displayObject.anchor.x;
        aY = displayObject.anchor.y;
        w0 = width * (1 - aX);
        w1 = width * -aX;
        
        h0 = height * (1 - aY);
        h1 = height * -aY;
        
        index = indexRun * 8;
        
        worldTransform = displayObject.worldTransform;
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
        
        var colorIndex = indexRun * 4;
        this.colors[colorIndex] = this.colors[colorIndex + 1] = this.colors[colorIndex + 2] = this.colors[colorIndex + 3] = displayObject.worldAlpha;
        this.dirtyColors = true;
      }else{
        index = indexRun * 8;
        
        verticies[index + 0 ] = 0.0;
        verticies[index + 1 ] = 0.0;
        
        verticies[index + 2 ] = 0.0;
        verticies[index + 3 ] = 0.0;
        
        verticies[index + 4 ] = 0.0;
        verticies[index + 5 ] = 0.0;
        
        verticies[index + 6] = 0.0;
        verticies[index + 7] = 0.0;
      }
      indexRun++;
    });
  }
  
  render() {
    if(size == 0) return;
    
    update();
    RenderingContext gl = renderer.gl;
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    
    gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    gl.bufferSubData(ARRAY_BUFFER, 0, verticies);
    gl.vertexAttribPointer(renderer.vertexPositionAttribute, 2, FLOAT, false, 0, 0);
    
//    gl.bindBuffer(ARRAY_BUFFER, uvBuffer);
//    gl.vertexAttribPointer(renderer.textureCoordAttribute, 2, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
    gl.bufferSubData(ARRAY_BUFFER, 0, colors);
    gl.vertexAttribPointer(renderer.colorAttribute, 1, FLOAT, false, 0, 0);
    
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.drawElements(TRIANGLES, size * 6, UNSIGNED_SHORT, 0);
  }
}
















