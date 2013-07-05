part of compass;

class WebGLRenderer {
  num width;
  num height;
  CanvasElement canvas;
  RenderingContext gl;
  int vertexPositionAttribute, textureCoordAttribute, colorAttribute;
  UniformLocation mvMatrixUniform, samplerUniform;
  Matrix4 projectionMatrix;
  List<WebGLBatch> _batchs;
  WebGLBatch batch;
  RenderGroup stageRenderGroup;
  
  WebGLRenderer(this.width, this.height, this.canvas) {
    gl = canvas.getContext3d(preserveDrawingBuffer: true);
    _initShader();
    
    _batchs = [];
    batch = new WebGLBatch(this);
    gl.disable(DEPTH_TEST);
    gl.disable(CULL_FACE);
    gl.enable(BLEND);
    gl.colorMask(true, true, true, true);
    projectionMatrix = new Matrix4.identity();
    resize(width, height);
    stageRenderGroup = new RenderGroup(this);
  }
  
  getBatch() {
    if(_batchs.length > 0)
      return _batchs.removeLast();
    return new WebGLBatch(this);
  }
  
  returnBatch(batch) {
    batch.clean();
    _batchs.add(batch);
  }
  
  resize(num width, num height) {
    this.width = width;
    this.height = height;
    canvas.width = width;
    canvas.height = height;
    gl.viewport(0, 0, width, height);
    projectionMatrix[0] = 2 / width;
    projectionMatrix[5] = -2 / height;
    projectionMatrix[12] = -1.0;
    projectionMatrix[13] = 1.0;
  }
  
  _initShader() {
    Shader vertexShader = gl.createShader(VERTEX_SHADER);
    gl.shaderSource(vertexShader, VERTEX_SHADER_COLOR);
    gl.compileShader(vertexShader);
    if (!gl.getShaderParameter(vertexShader, COMPILE_STATUS)) {
      throw "vertex shader error: "+ gl.getShaderInfoLog(vertexShader);
    }
    
    Shader fragmentShader = gl.createShader(FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, FRAGMENT_SHADER_COLOR);
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
  
  render(Stage stage) {
    updateTextures();
    stage.updateTransform();
    gl.colorMask(true, true, true, true);
    gl.viewport(0, 0, width, height);
    gl.bindFramebuffer(FRAMEBUFFER, null);
    var backgroundColor = stage.backgroundColor;
    gl.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
    gl.clear(COLOR_BUFFER_BIT);
    stageRenderGroup.render(projectionMatrix);
  }
  
  updateTextures() {
    //TODO
  }
}