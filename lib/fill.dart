part of compass;

abstract class Fill {
  equals(Fill fill);
}

class Image extends Fill {
  static final Map<String, Image> _cache = new Map<String, Image>();
  
  html.ImageElement imageData;
  EventDispatcher onReady;
  
  Image.fromImageElement(html.ImageElement image) {
    imageData = image;
    onReady = new EventDispatcher(this);
    onReady.dispatch();
  }
  
  equals(Fill fill) {
    if(fill is Image)
      return imageData == (fill as Image).imageData;
    return false;
  }
  
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
  
  static Future<TextureAtlas> load(String url, String textureAtlasFormat) {

    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    switch(textureAtlasFormat) {
      case TextureAtlasFormat.JSON:
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

        break;
    }

    return completer.future;
  }
  
}

class TextureAtlasFrame {

  final TextureAtlas _textureAtlas;  
  final String _name;
  final bool _rotated;
  
  final int _originalWidth;
  final int _originalHeight;
  final int _offsetX;
  final int _offsetY;
  
  final int _frameX;
  final int _frameY;
  final int _frameWidth;
  final int _frameHeight;

  TextureAtlasFrame.fromJson(TextureAtlas textureAtlas, String name, Map frame) :
    _textureAtlas = textureAtlas,
    _name = name,
    _rotated = _ensureBool(frame["rotated"]),
    _originalWidth = _ensureInt(frame["sourceSize"]["w"]),
    _originalHeight = _ensureInt(frame["sourceSize"]["h"]),
    _offsetX = _ensureInt(frame["spriteSourceSize"]["x"]),
    _offsetY = _ensureInt(frame["spriteSourceSize"]["y"]),
    _frameX = _ensureInt(frame["frame"]["x"]),
    _frameY = _ensureInt(frame["frame"]["y"]),
    _frameWidth = _ensureInt(frame["frame"]["w"]),
    _frameHeight = _ensureInt(frame["frame"]["h"]);     

  TextureAtlas get textureAtlas => _textureAtlas;
  String get name => _name;
  bool get rotated => _rotated;
  
  int get frameX => _frameX;
  int get frameY => _frameY;
  int get frameWidth => _frameWidth;
  int get frameHeight => _frameHeight;

  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
  int get originalWidth => _originalWidth;
  int get originalHeight => _originalHeight;
}













