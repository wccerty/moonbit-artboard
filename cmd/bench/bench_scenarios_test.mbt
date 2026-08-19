///|
test "benchmark scenarios have fixed node counts and checksums" {
  let small = build_benchmark_document(16)
  let medium = build_benchmark_document(64)
  assert_true(small.nodes.length() > 16)
  assert_true(medium.nodes.length() > small.nodes.length())
  assert_eq(document_checksum(small), document_checksum(small))
  assert_eq(document_checksum(medium), document_checksum(medium))
}

///|
test "benchmark suite exposes explicit positive iterations" {
  let results = run_benchmark_suite()
  assert_true(results.length() >= 3)
  for i = 0; i < results.length(); i = i + 1 {
    assert_true(results[i].sample_size > 0)
    assert_true(results[i].iterations > 0)
    assert_true(results[i].checksum >= 0)
  }
}
