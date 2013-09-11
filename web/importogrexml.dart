import 'dart:html';
import 'dart:web_gl';

import 'webglhelper.dart';
import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';


Stats stats;
CanvasElement canvas;
Renderer renderer;

double _rotation = 0.0;
double _lastElapsed = 0.0;

Mesh mesh;


void main() {
  canvas = query('#container');
  renderer = new Renderer(canvas);
  
  stats = new Stats();
  document.body.children.add(stats.container);
  
  var fileUrl = "BOSS_DRAGON.MESH.json";
  fileUrl = "NPC_HUF_TOWN_01.MESH.json";
//  fileUrl = "BOX.MESH.json";
  HttpRequest.getString(fileUrl).then(startup);
}


startup(String responseData) {
  
  mesh = makeMesh(responseData);
  mesh.init(renderer);
  renderer.ctx.enable(DEPTH_TEST);
  render();
}

void _render(num elapsed) {
  stats.begin();
  
  _rotation += (2 * (elapsed - _lastElapsed) / 1000.0);
  _lastElapsed = elapsed;
  
  renderer.ctx.viewport(0, 0, canvas.width, canvas.height);
  renderer.ctx.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  
  renderer.resetMatrix();
  
  renderer.mvMatrix.translate(0.0, 0.0, -7.0);
//  renderer.mvMatrix.scale(0.3, 0.3, 0.3);
  renderer.mvMatrix.rotateY(_rotation);
  
  mesh.render(renderer);
  
  stats.end();
  render();
}


render() {
  window.requestAnimationFrame(_render);
}

































