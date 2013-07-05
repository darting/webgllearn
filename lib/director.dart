part of compass;


class Director implements Dispose {
  Stats stats;
  CanvasElement _canvas;
  Renderer _renderer;
  Scene _scene;
  num _lastElapsed;
  int width, height;
  
  static init(CanvasElement canvas) {
    if(director != null) 
      director.dispose();
    director = new Director(canvas);
  }
  
  Director(CanvasElement canvas) {
    stats = new Stats();

    _canvas = canvas;
    width = canvas.width;
    height = canvas.height;
    _lastElapsed = 0;
    _renderer = new GLRenderer(canvas);
    _scene = new Scene();
   
    _run();
  }
  
  replaceScene(Scene scene) {
    if(_scene != null){
      _scene.exit();
    }
    scene.enter();
    _scene = scene;
  }
  
  _run() {
    window.requestAnimationFrame(_animate);
  }
  
  _animate(num elapsed) {
    stats.begin();
    
    var interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _scene.tick(interval);
    
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