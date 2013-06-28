import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson4.dart';



void main() {
 
  CanvasElement canvas = query('#container');
  
  var screen = new Lesson4(canvas);
  screen.render();
  
}













