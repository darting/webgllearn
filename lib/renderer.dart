part of compass;


abstract class Renderer implements Dispose{
  CanvasElement canvas;
  
  Renderer(this.canvas);
  nextFrame();
  render(Sprite sprite);
  finishBatch();
  dispose();
}

class WebGLRenderer extends Renderer {
  final Set<String> _loadingTextures = new Set<String>();
  final Map<String, Texture> _texturesCache = new Map<String, Texture>();
  final Map<String, ShaderProgram> _programsCache = new Map<String, ShaderProgram>();
  RenderingContext gl;
  List<RenderBatch> _batchs;
  int _currentBatchIndex;
  
  WebGLRenderer(CanvasElement canvas) : super(canvas) {
    gl = canvas.getContext3d(preserveDrawingBuffer: true);
    gl.disable(DEPTH_TEST);
    gl.disable(CULL_FACE);
    gl.enable(BLEND);
//    gl.blendFunc(SRC_ALPHA, ONE);
//    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    _initShader();
    
    _batchs = [new RenderBatch(this)];
    _currentBatchIndex = 0;
  }
  
  _initShader() {
    _programsCache["color"] = new ShaderProgram(VERTEX_SHADER_COLOR, FRAGMENT_SHADER_COLOR, gl);
    _programsCache["texture"] = new ShaderProgram(VERTEX_SHADER_TEXTURE, FRAGMENT_SHADER_TEXTURE, gl);
  }

  getShaderProgram(String name) {
    return _programsCache[name];
  }
  
  nextFrame() {
    _currentBatchIndex = 0;
    
    gl.viewport(0, 0, director.width, director.height);
    gl.clearColor(director.background.red, 
        director.background.green, 
        director.background.blue, 
        director.background.alpha);
    gl.clear(COLOR_BUFFER_BIT);
  }
  
  render(Sprite sprite) {
    if(sprite.fill is Image){
      loadTexture(sprite.fill as Image);
    }
    if(_batchs[_currentBatchIndex].isStateChanged(sprite)){
      finishBatch();
    }
    _batchs[_currentBatchIndex].add(sprite);
  }
  
  loadTexture(Image fill) {
    if(!_loadingTextures.contains(fill.src) && !_texturesCache.containsKey(fill.src)){
      _loadingTextures.add(fill.src);
      fill.onReady.once(_handleTexture);
    }
  }
  
  findTexture(Image fill) {
    return _texturesCache[fill.src];
  }

  _handleTexture(Image fill) {
    print('handle texture ${fill.src}');
    Texture texture = gl.createTexture();
    gl.bindTexture(TEXTURE_2D, texture);
    gl.pixelStorei(UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
    gl.texImage2D(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, fill.imageData);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, LINEAR);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR);
    gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, REPEAT);
    gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, REPEAT);
    gl.bindTexture(TEXTURE_2D, null);
    _loadingTextures.remove(fill.src);
    _texturesCache[fill.src] = texture;
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

class ShaderProgram {
  Program program;
  int vertexPositionAttribute, textureCoordAttribute, colorAttribute;
  UniformLocation samplerUniform;
  
  ShaderProgram(String vertextShaderSource, String fragmentShaderSource, RenderingContext gl) {
    Shader vertexShader = gl.createShader(VERTEX_SHADER);
    gl.shaderSource(vertexShader, vertextShaderSource);
    gl.compileShader(vertexShader);
    if (!gl.getShaderParameter(vertexShader, COMPILE_STATUS)) {
      throw "vertex shader error: "+ gl.getShaderInfoLog(vertexShader);
    }
    
    Shader fragmentShader = gl.createShader(FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, fragmentShaderSource);
    gl.compileShader(fragmentShader);
    if (!gl.getShaderParameter(fragmentShader, COMPILE_STATUS)) {
      throw "fragment shader error: "+ gl.getShaderInfoLog(fragmentShader);
    }
    
    program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, LINK_STATUS)) {
      throw "Could not initialise shaders.";
    }

    vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition");
    gl.enableVertexAttribArray(vertexPositionAttribute);
    
    colorAttribute = gl.getAttribLocation(program, "aColor");
    if(colorAttribute > 0)
      gl.enableVertexAttribArray(colorAttribute);
    
    textureCoordAttribute = gl.getAttribLocation(program, "aTextureCoord");
    if(textureCoordAttribute > 0)
      gl.enableVertexAttribArray(textureCoordAttribute);
    
    samplerUniform = gl.getUniformLocation(program, "uSampler");
  }
}