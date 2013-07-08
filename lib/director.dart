part of compass;


class Director implements Dispose {
  Stats stats;
  html.CanvasElement _canvas;
  Renderer _renderer;
  Scene _scene;
  num _lastElapsed;
  int width, height;
  Color background;
  
    
  
  static init(html.CanvasElement canvas) {
    if(director != null) 
      director.dispose();
    director = new Director._internal(canvas);
  }
  
  Director._internal(html.CanvasElement canvas) {
    stats = new Stats();

    _canvas = canvas;
    width = canvas.width;
    height = canvas.height;
    background = Color.parse(Color.White);
    _lastElapsed = 0;
    _renderer = new WebGLRenderer(canvas);
    _scene = new Scene();
   
    _run();
  }
  
  replace(Scene scene) {
    if(_scene != null){
      _scene.exit();
    }
    scene.enter();
    _scene = scene;
  }
  
  _run() {
    html.window.requestAnimationFrame(_animate);
  }
  
  _animate(num elapsed) {
    stats.begin();

    var caller = new CallerStats("director animate");
    
    var interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _scene.tick(interval);
    
    var c = new CallerStats("nextFrame");
    _renderer.nextFrame();
    c.stop();
    
    c = new CallerStats("scene render");
    _scene.render(_renderer);
    c.stop();
    
    _renderer.finishBatch();
    
    caller.stop();
    
    stats.end();
    
    _run();
  }

  dispose() {
    // TODO implement this method
  }
}