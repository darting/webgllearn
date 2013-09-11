import 'dart:html';
import 'dart:json';
import 'dart:typed_data';
import 'dart:web_gl' as gl;
import 'package:vector_math/vector_math.dart';

const VertexShaderCode = """
attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;
attribute highp vec3 aVertexNormal;

uniform mat4 uNormalMatrix;
uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

varying highp vec3 vLighting;
varying vec2 vTextureCoord;

void main(void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

    vTextureCoord = aTextureCoord;

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

uniform sampler2D uSampler;

varying highp vec3 vLighting;

varying vec2 vTextureCoord;

void main(void) {
    vec4 texelColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
    gl_FragColor = vec4(texelColor.rgb * vLighting, 1.0);
}
""";



class Renderer {
  CanvasElement canvas;
  gl.RenderingContext ctx;
  int vertexPositionAttribute;
  int vertexNormalAttribute;
  int vertexTextureAttribute;
  gl.UniformLocation pMatrixUniform;
  gl.UniformLocation mvMatrixUniform;
  gl.UniformLocation uNormalMatrix;
  gl.UniformLocation samplerUniform;
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
    
    vertexTextureAttribute = ctx.getAttribLocation(program, "aTextureCoord");
    ctx.enableVertexAttribArray(vertexTextureAttribute);
    
    pMatrixUniform = ctx.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = ctx.getUniformLocation(program, "uMVMatrix");
    uNormalMatrix = ctx.getUniformLocation(program, "uNormalMatrix");
    samplerUniform = ctx.getUniformLocation(program, "uSampler");
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

    _geometry.textureCoordsBuffer = renderer.ctx.createBuffer();
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.textureCoordsBuffer);
    renderer.ctx.bufferDataTyped(gl.ARRAY_BUFFER, new Float32List.fromList(_geometry.textureCoords), gl.STATIC_DRAW);
    
    subMeshes.forEach((sub) {
      sub.faceBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sub.faceBuffer);
      renderer.ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(sub.faces), gl.STATIC_DRAW);
      sub.material.load(renderer);
    });
  }
  
  render(Renderer renderer) {
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.vertexBuffer);
    renderer.ctx.vertexAttribPointer(renderer.vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
    
    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.normalBuffer);
    renderer.ctx.vertexAttribPointer(renderer.vertexNormalAttribute, 3, gl.FLOAT, false, 0, 0);

    renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, _geometry.textureCoordsBuffer);
    renderer.ctx.vertexAttribPointer(renderer.vertexTextureAttribute, 2, gl.FLOAT, false, 0, 0);
    
    subMeshes.forEach((sub) {
      if(sub.material.ready) {
        renderer.ctx.activeTexture(gl.TEXTURE0);
        renderer.ctx.bindTexture(gl.TEXTURE_2D, sub.material.texture);
        renderer.ctx.uniform1i(renderer.samplerUniform, 0);
        renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sub.faceBuffer);
        renderer.setMatrixUniforms();
        renderer.ctx.drawElements(gl.TRIANGLES, sub.faces.length, gl.UNSIGNED_SHORT, 0);
      }
    });
  }
}

class SubMesh {
  Material material;
  List<int> faces;
  gl.Buffer faceBuffer;
}

class Geometry {
  List<double> vertices;
  List<double> normals;
  List<double> textureCoords;
  
  gl.Buffer vertexBuffer;
  gl.Buffer normalBuffer;
  gl.Buffer textureCoordsBuffer;
}

class Material {
  String name;
  String textureSource;
  List<double> ambient;
  List<double> diffuse;
  List<double> specular;
  List<double> emissive;
  
  ImageElement image;
  gl.Texture texture;
  bool ready = false;
  
  load(Renderer renderer) {
    image = new ImageElement(src: textureSource);
    image.onLoad.listen((e) => _handleTexture(renderer));
  }

  
  _handleTexture(Renderer renderer) {
    texture = renderer.ctx.createTexture();
    // 绑定纹理
    renderer.ctx.bindTexture(gl.TEXTURE_2D, texture);
    // 反转纹理，由于计算机图形系统 的坐标是Y轴向下，而webgl的坐标Y轴向上，所以要反转。
    renderer.ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
    // 将图片上传到显卡的纹理空间
    // 参数分别是：图片类型，细节层次，图片通道大小，最后是图片本身
    // 要注意图片需要是2的整数倍
    renderer.ctx.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
    // 指示纹理的缩放方式，MAG_FILTER 表示放大是怎么放大的。
    // NEAREST 是指无论如何都只使用原始图片，此方法渲染速度最快。
    renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    // 指示纹理缩小时如何缩小
    renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    // 清理当前绑定的纹理。
    renderer.ctx.bindTexture(gl.TEXTURE_2D, null);
    ready = true;
  }
}

/**
 * 
 * var mesh = {
 *   geometry : {
 *      vertexcount : int,
 *      vertices : [x, y, z ...],
 *      normals : [x, y, z ...],
 *      texturecoords : [u, v ...]
 *   },
 *
 *   submeshes : [
 *     {
 *      material: {
 *       name: String,
 *       texture: String,
 *       ambient: [],
 *       specular: [],
 *       diffuse: [],
 *       emissive: []
 *      },
 *      faces : [v1, v2, v3 ...]
 *     },
 *     ...
 *   ]
 * }
 * 
 */ 
Mesh parseMesh(String jsonStr) {
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
    
    var material = submesh["material"];
    sub.material = new Material();
    sub.material.name = material["name"];
    sub.material.textureSource = material["texture"];
    
    var ambient = material["ambient"];
    sub.material.ambient = new List.generate(ambient.length, (i) {
      return ambient[i].toDouble();
    });

    var diffuse = material["diffuse"];
    sub.material.diffuse = new List.generate(diffuse.length, (i) {
      return diffuse[i].toDouble();
    });
    
    var specular = material["specular"];
    sub.material.specular = new List.generate(specular.length, (i) {
      return specular[i].toDouble();
    });
    
    var emissive = material["emissive"];
    sub.material.emissive = new List.generate(emissive.length, (i) {
      return emissive[i].toDouble();
    });
    
    var faces = submesh["faces"];
    sub.faces = new List.generate(faces.length, (i) {
      return faces[i].toInt();
    });
    return sub;
  });
  
  return mesh;
}































