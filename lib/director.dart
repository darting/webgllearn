part of compass;


class Director implements Dispose {
  Stats stats;
  CanvasElement _canvas;
  Renderer _renderer;
  Scene _scene;
  
  Director(canvas) {
    stats = new Stats();
    
    _canvas = canvas;
    _renderer = new GLRenderer(canvas);
    _scene = new Scene();
   
    _run();
  }
  
  replaceScene(Scene scene) {
    if(_scene != null) _scene.exit();
    scene.enter();
    _scene = scene;
  }
  
  _run() {
    window.requestAnimationFrame(_animate);
  }
  
  _animate(num elapsed) {
    stats.begin();
    _renderer.nextFrame();
    _scene.render(_renderer);
    _renderer.finishBatch();
    
    stats.end();
    _run();
  }

  dispose() {
    // TODO implement this method
  }
}