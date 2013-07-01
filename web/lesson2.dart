import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'common.dart';


class Lesson2 {
  CanvasElement _canvas;
  RenderingContext _gl;
  
  int _vertexPositionAttribute;
  int _vertexColorAttribute;
  UniformLocation _pMatrixUniform;
  UniformLocation _mvMatrixUniform;
  VertexBuffer _triangle;
  VertexBuffer _triangleColor;
  
  Lesson2(c) {
    _canvas = c;
    _gl = _canvas.getContext3d(preserveDrawingBuffer: true);
    
    _initShader();
    _initBuffers();
  }
  
  _initShader(){
    // GLSL
    // 增加varying变量，从VertexShader传递到FragmentShader
    // vColor 会从 triangleColor 的拿到颜色信息，因为VertexShader会对Vertex之间的区域做线性插值
    // 所以 vColor 会被设置为平滑过渡的颜色值
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
    
    // 从VertexShader中拿到vColor的值，然后设置颜色。
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
    
    // 启用aVertexColor属性，在下面将会告诉webgl，在调用VertexShader的时候，这个aVertexColor对应的
    // Buffer是哪个。
    _vertexColorAttribute = _gl.getAttribLocation(program, "aVertexColor");
    _gl.enableVertexAttribArray(_vertexColorAttribute);
    
    _pMatrixUniform = _gl.getUniformLocation(program, "uPMatrix");
    _mvMatrixUniform = _gl.getUniformLocation(program, "uMVMatrix");
  }
  
  _initBuffers(){
    _triangle =  new VertexBuffer();
    _triangle.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _triangle.buffer);
    
    var list = [0.0, 1.0, 0.0,
                -1.0, -1.0, 0.0, 
                1.0, -1.0, 0.0];
    Float32List vertices = new Float32List.fromList(list);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _triangle.numItems = 3;
    _triangle.itemSize = 3;
    
    _triangleColor = new VertexBuffer();
    _triangleColor.buffer = _gl.createBuffer();
    _gl.bindBuffer(ARRAY_BUFFER, _triangleColor.buffer);
    var colors = [
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    ];
    vertices = new Float32List.fromList(colors);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _triangleColor.itemSize = 4;
    _triangleColor.numItems = 3;
  }
  
  render(){
    _gl.viewport(0, 0, _canvas.width, _canvas.height);
    _gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
    
    var pMatrix = makePerspectiveMatrix(radians(45.0), _canvas.width / _canvas.height, 0.1, 100.0);
    
    var mvMatrix = new Matrix4.identity();
    mvMatrix.translate(-1.5, 0.0, -7.0);
    
    _gl.bindBuffer(ARRAY_BUFFER, _triangle.buffer);
    _gl.vertexAttribPointer(_vertexPositionAttribute, _triangle.itemSize, FLOAT, false, 0, 0);
    
    // 设置vertexColor的属性点对应的Buffer数据
    _gl.bindBuffer(ARRAY_BUFFER, _triangleColor.buffer);
    _gl.vertexAttribPointer(_vertexColorAttribute, _triangleColor.itemSize, FLOAT, false, 0, 0);
    
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    pMatrix.copyIntoArray(tmp);
    _gl.uniformMatrix4fv(_pMatrixUniform, false, tmp);
    mvMatrix.copyIntoArray(tmp);
    _gl.uniformMatrix4fv(_mvMatrixUniform, false, tmp);
    
    _gl.drawArrays(TRIANGLES, 0, _triangle.numItems);
  }
}












































