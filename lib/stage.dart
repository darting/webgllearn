part of compass;

class Stage extends DisplayObjectContainer{
  CanvasElement canvas;
  int width, height;
  List<DisplayObject> children;
  WebGLRenderer renderer;
  Stats stats;
  

  InteractionManager interactionManager;
  Color backgroundColor;
  
  Stage(CanvasElement canvas) {
    stats = new Stats();
    this.canvas = canvas;
    width = canvas.width;
    height = canvas.height;
    children = [];
    renderer = new WebGLRenderer(width, height, canvas);
    
    stage = this;
    worldTransform = new Matrix3.identity();
    hitArea = new Rect(0, 0, 100000, 100000);
    dirty = true;
    _interactive = true;
    interactionManager = new InteractionManager(this);
    worldAlpha = 1.0;
  }
  
  updateTransform() {
    worldAlpha = 1.0;
    children.forEach((child) => child.updateTransform());
    if(dirty){
      dirty = false;
      interactionManager.dirty = true;
    }
    if(_interactive) interactionManager.update();
  }
  
  replaceStage(child) {
    if(child.dirty) dirty = true;
    child.stage = this;
    if(child is DisplayObjectContainer)
      child.children.forEach((e) => replaceStage(e));
  }
  
  removeStage(child) {
    if(child.interactive) dirty = true;
    child.stage = null;
    if(child is DisplayObjectContainer)
      child.children.forEach((e) => removeStage(e));
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

  onAddedToStage() {
    // TODO implement this method
  }
}