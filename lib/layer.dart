part of compass;

class Layer extends DisplayObject {
  List<DisplayObject> children;
  
  Layer() {
    children = [];
  }
  
  addChild(DisplayObject node) {
    node.removeFromParent();
    children.add(node);
  }
  
  removeChild(DisplayObject node) {
    return children.remove(node);
  }
  
  render(Renderer renderer) {
    children.forEach((child) => child.render(renderer));
  }
}