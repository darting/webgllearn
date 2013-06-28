import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'common.dart';


class Lesson3 {
  CanvasElement _canvas;
  RenderingContext _gl;
  
  int _vertexPositionAttribute;
  int _vertexColorAttribute;
  UniformLocation _pMatrixUniform;
  UniformLocation _mvMatrixUniform;
  VertexBuffer _triangle;
  VertexBuffer _triangleColor;
  VertexBuffer _square;
  VertexBuffer _squareColor;
  double _rotation;
  List _mvMatrixStack;
  double _lastElapsed;
  
  Lesson3(c) {
    _canvas = c;
    _gl = _canvas.getContext3d(preserveDrawingBuffer: true);
    
    _rotation = 0.0;
    _mvMatrixStack = [];
    _lastElapsed = 0.0;
    
    _initShader();
    _initBuffers();
  }
  
  _initShader(){
    // GLSL
    const VertexShaderCode = """
    attribute vec3 aVertexPosition;
    attribute vec4 aVertexColor;
  
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
  
    varying vec4 vColor;
  
    void main(void) {
      gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
      vColor = aVertexColor;
    }
    """;
    
    const FragmentShader = """
    precision mediump float;

    varying vec4 vColor;
    
    void main(void) {
        gl_FragColor = vColor;
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
    
    _vertexColorAttribute = _gl.getAttribLocation(program, "aVertexColor");
    _gl.enableVertexAttribArray(_vertexColorAttribute);
    
    _pMatrixUniform = _gl.getUniformLocation(program, "uPMatrix");
    _mvMatrixUniform = _gl.getUniformLocation(program, "uMVMatrix");
  }
  
  _initBuffers(){
    _triangle =  new VertexBuffer();
    _triangle.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _triangle.buffer);
    Float32List vertices = new Float32List.fromList([0.0, 1.0, 0.0,
                                                     -1.0, -1.0, 0.0, 
                                                     1.0, -1.0, 0.0]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _triangle.numItems = 3;
    _triangle.itemSize = 3;
    
    _triangleColor = new VertexBuffer();
    _triangleColor.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _triangleColor.buffer);
    vertices = new Float32List.fromList([
                                         1.0, 0.0, 0.0, 1.0,
                                         0.0, 1.0, 0.0, 1.0,
                                         0.0, 0.0, 1.0, 1.0
                                         ]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _triangleColor.numItems = 3;
    _triangleColor.itemSize = 4;
    
    _square = new VertexBuffer();
    _square.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _square.buffer);
    vertices = new Float32List.fromList([
                                         2.0, 2.0, 0.0,
                                         0.0, 2.0, 0.0,
                                         2.0, 0.0, 0.0,
                                         0.0, 0.0, 0.0,
                                         ]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _square.numItems = 4;
    _square.itemSize = 3;
    
    _squareColor = new VertexBuffer();
    _squareColor.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _squareColor.buffer);
    vertices = new Float32List.fromList([
                                         1.0, 1.0, 0.0, 1.0,
                                         0.0, 1.0, 0.0, 1.0,
                                         0.0, 0.0, 0.0, 1.0,
                                         1.0, 0.0, 0.0, 1.0
                                         ]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _squareColor.numItems = 4;
    _squareColor.itemSize = 4;
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
    //triangle
    mvMatrix.translate(-1.5, 0.0, -7.0);
    mvMatrix.rotateY(_rotation);
    
    
    _gl.bindBuffer(ARRAY_BUFFER, _triangle.buffer);
    _gl.vertexAttribPointer(_vertexPositionAttribute, _triangle.itemSize, FLOAT, false, 0, 0);
    
    _gl.bindBuffer(ARRAY_BUFFER, _triangleColor.buffer);
    _gl.vertexAttribPointer(_vertexColorAttribute, _triangleColor.itemSize, FLOAT, false, 0, 0);
    
    _setMatrixUniforms(pMatrix, mvMatrix);
    _gl.drawArrays(TRIANGLES, 0, _triangle.numItems);
    
    mvMatrix = _popMVMatrix();
    
    _pushMVMatrix(mvMatrix);
    //square
    mvMatrix.translate(-1.5, 0.0, -7.0);
    mvMatrix.rotateX(_rotation);
    _gl.bindBuffer(ARRAY_BUFFER, _square.buffer);
    _gl.vertexAttribPointer(_vertexPositionAttribute, _square.itemSize, FLOAT, false, 0, 0);
    _gl.bindBuffer(ARRAY_BUFFER, _squareColor.buffer);
    _gl.vertexAttribPointer(_vertexColorAttribute, _squareColor.itemSize, FLOAT, false, 0, 0);
    _setMatrixUniforms(pMatrix, mvMatrix);
    _gl.drawArrays(TRIANGLE_STRIP, 0, _square.numItems);
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












































