// Uniform grid indexing for viewport culling and spatial queries.

///|
pub(all) struct SpatialItem {
  id : @scenegraph.NodeID
  bounds : @math.Rect2D
} derive(Eq, Debug)

///|
pub(all) struct GridSpatialIndex {
  cell_size : Double
  items : Array[SpatialItem]
  buckets : Map[String, Array[@scenegraph.NodeID]]
  item_cells : Map[String, Array[String]]
  mut last_stats : SpatialIndexStats
} derive(Debug)

///|
pub(all) struct SpatialIndexStats {
  item_count : Int
  bucket_count : Int
  candidate_count : Int
  hit_count : Int
} derive(Eq, Debug)

///|
fn empty_stats() -> SpatialIndexStats {
  { item_count: 0, bucket_count: 0, candidate_count: 0, hit_count: 0 }
}

///|
fn floor_cell(value : Double) -> Int {
  let truncated = value.to_int()
  if value < truncated.to_double() {
    truncated - 1
  } else {
    truncated
  }
}

///|
fn cell_key(x : Int, y : Int) -> String {
  x.to_string() + ":" + y.to_string()
}

///|
fn covered_cells(cell_size : Double, bounds : @math.Rect2D) -> Array[String] {
  if bounds.is_empty() {
    []
  } else {
    let corners = bounds.corners()
    let min_x = floor_cell(corners[0].x / cell_size)
    let min_y = floor_cell(corners[0].y / cell_size)
    let max_x = floor_cell(corners[2].x / cell_size)
    let max_y = floor_cell(corners[2].y / cell_size)
    let result : Array[String] = []
    for x = min_x; x <= max_x; x = x + 1 {
      for y = min_y; y <= max_y; y = y + 1 {
        result.push(cell_key(x, y))
      }
    }
    result
  }
}

///|
fn remove_id_from_bucket(
  index : GridSpatialIndex,
  key : String,
  id : @scenegraph.NodeID,
) -> Unit {
  match index.buckets.get(key) {
    None => ()
    Some(ids) => {
      let kept : Array[@scenegraph.NodeID] = []
      for i = 0; i < ids.length(); i = i + 1 {
        if ids[i] != id {
          kept.push(ids[i])
        }
      }
      if kept.is_empty() {
        index.buckets.remove(key)
      } else {
        index.buckets[key] = kept
      }
    }
  }
}

///|
fn add_id_to_bucket(
  index : GridSpatialIndex,
  key : String,
  id : @scenegraph.NodeID,
) -> Unit {
  match index.buckets.get(key) {
    None => index.buckets[key] = [id]
    Some(ids) => if !ids.contains(id) { ids.push(id) }
  }
}

///|
pub fn GridSpatialIndex::new(cell_size : Double) -> GridSpatialIndex {
  {
    cell_size: if cell_size <= 0.0 {
      1.0
    } else {
      cell_size
    },
    items: [],
    buckets: Map([]),
    item_cells: Map([]),
    last_stats: empty_stats(),
  }
}

///|
pub fn GridSpatialIndex::insert(
  self : GridSpatialIndex,
  id : @scenegraph.NodeID,
  bounds : @math.Rect2D,
) -> Unit {
  ignore(self.remove(id))
  let item = { id, bounds }
  let cells = covered_cells(self.cell_size, bounds)
  self.items.push(item)
  self.item_cells[id.value] = cells
  for i = 0; i < cells.length(); i = i + 1 {
    add_id_to_bucket(self, cells[i], id)
  }
}

///|
pub fn GridSpatialIndex::remove(
  self : GridSpatialIndex,
  id : @scenegraph.NodeID,
) -> Bool {
  match self.item_cells.get(id.value) {
    None => false
    Some(cells) => {
      for i = 0; i < cells.length(); i = i + 1 {
        remove_id_from_bucket(self, cells[i], id)
      }
      self.item_cells.remove(id.value)
      let kept : Array[SpatialItem] = []
      let mut removed = false
      for i = 0; i < self.items.length(); i = i + 1 {
        if self.items[i].id == id {
          removed = true
        } else {
          kept.push(self.items[i])
        }
      }
      self.items.clear()
      for i = 0; i < kept.length(); i = i + 1 {
        self.items.push(kept[i])
      }
      removed
    }
  }
}

///|
pub fn GridSpatialIndex::update(
  self : GridSpatialIndex,
  id : @scenegraph.NodeID,
  bounds : @math.Rect2D,
) -> Bool {
  match self.item_cells.get(id.value) {
    None => false
    Some(_) => {
      ignore(self.remove(id))
      self.insert(id, bounds)
      true
    }
  }
}

///|
pub fn GridSpatialIndex::clear(self : GridSpatialIndex) -> Unit {
  self.items.clear()
  self.buckets.clear()
  self.item_cells.clear()
  self.last_stats = empty_stats()
}

///|
pub fn GridSpatialIndex::query_rect(
  self : GridSpatialIndex,
  query : @math.Rect2D,
) -> Array[@scenegraph.NodeID] {
  self.query_rect_with_stats(query).0
}

///|
pub fn GridSpatialIndex::query_rect_with_stats(
  self : GridSpatialIndex,
  query : @math.Rect2D,
) -> (Array[@scenegraph.NodeID], SpatialIndexStats) {
  let candidate_ids : Map[String, Bool] = Map([])
  let cells = covered_cells(self.cell_size, query)
  for i = 0; i < cells.length(); i = i + 1 {
    match self.buckets.get(cells[i]) {
      None => ()
      Some(ids) =>
        for j = 0; j < ids.length(); j = j + 1 {
          candidate_ids[ids[j].value] = true
        }
    }
  }
  let result : Array[@scenegraph.NodeID] = []
  for i = 0; i < self.items.length(); i = i + 1 {
    let item = self.items[i]
    match candidate_ids.get(item.id.value) {
      None => ()
      Some(_) => if item.bounds.intersects(query) { result.push(item.id) }
    }
  }
  let stats = {
    item_count: self.items.length(),
    bucket_count: self.buckets.length(),
    candidate_count: candidate_ids.length(),
    hit_count: result.length(),
  }
  self.last_stats = stats
  (result, stats)
}

///|
pub fn GridSpatialIndex::stats(self : GridSpatialIndex) -> SpatialIndexStats {
  {
    item_count: self.items.length(),
    bucket_count: self.buckets.length(),
    candidate_count: self.last_stats.candidate_count,
    hit_count: self.last_stats.hit_count,
  }
}

///|
pub fn GridSpatialIndex::build_from_doc(
  doc : @scenegraph.ArtboardDocument,
  cell_size : Double,
) -> GridSpatialIndex {
  let index = GridSpatialIndex::new(cell_size)
  let entries = doc.traverse()
  for i = 0; i < entries.length(); i = i + 1 {
    let entry = entries[i]
    if !entry.world_bounds.is_empty() {
      index.insert(entry.id, entry.world_bounds)
    }
  }
  index
}
