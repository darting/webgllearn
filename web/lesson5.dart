import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'common.dart';


class Lesson5 {
  CanvasElement _canvas;
  RenderingContext _gl;
  
  int _vertexPositionAttribute;
  int _vertexTextureAttribute;
  UniformLocation _pMatrixUniform;
  UniformLocation _mvMatrixUniform;
  UniformLocation _samplerUniform;
  VertexBuffer _cubeBuffer;
  VertexBuffer _cubeTextureCoords;
  VertexBuffer _cubeIndex;
  double _rotation;
  List _mvMatrixStack;
  double _lastElapsed;
  Texture _texture;
  
  
  Lesson5(c) {
    _canvas = c;
    _gl = _canvas.getContext3d(preserveDrawingBuffer: true);
    
    _rotation = 0.0;
    _mvMatrixStack = [];
    _lastElapsed = 0.0;
    
    _initShader();
    _initBuffers();
    _initTexture();
  }
  
  _initShader(){
    // GLSL
    // 增加了 aTextureCoord，用于获取UV坐标点
    const VertexShaderCode = """
    attribute vec3 aVertexPosition;
    attribute vec2 aTextureCoord;
  
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    
    varying vec2 vTextureCoord;
  
    void main(void) {
      gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
      vTextureCoord = aTextureCoord;
    }
    """;
    
    // 根据 vTextureCoord 拿到纹理指定点的颜色
    // uSampler 指示用第几号纹理
    const FragmentShader = """
    precision mediump float;
  
    uniform sampler2D uSampler;

    varying vec2 vTextureCoord;
    
    void main(void) {
        gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
    }
    """;
    
    Shader vertexShader = _gl.createShader(VERTEX_SHADER);
    _gl.shaderSource(vertexShader, VertexShaderCode);
    _gl.compileShader(vertexShader);
    
    Shader fragmentShader = _gl.createShader(FRAGMENT_SHADER);
    _gl.shaderSource(fragmentShader, FragmentShader);
    _gl.compileShader(fragmentShader);
    
    Program program = _gl.createProgram();
    _gl.attachShader(program, vertexShader);
    _gl.attachShader(program, fragmentShader);
    _gl.linkProgram(program);
    _gl.useProgram(program);

    _vertexPositionAttribute = _gl.getAttribLocation(program, "aVertexPosition");
    _gl.enableVertexAttribArray(_vertexPositionAttribute);
    
    _vertexTextureAttribute = _gl.getAttribLocation(program, "aTextureCoord");
    _gl.enableVertexAttribArray(_vertexTextureAttribute);
    
    _pMatrixUniform = _gl.getUniformLocation(program, "uPMatrix");
    _mvMatrixUniform = _gl.getUniformLocation(program, "uMVMatrix");
    _samplerUniform = _gl.getUniformLocation(program, "uSampler");
  }
  
  _initBuffers(){
    _cubeBuffer = new VertexBuffer();
    _cubeBuffer.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _cubeBuffer.buffer);
    var vertices = new Float32List.fromList([
                                      // Front face
                                      -1.0, -1.0,  1.0,
                                      1.0, -1.0,  1.0,
                                      1.0,  1.0,  1.0,
                                      -1.0,  1.0,  1.0,
                                      
                                      // Back face
                                      -1.0, -1.0, -1.0,
                                      -1.0,  1.0, -1.0,
                                      1.0,  1.0, -1.0,
                                      1.0, -1.0, -1.0,
                                      
                                      // Top face
                                      -1.0,  1.0, -1.0,
                                      -1.0,  1.0,  1.0,
                                      1.0,  1.0,  1.0,
                                      1.0,  1.0, -1.0,
                                      
                                      // Bottom face
                                      -1.0, -1.0, -1.0,
                                      1.0, -1.0, -1.0,
                                      1.0, -1.0,  1.0,
                                      -1.0, -1.0,  1.0,
                                      
                                      // Right face
                                      1.0, -1.0, -1.0,
                                      1.0,  1.0, -1.0,
                                      1.0,  1.0,  1.0,
                                      1.0, -1.0,  1.0,
                                      
                                      // Left face
                                      -1.0, -1.0, -1.0,
                                      -1.0, -1.0,  1.0,
                                      -1.0,  1.0,  1.0,
                                      -1.0,  1.0, -1.0
                                         ]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _cubeBuffer.itemSize = 3;
    _cubeBuffer.numItems = 24;
    
    // 指定纹理的坐标位置，和别的ArrayBuffer没什么区别
    _cubeTextureCoords = new VertexBuffer();
    _cubeTextureCoords.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _cubeTextureCoords.buffer);
    var coords = [ // Front face
                  0.0, 0.0,
                  1.0, 0.0,
                  1.0, 1.0,
                  0.0, 1.0,
                
                  // Back face
                  1.0, 0.0,
                  1.0, 1.0,
                  0.0, 1.0,
                  0.0, 0.0,
                
                  // Top face
                  0.0, 1.0,
                  0.0, 0.0,
                  1.0, 0.0,
                  1.0, 1.0,
                
                  // Bottom face
                  1.0, 1.0,
                  0.0, 1.0,
                  0.0, 0.0,
                  1.0, 0.0,
                
                  // Right face
                  1.0, 0.0,
                  1.0, 1.0,
                  0.0, 1.0,
                  0.0, 0.0,
                
                  // Left face
                  0.0, 0.0,
                  1.0, 0.0,
                  1.0, 1.0,
                  0.0, 1.0];
    vertices = new Float32List.fromList(coords);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _cubeTextureCoords.itemSize = 2;
    _cubeTextureCoords.numItems = 24;
    
