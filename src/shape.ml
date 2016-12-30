open Binary

exception End_of_file

type t = {
  input : in_channel;
  dbase : Dbase.t;
}

type mbr = {
  min_long: float;
  min_lat: float;
  max_long: float;
  max_lat: float;
}

type point = {
  long : float;
  lat  : float;
}

type poly = {
  mbr   : mbr;
  parts : point list list
}

type shape = Polyline of poly | Polygon of poly

let validate_shp_sign input =
  assert(input_byte input = 0x00);
  assert(input_byte input = 0x00);
  assert(input_byte input = 0x27);
  assert(input_byte input = 0x0a);
  ignore (really_input_string input 20) (* 5 Integers not used in file format *)

let read_boundary input =
  let min_long = input_d64le input in
  let min_lat = input_d64le input in
  let max_long = input_d64le input in
  let max_lat = input_d64le input in
  { min_long; min_lat; max_long; max_lat; }

let read_point input =
  let long = input_d64le input in
  let lat = input_d64le input in
  { long; lat; }

let read_i32_list input length =
  let rec aux length result =
    match length with
    | 0 -> result
    | x ->
        let idx = input_i32le input in
        aux (length - 1) (idx :: result)
  in
  List.rev (aux length [])

let read_point_list input length =
  let rec aux length result =
    match length with
    | 0 -> result
    | x -> aux (length - 1) ((read_point input) :: result)
  in
  List.rev (aux length [])

let read_poly_content input =
  let mbr = read_boundary input in
  let num_parts = input_i32le input in
  let num_points = input_i32le input in
  let part_indexes = read_i32_list input num_parts in
  let part_end_indexes = List.append (List.tl part_indexes) [num_points] in
  let rec read_parts parts last_idx result =
    match parts with
    | [] -> result
    | idx::xs ->
        let part = read_point_list input (idx - last_idx) in
        read_parts xs idx (part :: result) in
  let parts = read_parts part_end_indexes 0 [] in
  { mbr; parts; }

let make shp dbf =
  let input = open_in shp in
  let dbase = Dbase.make dbf in
  validate_shp_sign input;
  ignore (really_input_string input 76); (* File length, version, type, mbr *)
  { input; dbase; }

let read_shape input =
  ignore (really_input_string input 8); (* Record length, content length *)
  let shape_type = input_i32le input in
  match shape_type with
  | 3 -> Polyline (read_poly_content input)
  | 5 -> Polygon (read_poly_content input)
  | _ -> raise (Failure ("Unknown shape: " ^ (string_of_int shape_type)))

let next t =
  let data = Dbase.next t.dbase in
  (read_shape t.input, Dbase.get_int data "KKOD")

let length t =
    Dbase.record_count t.dbase

let close t =
  close_in t.input;
  Dbase.close t.dbase

