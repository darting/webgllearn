import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'webglhelper.dart';
import 'package:vector_math/vector_math.dart';


CanvasElement canvas;
RenderingContext _gl;
int _vertexPositionAttribute;
UniformLocation _pMatrixUniform;
UniformLocation _mvMatrixUniform;

double _rotation = 0.0;
double _lastElapsed = 0.0;

Mesh mesh;


void main() {
  canvas = query('#container');
  _gl = canvas.getContext3d(preserveDrawingBuffer: true);
  
  var fileUrl = "BOSS_DRAGON.MESH.json";
  HttpRequest.getString(fileUrl).then(startup);
}


startup(String responseData) {

  initShader();
  
  mesh = makeMesh(responseData);
  
  mesh.geometry.vertexBuffer = _gl.createBuffer();
  _gl.bindBuffer(ARRAY_BUFFER, mesh.geometry.vertexBuffer);
  _gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(mesh.geometry.vertices), STATIC_DRAW);
  
  mesh.subMeshes.forEach((sub) {
    sub.faceBuffer = _gl.createBuffer();
    _gl.bindBuffer(ELEMENT_ARRAY_BUFFER, sub.faceBuffer);
    _gl.bufferDataTyped(ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(sub.faces), STATIC_DRAW);
  });
  
  render();
}

void _render(num elapsed) {
  
  _rotation += (2 * (elapsed - _lastElapsed) / 1000.0);
  _lastElapsed = elapsed;
  
  _gl.viewport(0, 0, canvas.width, canvas.height);
  _gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  
  var pMatrix = makePerspectiveMatrix(radians(45.0), canvas.width / canvas.height, 0.1, 100.0);
  var mvMatrix = new Matrix4.identity();
  
  mvMatrix.translate(0.0, 0.0, -7.0);
  mvMatrix.scale(0.5, 0.5, 0.5);
  mvMatrix.rotateY(_rotation);
  
  _gl.bindBuffer(ARRAY_BUFFER, mesh.geometry.vertexBuffer);
  _gl.vertexAttribPointer(_vertexPositionAttribute, 3, FLOAT, false, 0, 0);
  
  mesh.subMeshes.forEach((sub) {
    _gl.bindBuffer(ELEMENT_ARRAY_BUFFER, sub.faceBuffer);
    _setMatrixUniforms(pMatrix, mvMatrix);
    _gl.drawElements(TRIANGLES, sub.faces.length, UNSIGNED_SHORT, 0);
  });
  
  render();
}

_setMatrixUniforms(pMatrix, mvMatrix) {
  Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
  pMatrix.copyIntoArray(tmp);
  _gl.uniformMatrix4fv(_pMatrixUniform, false, tmp);
  mvMatrix.copyIntoArray(tmp);
  _gl.uniformMatrix4fv(_mvMatrixUniform, false, tmp);
}

render() {
  window.requestAnimationFrame(_render);
}

initShader() {
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
  
  _pMatrixUniform = _gl.getUniformLocation(program, "uPMatrix");
  _mvMatrixUniform = _gl.getUniformLocation(program, "uMVMatrix");
}































