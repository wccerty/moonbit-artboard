// Vector PDF Adapter generating PDF/X document stream definitions.

///|
pub fn export_to_pdf(doc : @scenegraph.ArtboardDocument) -> String {
  let mut pdf = "%PDF-1.4\n"
  pdf = pdf + "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"
  pdf = pdf + "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n"
  pdf = pdf +
    "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " +
    doc.width.to_string() +
    " " +
    doc.height.to_string() +
    "] /Contents 4 0 R >>\nendobj\n"

  let mut stream = "q\n"
  for i = 0; i < doc.root_ids.length(); i = i + 1 {
    let id = doc.root_ids[i]
    match doc.get_node(id) {
      Some(node) => {
        let m = node.transform
        stream = stream +
          m.a.to_string() +
          " " +
          m.b.to_string() +
          " " +
          m.c.to_string() +
          " " +
          m.d.to_string() +
          " " +
          m.tx.to_string() +
          " " +
          m.ty.to_string() +
          " cm\n"
      }
      None => ()
    }
  }
  stream = stream + "Q\n"

  pdf = pdf +
    "4 0 obj\n<< /Length " +
    stream.length().to_string() +
    " >>\nstream\n" +
    stream +
    "endstream\nendobj\n"
  pdf = pdf + "xref\n0 5\n0000000000 65535 f \n"
  pdf = pdf + "trailer\n<< /Size 5 /Root 1 0 R >>\nstartxref\n300\n%%EOF"
  pdf
}
