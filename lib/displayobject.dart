part of compass;


abstract class DisplayObject {
  Vector2 position = new Vector2(0.0, 0.0);
  Vector2 anchor = new Vector2(0.0, 0.0);
  Vector2 scale = new Vector2(0.0, 0.0);
  num width;
  num height;
  num rotation;
  bool visible = true;
  Stage stage;
  
  onAddedToStage();
}