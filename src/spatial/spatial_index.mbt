// Grid Spatial Indexing for viewport culling and spatial queries.

///|
pub(all) struct SpatialItem {
  id : @scenegraph.NodeID
  bounds : @math.Rect2D
} derive(Eq, Debug)

///|
pub(all) struct GridSpatialIndex {
  cell_size : Double
  items : Array[SpatialItem]
} derive(Debug)

///|
pub fn GridSpatialIndex::new(cell_size : Double) -> GridSpatialIndex {
  { cell_size, items: [] }
}

///|
pub fn GridSpatialIndex::insert(
  self : GridSpatialIndex,
  id : @scenegraph.NodeID,
  bounds : @math.Rect2D,
) -> Unit {
  self.items.push({ id, bounds })
}

///|
pub fn GridSpatialIndex::clear(self : GridSpatialIndex) -> Unit {
  self.items.clear()
}

///|
pub fn GridSpatialIndex::query_rect(
  self : GridSpatialIndex,
  query : @math.Rect2D,
) -> Array[@scenegraph.NodeID] {
  let result : Array[@scenegraph.NodeID] = []
  for i = 0; i < self.items.length(); i = i + 1 {
    let item = self.items[i]
    if item.bounds.intersects(query) {
      result.push(item.id)
    }
  }
  result
}

///|
pub fn GridSpatialIndex::build_from_doc(
  doc : @scenegraph.ArtboardDocument,
  cell_size : Double,
) -> GridSpatialIndex {
  let index = GridSpatialIndex::new(cell_size)
  for i = 0; i < doc.root_ids.length(); i = i + 1 {
    let id = doc.root_ids[i]
    let bounds = doc.get_world_bounds(id)
    index.insert(id, bounds)
  }
  index
}
