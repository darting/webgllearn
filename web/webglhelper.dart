import 'dart:html';
import 'dart:json';
import 'dart:math';
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
  
  var s3tc;
  
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
        renderer.ctx.uniform1i(renderer.samplerUniform, 0);
        renderer.ctx.activeTexture(gl.TEXTURE0);
        renderer.ctx.bindTexture(gl.TEXTURE_2D, sub.material.texture);
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
  
  ImageElement _image;
  gl.Texture texture;
  bool compressed = false;
  bool ready = false;
  
  load(Renderer renderer) {
    if(textureSource.endsWith(".DDS"))
      _loadDDS(renderer);
    else
      _loadImage(renderer);
  }

  _loadDDS(Renderer renderer) {
    compressed = true;
    var req = new HttpRequest();
    req.responseType = "arraybuffer";
    req.onLoad.listen((e) {
      texture = renderer.ctx.createTexture();
      renderer.ctx.bindTexture(gl.TEXTURE_2D, texture);

      var dds = parseDDS(req.response, true);
      var mipmapCount = dds["mipmapCount"];
      var mipmaps = dds["mipmaps"];
      for(var i = 0; i < mipmapCount; i++){
        var m = mipmaps[i];
        renderer.ctx.compressedTexImage2D(gl.TEXTURE_2D, i, 
            dds["format"], 
            m["width"].toInt(), m["height"].toInt(), 0, m["data"]);
        
        print([dds["format"], m["width"].toInt(), m["height"].toInt(), 0, m["data"]]);
      }
      
      renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
//      renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, 
//          mipmapCount > 1 ? gl.LINEAR_MIPMAP_LINEAR : gl.LINEAR);
      
      ready = true;
    });
    req.open("GET", textureSource);
    req.send();
  }

  _loadImage(Renderer renderer) {
    _image = new ImageElement(src: textureSource);
    _image.onLoad.listen((e) => _handleTexture(renderer));
  }
  
  _handleTexture(Renderer renderer) {
    texture = renderer.ctx.createTexture();
    renderer.ctx.bindTexture(gl.TEXTURE_2D, texture);
    renderer.ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
    renderer.ctx.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _image);
    renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    renderer.ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    renderer.ctx.generateMipmap(gl.TEXTURE_2D);
    renderer.ctx.bindTexture(gl.TEXTURE_2D, null);
    ready = true;
  }
}
 

parseDDS( buffer, loadMipmaps ) {

  var dds = { "mipmaps": [], "width": 0, "height": 0, "format": null, "mipmapCount": 1 };

  // Adapted from @toji's DDS utils
  //  https://github.com/toji/webgl-texture-utils/blob/master/texture-util/dds.js

  // All values and structures referenced from:
  // http://msdn.microsoft.com/en-us/library/bb943991.aspx/

  var DDS_MAGIC = 0x20534444;

  var DDSD_CAPS = 0x1,
    DDSD_HEIGHT = 0x2,
    DDSD_WIDTH = 0x4,
    DDSD_PITCH = 0x8,
    DDSD_PIXELFORMAT = 0x1000,
    DDSD_MIPMAPCOUNT = 0x20000,
    DDSD_LINEARSIZE = 0x80000,
    DDSD_DEPTH = 0x800000;

  var DDSCAPS_COMPLEX = 0x8,
    DDSCAPS_MIPMAP = 0x400000,
    DDSCAPS_TEXTURE = 0x1000;

  var DDSCAPS2_CUBEMAP = 0x200,
    DDSCAPS2_CUBEMAP_POSITIVEX = 0x400,
    DDSCAPS2_CUBEMAP_NEGATIVEX = 0x800,
    DDSCAPS2_CUBEMAP_POSITIVEY = 0x1000,
    DDSCAPS2_CUBEMAP_NEGATIVEY = 0x2000,
    DDSCAPS2_CUBEMAP_POSITIVEZ = 0x4000,
    DDSCAPS2_CUBEMAP_NEGATIVEZ = 0x8000,
    DDSCAPS2_VOLUME = 0x200000;

  var DDPF_ALPHAPIXELS = 0x1,
    DDPF_ALPHA = 0x2,
    DDPF_FOURCC = 0x4,
    DDPF_RGB = 0x40,
    DDPF_YUV = 0x200,
    DDPF_LUMINANCE = 0x20000;

  fourCCToInt32( value ) {
    return value.codeUnitAt(0) +
      (value.codeUnitAt(1) << 8) +
      (value.codeUnitAt(2) << 16) +
      (value.codeUnitAt(3) << 24);

  }

  int32ToFourCC( value ) {

    return new String.fromCharCodes([
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff
    ]);
  }

  var FOURCC_DXT1 = fourCCToInt32("DXT1");
  var FOURCC_DXT3 = fourCCToInt32("DXT3");
  var FOURCC_DXT5 = fourCCToInt32("DXT5");

  var headerLengthInt = 31; // The header length in 32 bit ints

  // Offsets into the header array

  var off_magic = 0;

  var off_size = 1;
  var off_flags = 2;
  var off_height = 3;
  var off_width = 4;

  var off_mipmapCount = 7;

  var off_pfFlags = 20;
  var off_pfFourCC = 21;

  // Parse header

  var header = new Int32List.view( buffer, 0, headerLengthInt );

  if ( header[ off_magic ] != DDS_MAGIC ) {
      print( "ImageUtils.parseDDS(): Invalid magic number in DDS header" );
      return dds;
  }

  if ( (header[ off_pfFlags ] & DDPF_FOURCC) == 0 ) {
      print( "ImageUtils.parseDDS(): Unsupported format, must contain a FourCC code" );
      return dds;
  }

  var blockBytes;

  var fourCC = header[ off_pfFourCC ];

  if( fourCC == FOURCC_DXT1 ) {
      blockBytes = 8;
      dds["format"] =  gl.CompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT;//   RGB_S3TC_DXT1_Format;
  } else if(fourCC == FOURCC_DXT3) {
      blockBytes = 16;
      dds["format"] = gl.CompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT1_EXT;// RGBA_S3TC_DXT3_Format;
  } else if(fourCC == FOURCC_DXT5) {
      blockBytes = 16;
      dds["format"] = gl.CompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT;// RGBA_S3TC_DXT5_Format;
  } else {
      print( "ImageUtils.parseDDS(): Unsupported FourCC code: ${int32ToFourCC( fourCC )}" );
  }

  dds["mipmapCount"] = 1;

  if ( ( (header[ off_flags ] & DDSD_MIPMAPCOUNT) != 0) && (loadMipmaps != false) ) {
      dds["mipmapCount"] = max( 1, header[ off_mipmapCount ] );
  }

  dds["width"] = header[ off_width ];
  dds["height"] = header[ off_height ];

  var dataOffset = header[ off_size ] + 4;

  // Extract mipmaps buffers

  var width = dds["width"];
  var height = dds["height"];

  for ( var i = 0; i < dds["mipmapCount"]; i ++ ) {

    int dataLength = max( 4, width ) ~/ 4 * max( 4, height ) ~/ 4 * blockBytes;
    var byteArray = new Uint8List.view( buffer, dataOffset, dataLength);

    var mipmap = { "data": byteArray, "width": width, "height": height };
    dds["mipmaps"].add( mipmap );

    dataOffset += dataLength;

    width = max( width * 0.5, 1 );
    height = max( height * 0.5, 1 );

  }

  return dds;
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































