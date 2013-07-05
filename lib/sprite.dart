part of compass;

class Sprite extends DisplayObject {
  Fill fill;
  
  render(Renderer renderer) {
    renderer.render(this);
  }
}
