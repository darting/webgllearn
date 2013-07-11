part of compass;

abstract class Fill {
  equals(Fill fill);
}

class Image extends Fill {
  int _width;
  int _height;
  int _frameX;
  int _frameY;
  int _frameWidth;
  int _frameHeight;
  
  html.ImageElement imageData;
  
  Image.fromImageElement(html.ImageElement image) {
    imageData = image;
    _width = image.naturalWidth;
    _height = image.naturalHeight;
    _frameX = 0;
    _frameY = 0;
    _frameWidth = _width;
    _frameHeight = _height;
  }
  
  Image.fromTextureAtlasFrame(TextureAtlasFrame frame) {
    imageData = frame.textureAtlas._image.imageData;
    _width = imageData.naturalWidth;
    _height = imageData.naturalHeight;
    _frameX = frame.frameX;
    _frameY = frame.frameY;
    _frameWidth = frame.frameWidth;
    _frameHeight = frame.frameHeight;
  }
  
  equals(Fill fill) {
    if(fill is Image)
      return imageData == (fill as Image).imageData;
    return false;
  }
  
  int get frameX => _frameX;
  int get frameY => _frameY;
  int get frameWidth => _frameWidth;
  int get frameHeight => _frameHeight;
  int get width => _width;
  int get height => _height;
  
  static Future<Image> load(String url) {
    Completer<Image> completer = new Completer<Image>();

    html.ImageElement imageElement = new html.ImageElement();
    StreamSubscription onLoadSubscription;
    StreamSubscription onErrorSubscription;

    onLoadSubscription = imageElement.onLoad.listen((event) {
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      completer.complete(new Image.fromImageElement(imageElement));
    });

    onErrorSubscription = imageElement.onError.listen((event) {
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      completer.completeError(new StateError("Error loading image."));
    });
    
    imageElement.src = url;
    
    return completer.future;
  }
}

class TextureAtlasFormat {
  static const String JSON = "json";
}

class TextureAtlas {
  Image _image;
  final List<TextureAtlasFrame> _frames = new List<TextureAtlasFrame>();
  
  static Future<TextureAtlas> load(String url) {
    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();
    html.HttpRequest.getString(url).then((textureAtlasJson) {
      var data = json.parse(textureAtlasJson);
      var frames = data["frames"];
      var meta = data["meta"];
      var imageUrl = _replaceFilename(url, meta["image"]);

      if (frames is List) {
        for(var frame in frames) {
          var frameMap = frame as Map;
          var fileName = frameMap["filename"] as String;
          var frameName = _getFilenameWithoutExtension(fileName);
          var taf = new TextureAtlasFrame.fromJson(textureAtlas, frameName, frameMap);
          textureAtlas._frames.add(taf);
        }
      }

      if (frames is Map) {
        for(String fileName in frames.keys) {
          var frameMap = frames[fileName] as Map;
          var frameName = _getFilenameWithoutExtension(fileName);
          var taf = new TextureAtlasFrame.fromJson(textureAtlas, frameName, frameMap);
          textureAtlas._frames.add(taf);
        }
      }

      Image.load(imageUrl).then((Image image) {
        textureAtlas._image = image;
        completer.complete(textureAtlas);
      }).catchError((error) {
        completer.completeError(new StateError("Failed to load image."));
      });

    }).catchError((error) {
      completer.completeError(new StateError("Failed to load json file."));
    });
    
    return completer.future;
  }

  Image getImage(String name) {
    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name == name) {
        return new Image.fromTextureAtlasFrame(frame);
      }
    }
    throw new ArgumentError("TextureAtlasFrame not found: '$name'");
  }

  List<Image> getImages(String namePrefix) {
    var imageList = new List<Image>();
    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name.startsWith(namePrefix)) {
        imageList.add(new Image.fromTextureAtlasFrame(frame));
      }
    }
    return imageList;
  }

  List<String> get frameNames {
    return _frames.map((f) => f.name).toList(growable: false);
  }
  
}

class TextureAtlasFrame {

  final TextureAtlas _textureAtlas;  
  final String _name;
  bool _rotated;
  int _frameX;
  int _frameY;
  int _frameWidth;
  int _frameHeight;

  TextureAtlasFrame.fromJson(TextureAtlas textureAtlas, String name, Map frame) :
    _textureAtlas = textureAtlas,
    _name = name,
    _rotated = _ensureBool(frame["rotated"]){
    if(frame.containsKey("frame")) {
      _frameX = _ensureInt(frame["frame"]["x"]);
      _frameY = _ensureInt(frame["frame"]["y"]);
      _frameWidth = _ensureInt(frame["frame"]["w"]);
      _frameHeight = _ensureInt(frame["frame"]["h"]);
    }else{
      _frameX = _ensureInt(frame["spriteSourceSize"]["x"]);
      _frameY = _ensureInt(frame["spriteSourceSize"]["y"]);
      _frameWidth = _ensureInt(frame["spriteSourceSize"]["w"]);
      _frameHeight = _ensureInt(frame["spriteSourceSize"]["h"]);
    }
  }

  TextureAtlas get textureAtlas => _textureAtlas;
  String get name => _name;
  bool get rotated => _rotated;
  
  int get frameX => _frameX;
  int get frameY => _frameY;
  int get frameWidth => _frameWidth;
  int get frameHeight => _frameHeight;
}













