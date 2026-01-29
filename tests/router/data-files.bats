#!/usr/bin/env bats

load '../helpers/setup'

@test "data/networks/admin.txt exists and has 1 entry" {
  assert_file_exists "$DATA_DIR/networks/admin.txt"
  assert_line_count "$DATA_DIR/networks/admin.txt" 1
}

@test "data/networks/services.txt has 35 entries" {
  assert_file_exists "$DATA_DIR/networks/services.txt"
  assert_line_count "$DATA_DIR/networks/services.txt" 35
}

@test "data/networks/grayspace.txt has > 1400 entries" {
  assert_file_exists "$DATA_DIR/networks/grayspace.txt"
  assert_line_count_gt "$DATA_DIR/networks/grayspace.txt" 1400
}

@test "data/networks/wan.txt has 1 entry" {
  assert_file_exists "$DATA_DIR/networks/wan.txt"
  assert_line_count "$DATA_DIR/networks/wan.txt" 1
}

@test "All data files contain only valid CIDR" {
  for f in admin.txt services.txt grayspace.txt wan.txt; do
    assert_all_valid_cidr "$DATA_DIR/networks/$f"
  done
}
