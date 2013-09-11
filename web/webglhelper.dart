import 'dart:json';
import 'dart:web_gl' as gl;

const VertexShaderCode = """
attribute vec3 aVertexPosition;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

void main(void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
}
""";

const FragmentShader = """
precision mediump float;

void main(void) {
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
""";






class Mesh {
  Geometry geometry;
  List<SubMesh> subMeshes;
  
  
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
//  geometry.vertices = new List.generate(vertexCount, (index) {
//    var offset = index * 3;
//    return new Vector3(vertices[offset].toDouble(), vertices[offset + 1].toDouble(), vertices[offset + 2].toDouble());
//  });
  
  geometry.vertices = new List.generate(vertexCount * 3, (index) {
    return vertices[index].toDouble();
  });
  
  var normals = json["geometry"]["normals"];
//  geometry.normals = new List.generate(vertexCount, (index) {
//    var offset = index * 3;
//    return new Vector3(normals[offset].toDouble(), normals[offset + 1].toDouble(), normals[offset + 2].toDouble());
//  });
  geometry.normals = new List.generate(vertexCount * 3, (index) {
    return normals[index].toDouble();
  });
  
  var textureCoords = json["geometry"]["texturecoords"];
//  geometry.textureCoords = new List.generate(vertexCount, (index) {
//    var offset = index * 2;
//    return new Vector2(textureCoords[offset].toDouble(), textureCoords[offset + 1].toDouble());
//  });
  geometry.textureCoords = new List.generate(vertexCount * 2, (index) {
    return textureCoords[index].toDouble();
  });
  
  mesh.geometry = geometry;
  
  var submeshes = json["submeshes"];
  mesh.subMeshes = new List.generate(submeshes.length, (index) {
    var submesh = submeshes[index];
    var sub =  new SubMesh();
    sub.material = submesh["material"];
    
    var faces = submesh["faces"];
//    sub.faces = new List.generate((faces.length / 3).toInt(), (i) {
//      var offset = i * 3;
//      var face = new Face();
//      face.v1 = faces[offset];
//      face.v2 = faces[offset + 1];
//      face.v3 = faces[offset + 2];
//      return face;
//    });
    sub.faces = new List.generate(faces.length, (i) {
      return faces[i].toInt();
    });
    return sub;
  });
  
  return mesh;
}































