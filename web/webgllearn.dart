import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson3.dart';



void main() {
 
  CanvasElement canvas = query('#container');
  
  var screen = new Lesson3(canvas);
  screen.render();
  
}













