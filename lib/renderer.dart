part of compass;


abstract class Renderer implements Dispose{
  CanvasElement canvas;
  
  Renderer(this.canvas);
  nextFrame();
  render(Sprite sprite);
  finishBatch();
  dispose();
}

class GLRenderer extends Renderer {
  RenderingContext gl;
  int vertexPositionAttribute, textureCoordAttribute, colorAttribute;
  UniformLocation mvMatrixUniform, samplerUniform;
  
  List<RenderBatch> _batchs;
  int _currentBatchIndex;
  
  GLRenderer(canvas) : super(canvas) {
    gl = canvas.getContext3d(preserveDrawingBuffer: true);
    _initShader();
    
    _batchs = [new RenderBatch(this)];
    _currentBatchIndex = 0;
  }
  
  _initShader() {
    Shader vertexShader = gl.createShader(VERTEX_SHADER);
    gl.shaderSource(vertexShader, VERTEX_SHADER_CODE);
    gl.compileShader(vertexShader);
    if (!gl.getShaderParameter(vertexShader, COMPILE_STATUS)) {
      throw "vertex shader error: "+ gl.getShaderInfoLog(vertexShader);
    }
    
    Shader fragmentShader = gl.createShader(FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, FRAGMENT_SHADER_CODE);
    gl.compileShader(fragmentShader);
    if (!gl.getShaderParameter(fragmentShader, COMPILE_STATUS)) {
      throw "fragment shader error: "+ gl.getShaderInfoLog(fragmentShader);
    }
    
    Program program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, LINK_STATUS)) {
      throw "Could not initialise shaders.";
    }
    gl.useProgram(program);

    vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition");
    gl.enableVertexAttribArray(vertexPositionAttribute);
    
    colorAttribute = gl.getAttribLocation(program, "aColor");
    gl.enableVertexAttribArray(colorAttribute);
    
    mvMatrixUniform = gl.getUniformLocation(program, "uMVMatrix");
    samplerUniform = gl.getUniformLocation(program, "uSampler");
  }

  nextFrame() {
    _currentBatchIndex = 0;
  }
  
  render(Sprite sprite) {
    if(_batchs[_currentBatchIndex].isStateChange(sprite)){
      finishBatch();
    }
    _batchs[_currentBatchIndex].add(sprite);
  }
  
  finishBatch() {
    _batchs[_currentBatchIndex].render();
    _batchs[_currentBatchIndex].reset();
    _currentBatchIndex++;
    if(_batchs.length <= _currentBatchIndex)
      _batchs.add(new RenderBatch(this));
  }

  dispose() {
    _batchs.forEach((batch) => batch.dispose());
    _batchs.clear();
  }
}