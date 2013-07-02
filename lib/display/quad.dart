part of compass;

class Quad extends DisplayObject {
  Buffer vertexBuffer, indexBuffer, uvBuffer, colorBuffer;
  int blendMode = BLEND;
  int color;
  
  Quad(num width, num height, int color) {
    this.width = width;
    this.height = height;
    this.color = color;
  }
  
  _init() {
    var context = stage.renderer.gl;
    vertexBuffer = context.createBuffer();
    context.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    context.bufferData(ARRAY_BUFFER,  new Float32List.fromList([
      -1.0, -1.0,
      1.0, -1.0,
      1.0, 1.0,
      -1.0, 1.0]) , STATIC_DRAW);
    
    uvBuffer = context.createBuffer();
    context.bindBuffer(ARRAY_BUFFER, uvBuffer);
    context.bufferData(ARRAY_BUFFER,  new Float32List(8) , DYNAMIC_DRAW);
    
    colorBuffer = context.createBuffer();
    context.bindBuffer(ARRAY_BUFFER, colorBuffer);
    Color argb = Color.parse(color);
    var colors = [];
    for(var i = 0; i < 4; i++){
      colors.add(argb.red.toDouble() / 255.0);
      colors.add(argb.green.toDouble() / 255.0);
      colors.add(argb.blue.toDouble() / 255.0);
      colors.add(argb.alpha);
    }
    context.bufferData(ARRAY_BUFFER,  new Float32List.fromList(colors), STATIC_DRAW);
    
    indexBuffer = context.createBuffer();
    context.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    context.bufferData(ELEMENT_ARRAY_BUFFER, new Uint16List.fromList([0, 1, 2, 0, 2, 3]), STATIC_DRAW);
  }
  
  render() {
    var renderer = stage.renderer;
    var context = renderer.gl;
    
    context.bindBuffer(ARRAY_BUFFER, vertexBuffer);
    context.vertexAttribPointer(renderer.vertexPositionAttribute, 2, FLOAT, false, 0, 0);
 
    context.bindBuffer(ARRAY_BUFFER, colorBuffer);
    context.vertexAttribPointer(renderer.colorAttribute, 4, FLOAT, false, 0, 0);
    
    renderer.pushMVMatrix();
    
    var mvMatrix = renderer.modelViewMatrix;
    mvMatrix.translate(position.x / stage.width - 1.0, 1.0 - position.y / stage.height);
    mvMatrix.scale(width / stage.width, height / stage.height);
    
    // 绘制
    context.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
    renderer.setMatrixUniforms();
    context.drawElements(TRIANGLES, 6, UNSIGNED_SHORT, 0);
    
    renderer.popMVMatrix();
  }

  onAddedToStage() {
    _init();
  }

  updateTransform() {
    // TODO implement this method
  }
}