part of compass;

abstract class Fill {
  equals(Fill fill);
}

class Image extends Fill {
  static final Map<String, Image> _cache = new Map<String, Image>();
  
  final String src;
  ImageElement imageData;
  EventDispatcher onReady;
  
  factory Image(String src) {
    if(_cache.containsKey(src))
      return _cache[src];
    else{
      final image = new Image._internal(src);
      _cache[src] = image;
      return image;
    }
  }
  
  Image._internal(this.src) {
    onReady = new EventDispatcher(this);
    imageData = new ImageElement(src: src);
    imageData.onLoad.listen((e) => onReady.dispatch());
  }
  
  equals(Fill fill) {
    if(fill is Image)
      return src == (fill as Image).src;
    return false;
  }
}

class TextureAtlas {
  Image _image;
  Map<String, Rectangle> _regions;
  Map<String, Rectangle> _frames;
  
  TextureAtlas(Image image, XmlElement atlasXml) {
    _image = image;
    _regions = new Map<String, Rectangle>();
    _frames = new Map<String, Rectangle>();
    _parseAtlasXml(atlasXml);
  }
  
  _parseAtlasXml(XmlElement atlasXml) {
    
  }
  
}














