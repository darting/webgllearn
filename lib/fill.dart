part of compass;

abstract class Fill {
  equals(Fill fill);
}

class Image extends Fill {
  static final Map<String, Image> _cache = new Map<String, Image>();
  
  final String src;
  ImageElement imageData;
  
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
    imageData = new ImageElement(src: src);
  }
  
  get onLoad => imageData.onLoad;
  
  equals(Fill fill) {
    if(fill is Image)
      return src == (fill as Image).src;
    return false;
  }
}


