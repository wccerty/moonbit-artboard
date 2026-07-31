// SceneGraph Node and NodeType representations.

///|
pub(all) struct ArtboardData {
  width : Double
  height : Double
  background : @shapes.RGBA
} derive(Eq, Debug)

///|
pub(all) struct TextData {
  text : String
  font_size : Double
  font_family : String
  align : String
  style : @shapes.Style
} derive(Eq, Debug)

///|
pub(all) struct ImageData {
  src : String
  width : Double
  height : Double
} derive(Eq, Debug)

///|
pub(all) struct ShapeNodeData {
  geometry : @shapes.ShapeGeometry
  style : @shapes.Style
} derive(Eq, Debug)

///|
pub(all) enum NodeType {
  ArtboardNode(ArtboardData)
  GroupNode(Array[NodeID])
  ShapeNode(ShapeNodeData)
  TextNode(TextData)
  ImageNode(ImageData)
} derive(Eq, Debug)

///|
pub(all) struct Node {
  id : NodeID
  name : String
  node_type : NodeType
  transform : @math.Matrix2D
  parent_id : NodeID?
  visible : Bool
  locked : Bool
  opacity : Double
  z_index : Int
} derive(Eq, Debug)

///|
pub fn Node::create_shape(
  id : NodeID,
  name : String,
  geometry : @shapes.ShapeGeometry,
  style : @shapes.Style,
) -> Node {
  {
    id,
    name,
    node_type: ShapeNode({ geometry, style }),
    transform: @math.Matrix2D::identity(),
    parent_id: None,
    visible: true,
    locked: false,
    opacity: 1.0,
    z_index: 0,
  }
}

///|
pub fn Node::create_group(
  id : NodeID,
  name : String,
  children : Array[NodeID],
) -> Node {
  {
    id,
    name,
    node_type: GroupNode(children),
    transform: @math.Matrix2D::identity(),
    parent_id: None,
    visible: true,
    locked: false,
    opacity: 1.0,
    z_index: 0,
  }
}

///|
pub fn Node::create_artboard(
  id : NodeID,
  name : String,
  w : Double,
  h : Double,
  bg : @shapes.RGBA,
) -> Node {
  {
    id,
    name,
    node_type: ArtboardNode({ width: w, height: h, background: bg }),
    transform: @math.Matrix2D::identity(),
    parent_id: None,
    visible: true,
    locked: false,
    opacity: 1.0,
    z_index: 0,
  }
}

///|
pub fn Node::create_text(
  id : NodeID,
  name : String,
  text : String,
  font_size : Double,
  font_family : String,
  style : @shapes.Style,
) -> Node {
  {
    id,
    name,
    node_type: TextNode({ text, font_size, font_family, align: "left", style }),
    transform: @math.Matrix2D::identity(),
    parent_id: None,
    visible: true,
    locked: false,
    opacity: 1.0,
    z_index: 0,
  }
}

///|
pub fn Node::create_image(
  id : NodeID,
  name : String,
  src : String,
  w : Double,
  h : Double,
) -> Node {
  {
    id,
    name,
    node_type: ImageNode({ src, width: w, height: h }),
    transform: @math.Matrix2D::identity(),
    parent_id: None,
    visible: true,
    locked: false,
    opacity: 1.0,
    z_index: 0,
  }
}

///|
pub fn Node::local_bounds(self : Node) -> @math.Rect2D {
  match self.node_type {
    ArtboardNode(art) => @math.Rect2D::new(0.0, 0.0, art.width, art.height)
    ShapeNode(s) => s.geometry.to_path().bounds()
    TextNode(t) => {
      let est_width = t.text.length().to_double() * t.font_size * 0.6
      let est_height = t.font_size * 1.2
      @math.Rect2D::new(0.0, 0.0, est_width, est_height)
    }
    ImageNode(img) => @math.Rect2D::new(0.0, 0.0, img.width, img.height)
    GroupNode(_) => @math.Rect2D::empty()
  }
}
