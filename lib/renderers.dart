part of compass;


class WebGLRenderer {
  RenderingContext context;
  int vertexPositionAttribute, textureCoordAttribute, colorAttribute;
  UniformLocation _mvMatrixUniform, _samplerUniform;
  List<Matrix4> _mvMatrixStack;
  Matrix4 modelViewMatrix;
  
  WebGLRenderer(CanvasElement canvas) {
    context = canvas.getContext3d(preserveDrawingBuffer: true);
    _mvMatrixStack = [];
    modelViewMatrix = new Matrix4.identity();
    resize(canvas.width, canvas.height);
    _initShader();
  }

  resize(num width, num height) {
//    _mvMatrix[0] = 2 / width;
//    _mvMatrix[5] = -2 / height;
//    _mvMatrix[12] = -1.0;
//    _mvMatrix[13] = 1.0;
  }
  
  _initShader() {
    Shader vertexShader = context.createShader(VERTEX_SHADER);
    context.shaderSource(vertexShader, VERTEX_SHADER_CODE);
    context.compileShader(vertexShader);
    if (!context.getShaderParameter(vertexShader, COMPILE_STATUS)) {
      throw "vertex shader error: "+ context.getShaderInfoLog(vertexShader);
    }
    
    Shader fragmentShader = context.createShader(FRAGMENT_SHADER);
    context.shaderSource(fragmentShader, FRAGMENT_SHADER_CODE);
    context.compileShader(fragmentShader);
    if (!context.getShaderParameter(fragmentShader, COMPILE_STATUS)) {
      throw "fragment shader error: "+ context.getShaderInfoLog(fragmentShader);
    }
    
    Program program = context.createProgram();
    context.attachShader(program, vertexShader);
    context.attachShader(program, fragmentShader);
    context.linkProgram(program);
    if (!context.getProgramParameter(program, LINK_STATUS)) {
      throw "Could not initialise shaders.";
    }
    context.useProgram(program);

    vertexPositionAttribute = context.getAttribLocation(program, "aVertexPosition");
    context.enableVertexAttribArray(vertexPositionAttribute);
    
    colorAttribute = context.getAttribLocation(program, "aColor");
    context.enableVertexAttribArray(colorAttribute);
    
    _mvMatrixUniform = context.getUniformLocation(program, "uMVMatrix");
    _samplerUniform = context.getUniformLocation(program, "uSampler");
  }
  
  pushMVMatrix() {
    _mvMatrixStack.add(modelViewMatrix.clone());
  }
  
  popMVMatrix() {
    modelViewMatrix = _mvMatrixStack.removeLast();
  }
  
  setMatrixUniforms() {
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    modelViewMatrix.copyIntoArray(tmp);
    context.uniformMatrix4fv(_mvMatrixUniform, false, tmp);
  }
  
  render(Stage stage) {
    
    context.viewport(0, 0, stage.width, stage.height);
    context.clearColor(1, 1, 1, 1);
    context.clear(COLOR_BUFFER_BIT);
//    context.colorMask(true, true, true, false);
//    context.enable(BLEND);
//    context.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
    
    modelViewMatrix.setIdentity();
    
    pushMVMatrix();

    stage.children.forEach((child) => child.render());
    
    popMVMatrix();
  }
}