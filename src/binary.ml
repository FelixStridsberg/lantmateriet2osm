let input_i32be = input_binary_int

let input_i32le ic =
  let b0 = input_byte ic in
  let b1 = input_byte ic in
  let b2 = input_byte ic in
  let b3 = input_byte ic in
  (b3 lsl 24) lor (b2 lsl 16) lor (b1 lsl 8) lor b0

let input_i32be ic =
  let b0 = input_byte ic in
  let b1 = input_byte ic in
  let b2 = input_byte ic in
  let b3 = input_byte ic in
  (b0 lsl 24) lor (b1 lsl 16) lor (b2 lsl 8) lor b3

let input_i64le ic =
  let low = Int64.of_int @@ input_i32le ic in
  let high = Int64.of_int @@ input_i32le ic in
  Int64.logor (Int64.shift_left high 32) low

let input_d64le ic =
  Int64.float_of_bits (input_i64le ic)
