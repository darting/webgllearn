part of compass;

class Layer extends DisplayObject {
  List<DisplayObject> children;
  
  Layer() {
    children = [];
  }
  
  addChild(DisplayObject node) {
    node.removeFromParent();
    node.parent = this;
    children.add(node);
  }
  
  removeChild(DisplayObject node) {
    if(children.remove(node)){
      node.parent = null;
    }
  }
  
  render(Renderer renderer) {
    children.forEach((child) => child.render(renderer));
  }
}