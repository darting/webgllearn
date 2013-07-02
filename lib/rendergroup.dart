part of compass;

class RenderGroup {
  WebGLRenderer renderer;
  List<WebGLBatch> batchs;
  
  RenderGroup(this.renderer) {
    batchs = [];
  }
  
  addDisplayObjectAndChildren(child) {
    addDisplayObject(child);
    if(child is DisplayObjectContainer)
      child.children.forEach((e) => addDisplayObjectAndChildren(e));
  }
  
  addDisplayObject(DisplayObject child) {
    if(child.renderGroup != null) child.renderGroup.removeDisplayObjectAndChildren(child);
    child.renderGroup = this;
    child.batch = renderer.getBatch();
    child.batch.displayObjects.add(child);
    child.batch.grow();
    batchs.add(child.batch);
  }
  
  removeDisplayObjectAndChildren(displayObject) {
    removeDisplayObject(displayObject);
    if(displayObject is DisplayObjectContainer)
      displayObject.children.forEach((e) => removeDisplayObjectAndChildren(e));
  }
  
  removeDisplayObject(DisplayObject displayObject) {
    displayObject.renderGroup = null;
    displayObject.batch.displayObjects.remove(displayObject);
    displayObject.batch.dirty = true;
    batchs.remove(displayObject.batch);
    renderer.returnBatch(displayObject.batch);
  }
  
  render(projectionMatrix) {
    renderer.updateTextures();
    RenderingContext gl = renderer.gl;
    gl.uniformMatrix4fv(renderer.mvMatrixUniform, false, projectionMatrix);
    batchs.forEach((batch) => batch.render());
  }
  
  renderSpecific(displayObject, projectionMatrix) {
    renderer.updateTextures();
    RenderingContext gl = renderer.gl;
    gl.uniformMatrix4fv(renderer.mvMatrixUniform, false, projectionMatrix);
    
    //TODO ?
  }
}















