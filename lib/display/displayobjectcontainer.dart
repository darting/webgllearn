part of compass;


abstract class DisplayObjectContainer extends DisplayObject {
  List<DisplayObject> children;
  
  DisplayObjectContainer() {
    children = [];
  }
  
  addChild(child) {
    child.removeFromParent();
    child.parent = this;
    child.childIndex = children.length;
    children.add(child);
    if(stage != null)
      stage.replaceStage(child);
    if(renderGroup != null){
      if(child.renderGroup != null) child.renderGroup.removeDisplayObjectAndChildren(child);
      renderGroup.addDisplayObjectAndChildren(child);
    }
  }
  
  addChildAt(child, index) {
    //TODO
  }
  
  removeChild(child) {
    var index = children.indexOf(child);
    if(index != -1){
      if(stage != null) stage.removeStage(child);
      if(child.renderGroup) child.renderGroup.removeDisplayObjectAndChildren(child);
      child.parent = null;
      children.remove(child);
      for(var i = index; i < children.length; i++){
        children[i].childIndex--;
      }
    }
  }
  
  updateTransform() {
    if(!visible) return;
    super.updateTransform();
    children.forEach((child) => child.updateTransform());
  }
}