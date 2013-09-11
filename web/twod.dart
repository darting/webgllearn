import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';


class TwoD {
  CanvasElement _canvas;
  RenderingContext _gl;
  int _vertexPositionAttribute;
  UniformLocation _pMatrixUniform;
  UniformLocation _mvMatrixUniform;
  Triangle _triangleVertexPositionBuffer;
  
  Lesson1(c){
    _canvas = c;
    _gl = _canvas.getContext3d(preserveDrawingBuffer: true);
    
    _initShaders();
    _initBuffers();

    // 对WebGL进行了一些基本的设置，
    // 具体的含义是当我们清空canvas时应当把颜色设置为黑色，
    // 并且要启用深度检测（这样在后面的物体就会被前面的物体遮挡住）
    _gl.clearColor(0.0, 0.0, 0.0, 1.0);
    _gl.enable(DEPTH_TEST);
  }

  _initShaders(){
    // GLSL
    const VertexShaderCode = """
    attribute vec3 aVertexPosition;
    
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    
    void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
    }
    """;
    
    // 告诉显卡我们需要精确到浮点值的数字运算
    // 然后指定绘制物体的时候要用白色
    const FragmentShader = """
    precision mediump float;
    
    void main(void) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    }
    """;
    
    // 创建 Vertex Shader， 并将 Shader 的代码传递到webgl编译成显卡可以运行的形式
    // 这是一个顶点着色器，你也许会记得它的作用是让显卡对顶点做任何想要做的事
    Shader vertexShader = _gl.createShader(VERTEX_SHADER);
    _gl.shaderSource(vertexShader, VertexShaderCode);
    _gl.compileShader(vertexShader);
    
    // 创建 Fragment Shader， 并将 Shader 的代码传递到webgl编译成显卡可以运行的形式
    Shader fragmentShader = _gl.createShader(FRAGMENT_SHADER);
    _gl.shaderSource(fragmentShader, FragmentShader);
    _gl.compileShader(fragmentShader);
    
    Program program = _gl.createProgram();
    _gl.attachShader(program, vertexShader);
    _gl.attachShader(program, fragmentShader);
    _gl.linkProgram(program);
    _gl.useProgram(program);

    // 在顶点着色器编译的代码里有两个uniform变量，叫做uMVMatrix和uPMatrix
    // uniform变量非常有用，因为你可以在着色器之外访问它们，甚至在它们的容器program之外
    // 可以把着色器的program想象成一个对象（面对对象的观念），把uniform变量想象成字段
    // 由于在把属性和数组对象联系到一起的时候，我们在drawScene函数中使用了vertexPositionAttribute，
    // 所以现在可以为每个顶点调用着色器，并且把顶点作为aVertecPosition传递给着色器代码。
    // 在着色器的二进制码的主程序中，顶点位置与模型视图矩阵和投影矩阵相乘，然后把最终顶点位置作为结果输出。
    _vertexPositionAttribute = _gl.getAttribLocation(program, "aVertexPosition");
    _gl.enableVertexAttribArray(_vertexPositionAttribute);
    
    _pMatrixUniform = _gl.getUniformLocation(program, "uPMatrix");
    _mvMatrixUniform = _gl.getUniformLocation(program, "uMVMatrix");
    
    // 总结一下，initShaders 载入片元着色器和顶点着色器，
    // 他们被编译并传送给WebGL，然后提供给稍后进行的3D场景渲染时使用。
  }
  
  _initBuffers(){
    _triangleVertexPositionBuffer = new Triangle(); 
    // 我们创建了一个数组对象来储存三角形的顶点位置
    _triangleVertexPositionBuffer.buffer = _gl.createBuffer();
    
    //告诉WebGL要为下面的操作指定一个数组对象
    _gl.bindBuffer(ARRAY_BUFFER, _triangleVertexPositionBuffer.buffer);
    
    //创建了一个Float32List对象，然后告诉WebGL用它来填充当前数组对象
    var list = [0.0, 1.0, -6.0,
                -1.0, -1.0, -6.0, 
                1.0, -1.0, -6.0];
    Float32List vertices = new Float32List.fromList(list);
    _gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);
    _triangleVertexPositionBuffer.numItems = 3;
    _triangleVertexPositionBuffer.itemSize = 3;
  }
  
  render(){
    // 首先要使用viewport函数来告诉WebGL一些canvas的尺寸信息
    _gl.viewport(0, 0, _canvas.width, _canvas.height);
    // 我们清空canvas，开始准备绘制
    _gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
    
    // 我们建立一个用于观测场景的透视图。
    // 在默认的情况下，WebGL会把近处的物体和远处的物体用同样的尺寸绘制（在3D图形学中被称为“正射投影”）。
    // 为了使远处的物体看起来要小一些，我们需要明确告诉WebGL我们使用的透视。
    // 对于这个场景，我们告诉WebGL我们的（垂直）视野是45°、canvas的宽高比以及从我们的视点看到的最近距离是0.1个单位，最远距离是100个单位。
    var pMatrix = makePerspectiveMatrix(radians(45.0), _canvas.width / _canvas.height, 0.1, 100.0);
    
    // 现在我们已经建立起了透视，我们可以继续绘制工作了。
    // 第一步是“移动”到3D场景的中心。
    var mvMatrix = new Matrix4.identity();
    // 位移的起点就是3D空间的中心，我们先向左移动1.5个单位（即X轴的负半轴），然后向场景内部移动7个单位（即Z轴的负半轴）
    mvMatrix.translate(-1.5, 0.0, -7.0);
    
    // 调用gl.bindBuffer来将其指定为当前数组对象
    _gl.bindBuffer(ARRAY_BUFFER, _triangleVertexPositionBuffer.buffer);
    // 然后告诉WebGL这个数组对象中的值是用来表示顶点位置的
    // 此 函数告诉WebGL我们的数据是什么格式
    // 1) 
    // 2) 这个值表示了每个坐标有几个数字。我们现在是3，是因为是3d坐标(x,y,z).如果我们使用2d绘制，不加入深度(就是z),我们只要在这里写2就可以了。
    // 3) 意味着我们用float点值。 您也可以使用整数值，但最好习惯3D世界的浮点运算。
    // 4) 
    // 5) 这个stride告诉 WebGL 在每个坐标之间忽略哪几个点
    // 6) 
    _gl.vertexAttribPointer(_vertexPositionAttribute, 
        _triangleVertexPositionBuffer.itemSize, 
        FLOAT, 
        false, 
        0, 0);
    
    // 告知 webgl 当前对象的模型视图矩阵
    // 使用我们在initShaders中得到的储存模型视图矩阵和投影矩阵的uniform变量，我们把变量值从Javascript风格的矩阵推送到WebGL当中去。
    // 即设置uniform变量，然后通过 vertex shader 来变换矩阵
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    pMatrix.copyIntoArray(tmp);
    _gl.uniformMatrix4fv(_pMatrixUniform, false, tmp);
    mvMatrix.copyIntoArray(tmp);
    _gl.uniformMatrix4fv(_mvMatrixUniform, false, tmp);
    
    // 命令 webgl 用之前告诉它的顶点数组和矩阵绘制一个三角形
    // 3) 这将告诉WebGL在我们的数组中有多少顶点需要被绘制。
    //    比如说，我们绘制一个三角形，所以至少要3点，一个平方形需要4点，一个线需要2点（或更多），一个点需要一个（或者多点）
    _gl.drawArrays(TRIANGLES, 0, _triangleVertexPositionBuffer.numItems);
  }
}


class Triangle {
  int numItems;
  int itemSize;
  Buffer buffer;
}










