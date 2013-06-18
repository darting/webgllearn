import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'lesson1.dart';
import 'lesson2.dart';



void main() {
 
  CanvasElement canvas = query('#container');
  
  var screen = new Lesson2(canvas);
  
  
  
  
  screen.render();
  
}













