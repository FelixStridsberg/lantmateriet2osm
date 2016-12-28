open Shape

type node_register = Existing of int | New of int

type t = {
  filename : string;
  relation_out : out_channel * string;
  node_out : out_channel * string;
  node_register : (point, int) Hashtbl.t;
  skip_log : (int, int) Hashtbl.t;
  mutable node_id : int;
  mutable min_long : float;
  mutable max_long : float;
  mutable min_lat : float;
  mutable max_lat : float;
}

let relation_attributes = [
  (1, Style.Natural_water);
  (18, Style.Natural_marsh); (* Iffy water lines *)

  (2, Style.Natural_forest);
  (19, Style.Natural_forest);

  (5, Style.Natural_field);
  (17, Style.Natural_field);


  (4, Style.Landuse_farmland);
  (7, Style.Landuse_farmland);

  (12, Style.Landuse_residential3);
  (13, Style.Landuse_residential2);
  (14, Style.Landuse_residential1);
  (15, Style.Landuse_industrial);
  (16, Style.Landuse_recreational);

  (*
  (* Currently not in typ-file *)
  (21, [("boundary", "administrative"); ("admin_level", "1");]); (* Riksgräns *)
  (23, [("boundary", "administrative"); ("admin_level", "2");]); (* Länsgräns *)
  (24, [("boundary", "administrative"); ("admin_level", "3");]); (* Kommungräns *)
  *)

  (264, Style.Way_trail);         (* Gångstig *)
  (265, Style.Way_marked_trail);  (* Vandringsled *)
  (268, Style.Way_marked_trail);  (* Vandringsled längs väg *)
  (266, Style.Way_lighted_trail); (* Elljusspår *)

  (5095, Style.Way_trail);        (* Cykelväg *)
  (5098, Style.Way_bicycle_path); (* Tractor road *)

  (* 336 Färjeled *)
  (5011, Style.Way_highway); (* Motorväg *)
  (* 5014 road construction *)

  (5022, Style.Way_class1); (* Allmän väg klass 1 *)
  (5025, Style.Way_class2); (* Allmän väg klass 2 *)
  (5029, Style.Way_class3); (* Allmän väg klass 3 *)

  (5032, Style.Way_class1); (* På/av-fart väg klass 1 *)
  (5033, Style.Way_class2); (* På/av-fart väg klass 2 *)
  (5034, Style.Way_class3); (* På/av-fart väg klass 3 *)

  (5044, Style.Way_class2);     (* Genomfartsgata *)
  (5051, Style.Way_street_big); (* Gata, större *)
  (5056, Style.Way_street);     (* Gata *)
  (5058, Style.Way_street);     (* Gata i sluten bebyggelse *)

  (5061, Style.Way_street_big); (* Bättre bilväg *)
  (5071, Style.Way_street_big); (* Bilväg *)
  (5082, Style.Way_street);     (* Sämre bilväg *)
  (5091, Style.Way_street);     (* Uppfartsväg *)

  (5811, Style.Way_highway); (* Motorväg, Underfart *)

  (5822, Style.Way_class1); (* Underfart väg klass 1 *)
  (5825, Style.Way_class2); (* Underfart väg klass 2 *)
  (5829, Style.Way_class3); (* Underfart väg klass 3 *)

  (5832, Style.Way_class1); (* På/av-fart underfart väg klass 1 *)
  (5833, Style.Way_class2); (* På/av-fart underfart väg klass 2 *)
  (5834, Style.Way_class3); (* På/av-fart underfart väg klass 3 *)

  (5844, Style.Way_street);     (* Genomfartsgata, underfart *)
  (5851, Style.Way_street_big); (* Gata, större, underfart *)
  (5856, Style.Way_street);     (* Gata, underfart *)
  (5858, Style.Way_street);     (* Gata i sluten bebyggelse, underfart *)

  (5861, Style.Way_street_big); (* Bättre bilväg, underfart *)
  (5871, Style.Way_street_big); (* Bilväg, underfart *)
  (5882, Style.Way_street);     (* Sämre bilväg, underfart *)
  (5891, Style.Way_street);     (* Uppfartsväg, underfart *)

  (* Power grids *)
  (2611, Style.Power_line);         (* Kraftledning, stam *)
  (2612, Style.Power_line);         (* Kraftledning, region *)
  (2670, Style.Landuse_industrial); (* Transformatorområde *)

  (* Water streams *)
  (288, Style.Water_stream_class2); (* Vattentub/ränna *)
  (441, Style.Water_stream_class1);
  (455, Style.Water_stream_class2);
  (456, Style.Water_stream_class3);
  (513, Style.Water_stream_class1); (* Fors *)

  (* Buildings *)
  (690, Style.Building_big);


  (* Heigh info *)
  (568, Style.Data_height_curve);
  (*(598, [("height", "curve");]);*)
]

let get_id t =
  t.node_id <- t.node_id + 1;
  t.node_id

let get_node_id t point =
  try
    Existing (Hashtbl.find t.node_register point)
  with Not_found ->
    let id = get_id t in
    Hashtbl.add t.node_register point id;
    New id

let add_skip t kkod =
  try
    let cnt = Hashtbl.find t.skip_log kkod in
    Hashtbl.remove t.skip_log kkod;
    Hashtbl.add t.skip_log kkod (cnt + 1)
  with Not_found ->
    Hashtbl.add t.skip_log kkod 1

let make filename =
  let (relname, relout) = Filename.open_temp_file "rel" "out" in
  let (nodename, nodeout) = Filename.open_temp_file "node" "out" in
  Printf.printf "Creating temporary files:\n%s\n%s\n" relname nodename;
  {
    filename = filename;
    relation_out = (relout, relname);
    node_out = (nodeout, nodename);
    node_register = Hashtbl.create 100000;
    skip_log = Hashtbl.create 100;
    node_id  = 0;
    min_long = 360.0;
    max_long = 0.0;
    min_lat  = 360.0;
    max_lat  = 0.0;
  }

