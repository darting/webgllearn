part of compass;

abstract class Fill {
  equals(Fill fill);
}

class Texture extends Fill {
  
  equals(Fill fill) {
    return false;
  }
}