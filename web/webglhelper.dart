import 'dart:html';
import 'dart:json';
import 'dart:typed_data';
import 'dart:web_gl' as gl;
import 'package:vector_math/vector_math.dart';

const VertexShaderCode = """
attribute vec3 aVertexPosition;
attribute highp vec3 aVertexNormal;

uniform mat4 uNormalMatrix;
uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

varying highp vec3 vLighting;

void main(void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

    //apply lighting effect
    highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
    highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
    highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);

    highp vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
    highp float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
    vLighting = ambientLight + (directionalLightColor * directional);
}
""";

const FragmentShader = """
precision mediump float;

varying highp vec3 vLighting;

void main(void) {
    gl_FragColor = vec4(vec3(1.0, 0.0, 0.0) * vLighting, 1.0);
}
""";



class Renderer {
  CanvasElement canvas;
  gl.RenderingContext ctx;
  int vertexPositionAttribute;
  int vertexNormalAttribute;
  gl.UniformLocation pMatrixUniform;
  gl.UniformLocation mvMatrixUniform;
  gl.UniformLocation uNormalMatrix;
  Matrix4 pMatrix;
  Matrix4 mvMatrix;
  
  Renderer(this.canvas) {
    ctx = canvas.getContext3d(preserveDrawingBuffer: true);
    initShader();
    resetMatrix();
  }
  
  initShader() {
    gl.Shader vertexShader = ctx.createShader(gl.VERTEX_SHADER);
    ctx.shaderSource(vertexShader, VertexShaderCode);
    ctx.compileShader(vertexShader);

    gl.Shader fragmentShader = ctx.createShader(gl.FRAGMENT_SHADER);
    ctx.shaderSource(fragmentShader, FragmentShader);
    ctx.compileShader(fragmentShader);
    
    gl.Program program = ctx.createProgram();
    ctx.attachShader(program, vertexShader);
    ctx.attachShader(program, fragmentShader);
    ctx.linkProgram(program);
    ctx.useProgram(program);

    vertexPositionAttribute = ctx.getAttribLocation(program, "aVertexPosition");
    ctx.enableVertexAttribArray(vertexPositionAttribute);
    
    vertexNormalAttribute = ctx.getAttribLocation(program, "aVertexNormal");
    ctx.enableVertexAttribArray(vertexNormalAttribute);
    
    pMatrixUniform = ctx.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = ctx.getUniformLocation(program, "uMVMatrix");
    uNormalMatrix = ctx.getUniformLocation(program, "uNormalMatrix");
  }
  
  resetMatrix() {
    pMatrix = makePerspectiveMatrix(radians(45.0), canvas.width / canvas.height, 0.1, 100.0);
    mvMatrix = new Matrix4.identity();
  }
  
  setMatrixUniforms() {
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    pMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(pMatrixUniform, false, tmp);
    
    mvMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(mvMatrixUniform, false, tmp);
    
    var normalMatrix = new Matrix4.zero();
    normalMatrix.copyInverse(mvMatrix);
    normalMatrix.transpose();
    normalMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(uNormalMatrix, false, tmp);
  }
}


class Mesh {
  Geometry _geometry;
  List<SubMesh> subMeshes;
  
  init(Renderer renderer){
    _geometry.vertexBuffer = renderer.ctx.createBuffer();
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.vertexBuffer);
    renderer.ctx.bufferDataTyped(gl.ARRAY_BUFFER, new Float32List.fromList(_geometry.vertices), gl.STATIC_DRAW);
    
    _geometry.normalBuffer = renderer.ctx.createBuffer();
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.normalBuffer);
    renderer.ctx.bufferDataTyped(gl.ARRAY_BUFFER, new Float32List.fromList(_geometry.normals), gl.STATIC_DRAW);
    
    subMeshes.forEach((sub) {
      sub.faceBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sub.faceBuffer);
      renderer.ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(sub.faces), gl.STATIC_DRAW);
    });
  }
  
  render(Renderer renderer) {
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.vertexBuffer);
    renderer.ctx.vertexAttribPointer(renderer.vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
    
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.normalBuffer);
    renderer.ctx.vertexAttribPointer(renderer.vertexNormalAttribute, 3, gl.FLOAT, false, 0, 0);
    
    subMeshes.forEach((sub) {
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sub.faceBuffer);
      renderer.setMatrixUniforms();
      renderer.ctx.drawElements(gl.TRIANGLES, sub.faces.length, gl.UNSIGNED_SHORT, 0);
    });
  }
}

class SubMesh {
  String material;
  List<int> faces;
  gl.Buffer faceBuffer;
}

class Geometry {
  List<double> vertices;
  List<double> normals;
  List<double> textureCoords;
  
  gl.Buffer vertexBuffer;
  gl.Buffer normalBuffer;
}

class Face {
  int v1;
  int v2;
  int v3;
}

/**
 * 
 * var mesh = {
 *   geometry : {
 *      vertexcount : int,
 *      vertices : [x, y, z, x, y, z ...],
 *      normals : [x, y, z, x, y, z ...],
 *      texturecoords : [u, v, u, v ...]
 *   },
 *   
 *   submeshes : [
 *     {
 *      material: string,
 *      faces : [v1, v2, v3, v1, v2, v3 ...] 
 *     },
 *     ...
 *   ]
 * }
 * 
 */ 
Mesh makeMesh(String jsonStr) {
  var json = parse(jsonStr);
  
  var mesh = new Mesh();
  
  var vertexCount = json["geometry"]["vertexcount"];
  
  var geometry = new Geometry();
  
  var vertices = json["geometry"]["vertices"];
  geometry.vertices = new List.generate(vertices.length, (index) {
    return vertices[index].toDouble();
  });
  
  var normals = json["geometry"]["normals"];
  geometry.normals = new List.generate(normals.length, (index) {
    return normals[index].toDouble();
  });
  
  var textureCoords = json["geometry"]["texturecoords"];
  geometry.textureCoords = new List.generate(textureCoords.length, (index) {
    return textureCoords[index].toDouble();
  });
  
  mesh._geometry = geometry;
  
  var submeshes = json["submeshes"];
  mesh.subMeshes = new List.generate(submeshes.length, (index) {
    var submesh = submeshes[index];
    var sub =  new SubMesh();
    sub.material = submesh["material"];
    
    var faces = submesh["faces"];
    sub.faces = new List.generate(faces.length, (i) {
      return faces[i].toInt();
    });
    return sub;
  });
  
  return mesh;
}































