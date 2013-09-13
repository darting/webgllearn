import 'dart:html';
import 'dart:web_gl';


import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';
import 'webglhelper.dart';
import 'dart:math';


Stats stats;
CanvasElement canvas;
Renderer renderer;

double _lastElapsed = 0.0;
double _zoom = 1.0;

List<Mesh> meshs;

void main() {
  canvas = query('#container');
  renderer = new Renderer(canvas);
  renderer.ctx.enable(DEPTH_TEST);
  renderer.ctx.frontFace(CCW);
  renderer.ctx.cullFace(BACK);
  renderer.ctx.enable(CULL_FACE);
  
  var ct = renderer.ctx.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");
  var formats = renderer.ctx.getParameter(COMPRESSED_TEXTURE_FORMATS);
  formats.forEach((f) => print(f));

  requestRender();
  
  
  stats = new Stats();
  document.body.children.add(stats.container);
  document.body.onMouseWheel.listen(mouseWheelHandler);
  
  meshs = [];
  
//  var fileUrl = "BOSS_DRAGON.MESH.json";
//  fileUrl = "NPC_HUF_TOWN_01.MESH.json";
//  fileUrl = "BOX.MESH.json";
  
//  HttpRequest.getString("BOSS_DRAGON.MESH.json").then(addMesh);
//  HttpRequest.getString("NPC_HUF_TOWN_01.MESH.json").then(addMesh);
  HttpRequest.getString("HUM_F.MESH.json").then(addMesh);
}

addMesh(String responseData) {
  var mesh = parseMesh(responseData);
  mesh.init(renderer);
  mesh.x = -2.0 + meshs.length * 5;
  mesh.y = -1.0;
  mesh.z = -7.0;
  meshs.add(mesh);
}

mouseWheelHandler(WheelEvent e) {
  _zoom += e.deltaY / 500;
  _zoom = max(_zoom, 0.0);
}


void _render(num elapsed) {
  requestRender();
  
  stats.begin();
  
  renderer.prepareRender();

  meshs.forEach((e) {
    e.scaleX = _zoom;
    e.scaleY = _zoom;
    e.scaleZ = _zoom;
    e.rotationY += (2 * (elapsed - _lastElapsed) / 1000.0);
    e.render(renderer);
  });
  
  stats.end();
  _lastElapsed = elapsed;
}


requestRender() {
  window.requestAnimationFrame(_render);
}

































