import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson5.dart';



void main() {
 
  CanvasElement canvas = query('#container');
  
  var screen = new Lesson5(canvas);
  screen.render();
  
}













