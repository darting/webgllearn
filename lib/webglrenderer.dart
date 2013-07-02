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
    batch = new WebGLBatch(gl);
    gl.disable(DEPTH_TEST);
    gl.disable(CULL_FACE);
    gl.enable(BLEND);
    gl.colorMask(true, true, true, true);
    projectionMatrix = new Matrix4.identity();
    resize(width, height);
    stageRenderGroup = new RenderGroup(gl);
  }
  
  getBatch() {
    if(_batchs.length > 0)
      return _batchs.removeLast();
    return new WebGLBatch(gl);
  }
  
  returnBatch(batch) {
    batch.clean();
    _batchs.add(batch);
  }
  
  resize(num width, num height) {
    
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
  
}