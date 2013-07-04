part of compass;

class Layer extends Node {
  List<Node> children;
  
  Layer() {
    children = [];
  }
  
  addChild(Node node) {
    node.removeFromParent();
    children.add(node);
  }
  
  removeChild(Node node) {
    return children.remove(node);
  }
  
  render(Renderer renderer) {
    children.forEach((child) => child.render(renderer));
  }
}