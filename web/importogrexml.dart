import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'webglhelper.dart';
import 'package:vector_math/vector_math.dart';


CanvasElement canvas;
Renderer renderer;

double _rotation = 0.0;
double _lastElapsed = 0.0;

Mesh mesh;


void main() {
  canvas = query('#container');
  renderer = new Renderer(canvas);
  
  var fileUrl = "BOSS_DRAGON.MESH.json";
  HttpRequest.getString(fileUrl).then(startup);
}


startup(String responseData) {
  
  mesh = makeMesh(responseData);
  mesh.init(renderer);
  
  render();
}

void _render(num elapsed) {
  
  _rotation += (2 * (elapsed - _lastElapsed) / 1000.0);
  _lastElapsed = elapsed;
  
  renderer.ctx.viewport(0, 0, canvas.width, canvas.height);
  renderer.ctx.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  
  renderer.resetMatrix();
  
  renderer.mvMatrix.translate(0.0, 0.0, -7.0);
  renderer.mvMatrix.scale(0.3, 0.3, 0.3);
  renderer.mvMatrix.rotateY(_rotation);
  
  mesh.render(renderer);
  
  render();
}


render() {
  window.requestAnimationFrame(_render);
}

































