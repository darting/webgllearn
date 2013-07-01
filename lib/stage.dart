part of compass;

class Stage {
  CanvasElement canvas;
  int width, height;
  List<DisplayObject> children;
  WebGLRenderer renderer;
  Stats stats;
  
  Stage(CanvasElement canvas) {
    stats = new Stats();
    this.canvas = canvas;
    width = canvas.width;
    height = canvas.height;
    children = [];
    renderer = new WebGLRenderer(canvas);
  }
  
  addChild(DisplayObject child) {
    child.stage = this;
    child.onAddedToStage();
    children.add(child);
  }
  
  run() {
    window.requestAnimationFrame(_render);
  }
  
  void _render(num elapsed) {
    stats.begin();
    renderer.render(this);
    stats.end();
    run();
  }
}