import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

const VertexShaderCode = """
attribute vec3 aVertexPosition;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

void main(void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
}
""";

const FragmentShader = """
precision mediump float;

void main(void) {
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
""";

void main() {
 
  CanvasElement canvas = query('#container');
  
  // init webgl
  RenderingContext context = canvas.getContext3d(preserveDrawingBuffer: true);
  
  // init shaders
  Shader vertexShader = context.createShader(VERTEX_SHADER);
  context.shaderSource(vertexShader, VertexShaderCode);
  context.compileShader(vertexShader);
  
  Shader fragmentShader = context.createShader(FRAGMENT_SHADER);
  context.shaderSource(fragmentShader, FragmentShader);
  context.compileShader(fragmentShader);
  
  Program program = context.createProgram();
  context.attachShader(program, vertexShader);
  context.attachShader(program, fragmentShader);
  context.linkProgram(program);
  context.useProgram(program);
  
  var vertexPositionAttribute = context.getAttribLocation(program, "aVertexPosition");
  context.enableVertexAttribArray(vertexPositionAttribute);
  
  var pMatrixUniform = context.getUniformLocation(program, "uPMatrix");
  var mvMatrixUniform = context.getUniformLocation(program, "uMVMatrix");
  
  // init buffers
  var triangleVertexPositionBuffer = new Triangle(); 
  triangleVertexPositionBuffer.buffer = context.createBuffer();
  context.bindBuffer(ARRAY_BUFFER, triangleVertexPositionBuffer.buffer);
  var list = [0.0, 1.0, 0.0,
              -1.0, -1.0, 0.0, 
              1.0, -1.0, 0.0];
  Float32List vertices = new Float32List.fromList(list);
  context.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
  triangleVertexPositionBuffer.numItems = 3;
  triangleVertexPositionBuffer.itemSize = 3;


  context.clearColor(0.0, 0.0, 0.0, 1.0);
  context.enable(DEPTH_TEST);

  context.viewport(0, 0, canvas.width, canvas.height);
  context.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  
  context.bindBuffer(ARRAY_BUFFER, triangleVertexPositionBuffer.buffer);
  context.vertexAttribPointer(vertexPositionAttribute, 
      triangleVertexPositionBuffer.itemSize, FLOAT, false, 0, 0);
//  setMatrixUniforms();
  context.drawArrays(TRIANGLES, 0, triangleVertexPositionBuffer.numItems);
  
}



class Triangle {
  int numItems;
  int itemSize;
  Buffer buffer;
}






















