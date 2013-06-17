import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'firsttriangle.dart';



void main() {
 
  CanvasElement canvas = query('#container');
  
  var screen = new FirstTriangle(canvas);
  
  
  
  
  screen.render();
  
}