(* Save bounds for bounds-tag. Isn't this info in the shp file? *)
let log_coordinate t long lat =
  if long < t.min_long then
    t.min_long <- long;
  if long > t.max_long then
    t.max_long <- long;
  if lat < t.min_lat then
    t.min_lat <- lat;
  if lat > t.max_lat then
    t.max_lat <- lat

let write_node t id point =
  let (output, _) = t.node_out in
  let long, lat = Sweref99tm.to_wgs point.lat point.long in
  let html = Printf.sprintf "\t<node id=\"%d\" visible=\"true\" version=\"1\" lat=\"%f\" lon=\"%f\"/>\n"
  id lat long in
  log_coordinate t long lat;
  output_string output html

let write_node_member t id =
  let (output, _) = t.relation_out in
  let html = Printf.sprintf "\t<nd ref=\"%d\"/>\n" id in
  output_string output html

let write_way_start t id =
  let (output, _) = t.relation_out in
  let html = Printf.sprintf "<way id=\"%d\" visible=\"true\" version=\"1\">\n" id in
  output_string output html

let write_way_end t =
  let (output, _) = t.relation_out in
  let html = "</way>\n" in
  output_string output html

let write_relation_start t id =
  let (output, _) = t.relation_out in
  let html = Printf.sprintf "<relation id=\"%d\" visible=\"true\" version=\"1\">\n" id in
  output_string output html

let write_relation_end t =
  let (output, _) = t.relation_out in
  let html = "</relation>\n" in
  output_string output html

let write_relation_tag t key value =
  let (output, _) = t.relation_out in
  let html = Printf.sprintf "\t<tag k=\"%s\" v=\"%s\"/>\n" key value in
  output_string output html

let write_relation_member t rel_type role id =
  let (output, _) = t.relation_out in
  let html = Printf.sprintf "\t<member type=\"%s\" ref=\"%d\" role=\"%s\"/>\n" rel_type id role in
  output_string output html

let write_relation_attributes t kkod style =
  let (key, value) = Style.attributes style in
  write_relation_tag t key value;
  write_relation_tag t "kkod" (string_of_int kkod)

let add_polyline_shape t kkod shape =
  try
    let style =  List.assoc kkod relation_attributes in
    List.iter (fun part ->
      let part = part in (*Data.wgs_point_list_to_sweref99 part in*)
      let rel_id = get_id t in
      write_way_start t rel_id;
      List.iter (fun point ->
        match get_node_id t point with
        | New id ->
            write_node t id point;
            write_node_member t id
        | Existing id ->
            write_node_member t id
      ) part;
      write_relation_attributes t kkod style;
      write_way_end t;
    ) shape.parts
  with Not_found -> add_skip t kkod

let add_polygon_shape t kkod shape =
  try
    let style =  List.assoc kkod relation_attributes in
    let rel_ids = ref [] in
    List.iter (fun part ->
      let part = part in (*Data.wgs_point_list_to_sweref99 part in*)
      let rel_id = get_id t in
      rel_ids := rel_id :: !rel_ids;
      write_way_start t rel_id;
      List.iter (fun point ->
        match get_node_id t point with
        | New id ->
            write_node t id point;
            write_node_member t id
        | Existing id ->
            write_node_member t id
      ) part;
      if List.length !rel_ids = 1 then (* Only write attributes on master *)
        write_relation_attributes t kkod style;
      write_way_end t;
    ) (List.rev shape.parts);

    if List.length !rel_ids > 1 then (
      let rel_id = get_id t in
      write_relation_start t rel_id;
      write_relation_tag t "type" "multipolygon";
      List.iteri (fun i id ->
        if i+1 = List.length !rel_ids
        then write_relation_member t "way" "outer" id
        else write_relation_member t "way" "inner" id
      ) !rel_ids;
      write_relation_end t
    )
  with Not_found -> add_skip t kkod

let merge_files t node_filename relation_filename =
  let header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<osm version=\"0.6\" generator=\"Klamon\">\n" in
  let bounds = Printf.sprintf "<bounds minlat=\"%f\" minlon=\"%f\" maxlat=\"%f\" maxlon=\"%f\"/>\n" t.min_lat t.min_long t.max_lat t.max_long in
  let footer = "</osm>\n" in
  let result_file = open_out t.filename in
  let rec copy_content ic oc =
    let buff_size = 128 * 1024 in (* 128 Kb *)
    let buff = Bytes.create buff_size in
    let r = input ic buff 0 buff_size in
    if r != 0 then (
      output oc buff 0 r;
      copy_content ic oc
    ) in
  let node_file = open_in node_filename in
  let rel_file = open_in relation_filename in

  output_string result_file header;
  output_string result_file bounds;
  copy_content node_file result_file;
  copy_content rel_file result_file;
  output_string result_file footer;
  close_out result_file;
  close_in rel_file;
  close_in node_file

let close t =
  let (node_out, node_filename) = t.node_out in
  let (relation_out, relation_filename) = t.relation_out in
  close_out node_out;
  close_out relation_out;

  Printf.printf "Merging nodes and relations, may take a minute...\n(No progress bar for performance)\n";
  flush stdout;
  merge_files t node_filename relation_filename;

  Printf.printf "Removing temporary files:\n%s\n%s\n\n"node_filename relation_filename;
  Unix.unlink node_filename;
  Unix.unlink relation_filename;

  Printf.printf "Done\n\nSkip summary:\n";
  Hashtbl.iter (fun kkod cnt ->
    Printf.printf "\t%d skipped %d times\n" kkod cnt
  ) t.skip_log


