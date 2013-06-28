import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'common.dart';


class Lesson4 {
  CanvasElement _canvas;
  RenderingContext _gl;
  
  int _vertexPositionAttribute;
  int _vertexColorAttribute;
  UniformLocation _pMatrixUniform;
  UniformLocation _mvMatrixUniform;
  VertexBuffer _pyramidBuffer;
  VertexBuffer _pyramidColor;
  VertexBuffer _cubeBuffer;
  VertexBuffer _cubeColor;
  VertexBuffer _cubeIndex;
  double _rotation;
  List _mvMatrixStack;
  double _lastElapsed;
  
  Lesson4(c) {
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
    _pyramidBuffer =  new VertexBuffer();
    _pyramidBuffer.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _pyramidBuffer.buffer);
    Float32List vertices = new Float32List.fromList([// Front face
                                                     0.0,  1.0,  0.0,
                                                     -1.0, -1.0,  1.0,
                                                     1.0, -1.0,  1.0,
                                                     
                                                     // Right face
                                                     0.0,  1.0,  0.0,
                                                     1.0, -1.0,  1.0,
                                                     1.0, -1.0, -1.0,
                                                     
                                                     // Back face
                                                     0.0,  1.0,  0.0,
                                                     1.0, -1.0, -1.0,
                                                     -1.0, -1.0, -1.0,
                                                     
                                                     // Left face
                                                     0.0,  1.0,  0.0,
                                                     -1.0, -1.0, -1.0,
                                                     -1.0, -1.0,  1.0]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _pyramidBuffer.itemSize = 3;
    _pyramidBuffer.numItems = 12;
    
    _pyramidColor = new VertexBuffer();
    _pyramidColor.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _pyramidColor.buffer);
    vertices = new Float32List.fromList([
                                        // Front face
                                        1.0, 0.0, 0.0, 1.0,
                                        0.0, 1.0, 0.0, 1.0,
                                        0.0, 0.0, 1.0, 1.0,
                                        
                                        // Right face
                                        1.0, 0.0, 0.0, 1.0,
                                        0.0, 0.0, 1.0, 1.0,
                                        0.0, 1.0, 0.0, 1.0,
                                        
                                        // Back face
                                        1.0, 0.0, 0.0, 1.0,
                                        0.0, 1.0, 0.0, 1.0,
                                        0.0, 0.0, 1.0, 1.0,
                                        
                                        // Left face
                                        1.0, 0.0, 0.0, 1.0,
                                        0.0, 0.0, 1.0, 1.0,
                                        0.0, 1.0, 0.0, 1.0
                                         ]);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _pyramidColor.itemSize = 4;
    _pyramidColor.numItems = 12;
    
    _cubeBuffer = new VertexBuffer();
    _cubeBuffer.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _cubeBuffer.buffer);
    vertices = new Float32List.fromList([
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
    
    _cubeColor = new VertexBuffer();
    _cubeColor.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _cubeColor.buffer);
    List<List<double>> colors2 = [
                                  [1.0, 0.0, 0.0, 1.0],     // Front face
                                  [1.0, 1.0, 0.0, 1.0],     // Back face
                                  [0.0, 1.0, 0.0, 1.0],     // Top face
                                  [1.0, 0.5, 0.5, 1.0],     // Bottom face
                                  [1.0, 0.0, 1.0, 1.0],     // Right face
                                  [0.0, 0.0, 1.0, 1.0],     // Left face
                                  ];
    List<double> unpackedColors = new List.generate(4 * 4 * colors2.length, (int index) {
      return colors2[index ~/ 16][index % 4];
    }, growable: false);
    
    vertices = new Float32List.fromList(unpackedColors);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _cubeColor.itemSize = 4;
    _cubeColor.numItems = 24;
    
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
    
    
    _gl.bindBuffer(ARRAY_BUFFER, _pyramidBuffer.buffer);
    _gl.vertexAttribPointer(_vertexPositionAttribute, _pyramidBuffer.itemSize, FLOAT, false, 0, 0);
    
    _gl.bindBuffer(ARRAY_BUFFER, _pyramidColor.buffer);
    _gl.vertexAttribPointer(_vertexColorAttribute, _pyramidColor.itemSize, FLOAT, false, 0, 0);
    
    _setMatrixUniforms(pMatrix, mvMatrix);
    _gl.drawArrays(TRIANGLES, 0, _pyramidBuffer.numItems);
    
    mvMatrix = _popMVMatrix();
    
    _pushMVMatrix(mvMatrix);
    //square
    mvMatrix.translate(2.0, 0.0, -7.0);
    mvMatrix.rotateX(_rotation);
    _gl.bindBuffer(ARRAY_BUFFER, _cubeBuffer.buffer);
    _gl.vertexAttribPointer(_vertexPositionAttribute, _cubeBuffer.itemSize, FLOAT, false, 0, 0);
 
    _gl.bindBuffer(ARRAY_BUFFER, _cubeColor.buffer);
    _gl.vertexAttribPointer(_vertexColorAttribute, _cubeColor.itemSize, FLOAT, false, 0, 0);
 
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












































