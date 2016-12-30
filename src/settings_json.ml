open Printf
open Yojson.Basic.Util

type t = {
  json : Yojson.Basic.json
}

let make file =
  let json = Yojson.Basic.from_file file in
  { json; }

module Settings = struct
  let get_file_regex t =
    let shp_file = t.json |> member "shape_file" |> to_string in
    let dbf_file = t.json |> member "dbase_file" |> to_string in
    (shp_file, dbf_file)

  let get_file_definition t =
    let file_defs = t.json |> member "file_definition" |> to_assoc in
    List.map (fun (ft, j) ->
        let desc = j |> member "description" |> to_string in
        (ft, desc)
      ) file_defs

  let get_kkod_definition t =
    let file_defs = t.json |> member "file_definition" |> to_assoc in
    let to_kkod_def (file, json) =
      let items = json |> member "item" |> to_assoc in
      List.map (fun (kkod, json) ->
          (int_of_string kkod, file, json |> to_string)
        ) items
    in
    List.flatten @@ List.map to_kkod_def file_defs
end

module Style = struct
  let get_style_definitions t =
    let open Style in
    let json = t.json in
    let parse_line_object json =
      let int_to_string = fun j -> string_of_int (to_int j) in
      let line_width = json |> member "line_width" |> to_option int_to_string in
      let border_width = json |> member "border_width" |> to_option int_to_string in
      let use_orientation = Some "Y" in (* TODO implement. *)
      Line { line_width; border_width; use_orientation; } in
    let parse_polygon_object json =
      Polygon { font_style = NoLabel; } in (* TODO implement. *)
    let parse_object_type otype json =
      match otype with
      | "point" -> Point
      | "line" -> parse_line_object json
      | "polygon" -> parse_polygon_object json
      | t -> raise @@ Failure ("Failed to parse style definition. Unknown type: " ^ t) in
    let parse_xpm json =
      let width = json |> member "width" |> to_int in
      let height = json |> member "height" |> to_int in
      let color_name_len = json |> member "color_name_len" |> to_int in
      let colors = json |> member "colors" |> convert_each to_string in
      let bitmap = json |> member "bitmap" |> to_list |> List.map to_string in
      { width; height; colors; color_name_len; bitmap; } in
    let defs = json |> member "style_definitions" |> to_assoc in
    let def_tbl = Hashtbl.create 50 in
    List.iter (fun (key, json) ->
      let description = json |> member "description" |> to_string in
      let render_order = json |> member "render_order" |> to_int in
      let zoom_level = json |> member "zoom_level" |> to_int |> string_of_int in
      let tag_list = json |> member "tags" |> to_list in
      (* TODO implement multi tag support *)
      let tag_key = tag_list |> List.hd |> member "key" |> to_string in
      let tag_val = tag_list |> List.hd |> member "value" |> to_string in
      let tag = (tag_key, tag_val) in
      let style_json = json |> member "style" in
      let xpm_json = json |> member "xpm" in
      let object_type = json |> member "type" |> to_string in
      let map_object = parse_object_type object_type style_json in
      let xpm = parse_xpm xpm_json in
      let style = { tag; render_order; zoom_level; description; map_object; xpm; } in
      Hashtbl.add def_tbl key style
    ) defs;
    def_tbl

  let get_style_items t =
    let style_items = Hashtbl.create 100 in
    let items = t.json |> member "items" |> to_assoc in
    List.iter (fun (style_name, j) ->
        let kkods = j |> to_list in
        List.iter (fun jkkod ->
          let kkod = jkkod |> to_int in
          Hashtbl.add style_items kkod style_name
        ) kkods
    ) items;
    style_items
end