    _cubeIndex = new VertexBuffer();
    _cubeIndex.buffer = _gl.createBuffer();
    _gl.bindBuffer(ELEMENT_ARRAY_BUFFER, _cubeIndex.buffer);
    var cubeVertexIndices = [
                             0, 1, 2,      0, 2, 3,    // Front face
                             4, 5, 6,      4, 6, 7,    // Back face
                             8, 9, 10,     8, 10, 11,  // Top face
                             12, 13, 14,   12, 14, 15, // Bottom face
                             16, 17, 18,   16, 18, 19, // Right face
                             20, 21, 22,   20, 22, 23  // Left face
                             ];
    _gl.bufferData(ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(cubeVertexIndices), STATIC_DRAW);
    _cubeIndex.itemSize = 1;
    _cubeIndex.numItems = 36;
  }
  
  _initTexture() {
    _texture = _gl.createTexture();
    var img = new ImageElement(src: "nehe.gif");
    img.onLoad.listen((e) => _handleTexture(img));
  }
  
  _handleTexture(ImageElement img) {
    // 绑定纹理
    _gl.bindTexture(TEXTURE_2D, _texture);
    // 反转纹理，由于计算机图形系统 的坐标是Y轴向下，而webgl的坐标Y轴向上，所以要反转。
    _gl.pixelStorei(UNPACK_FLIP_Y_WEBGL, 1);
    // 将图片上传到显卡的纹理空间
    // 参数分别是：图片类型，细节层次，图片通道大小，最后是图片本身
    // 要注意图片需要是2的整数倍
    _gl.texImage2D(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, img);
    // 指示纹理的缩放方式，MAG_FILTER 表示放大是怎么放大的。
    // NEAREST 是指无论如何都只使用原始图片，此方法渲染速度最快。
    _gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, NEAREST);
    // 指示纹理缩小时如何缩小
    _gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, NEAREST);
    // 清理当前绑定的纹理。
    _gl.bindTexture(TEXTURE_2D, null);
  }
  
  render(){
    window.requestAnimationFrame(_render);
  }
  
  void _render(num elapsed) {
    _rotation += (5 * (elapsed - _lastElapsed) / 1000.0);
    _lastElapsed = elapsed;
    
    _gl.viewport(0, 0, _canvas.width, _canvas.height);
    _gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
    
    var pMatrix = makePerspectiveMatrix(radians(45.0), _canvas.width / _canvas.height, 0.1, 100.0);
    var mvMatrix = new Matrix4.identity();
    
    
    _pushMVMatrix(mvMatrix);
    
    mvMatrix.translate(2.0, 0.0, -7.0);
    mvMatrix.rotateX(_rotation);
    
    _gl.bindBuffer(ARRAY_BUFFER, _cubeBuffer.buffer);
    _gl.vertexAttribPointer(_vertexPositionAttribute, _cubeBuffer.itemSize, FLOAT, false, 0, 0);
 
    // 绑定纹理坐标的Buffer
    _gl.bindBuffer(ARRAY_BUFFER, _cubeTextureCoords.buffer);
    _gl.vertexAttribPointer(_vertexTextureAttribute, _cubeTextureCoords.itemSize, FLOAT, false, 0, 0);
    // 激活第0号纹理
    _gl.activeTexture(TEXTURE0);
    // 绑定当前纹理
    _gl.bindTexture(TEXTURE_2D, _texture);
    // 将0传递给Shader，告诉Shader使用的是0号纹理
    _gl.uniform1i(_samplerUniform, 0);
  
    // 绘制
    _gl.bindBuffer(ELEMENT_ARRAY_BUFFER, _cubeIndex.buffer);
    _setMatrixUniforms(pMatrix, mvMatrix);
    _gl.drawElements(TRIANGLES, _cubeIndex.numItems, UNSIGNED_SHORT, 0);
    
    mvMatrix = _popMVMatrix();
    
    render();
  }
  
  _setMatrixUniforms(pMatrix, mvMatrix) {
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    pMatrix.copyIntoArray(tmp);
    _gl.uniformMatrix4fv(_pMatrixUniform, false, tmp);
    mvMatrix.copyIntoArray(tmp);
    _gl.uniformMatrix4fv(_mvMatrixUniform, false, tmp);
  }
  
  _pushMVMatrix(Matrix4 mvMatrix) {
    var copy = mvMatrix.clone();
    _mvMatrixStack.add(copy);
  }
  
  _popMVMatrix() {
    return _mvMatrixStack.removeLast();
  }
}












































