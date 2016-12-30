(* This file is a mess, the styles are hard coded, I'm planing on moving them to a json file instead. *)

(* Todo implement zoom levels as list, or is the options good enough? *)

type font_style = NoLabel | SmallFont | NormalFont | LargeFont

type xpm = {
  width : int;
  height : int;
  colors : string list;
  color_name_len : int;
  bitmap : string list;
}

type line = {
  line_width      : string option;
  border_width    : string option;
  use_orientation : string option;
}

type polygon = {
  font_style   : font_style;
}

type map_object = Point | Line of line | Polygon of polygon

type style = {
  tag          : string * string;
  render_order : int;
  zoom_level   : string;
  description  : string;
  map_object   : map_object;
  xpm          : xpm;
}

let string_of_optional_attr key oattr =
  match oattr with
  | Some value -> Printf.sprintf "%s=%s\n" key value
  | None -> ""

let string_of_xpm name xpm =
  (Printf.sprintf "%s=\"%d %d %d %d\"\n" name xpm.width xpm.height (List.length xpm.colors) xpm.color_name_len) ^
  (String.concat "\n" (List.map (fun x -> ("\"" ^ x ^ "\"")) xpm.colors)) ^
  "\n" ^
  (String.concat "\n" (List.map (fun x -> ("\"" ^ x ^ "\"")) xpm.bitmap)) ^
  (if List.length xpm.bitmap > 0 then "\n" else "")

let string_of_line line =
  (string_of_optional_attr "LineWidth" line.line_width) ^
  (string_of_optional_attr "BorderWidth" line.border_width)

let string_of_polygon polygon =
  ""

let typ_string_of_style id style =
  match style.map_object with
  | Line l -> Printf.sprintf "[_line]\nType=0x%x\nString=0x04,\"%s\"\n%s%s[end]\n"
      id style.description (string_of_line l) (string_of_xpm "Xpm" style.xpm)
  | Polygon p -> Printf.sprintf "[_polygon]\nType=0x%x\nString=0x04,\"%s\"\n%s%s[end]\n"
      id style.description (string_of_polygon p) (string_of_xpm "Xpm" style.xpm)
  | Point -> Printf.sprintf "[_point]\nType=0x%x\nString=0x04,\"%s\"\n%s[end]\n"
      id style.description (string_of_xpm "DayXpm" style.xpm)


let tag_string_of_style id style =
  let key, value = style.tag in
  Printf.sprintf "%s=%s [0x%x level %s]" key value id style.zoom_level

let render_order_of_style id style =
  Printf.sprintf "Type=0x%x,%d\n" id style.render_order

let tag_of_style style =
  style.tag

let write_styles style_definitions directory =
  let typ_def = ref [] in
  let render_levels = ref [] in
  let points_def = ref [] in
  let lines_def = ref [] in
  let polygons_def = ref [] in
  let point_id = ref 0xFF in
  let id = ref 0 in
  Hashtbl.iter (fun _ style ->
    let add_point () =
      point_id := !point_id + 1;
      typ_def := typ_string_of_style !point_id style :: !typ_def;
      render_levels := render_order_of_style !point_id style :: !render_levels in
    let add_poly () =
      id := !id + 1;
      typ_def := typ_string_of_style !id style :: !typ_def;
      render_levels := render_order_of_style !id style :: !render_levels in
    match style.map_object with
    | Point -> add_point (); points_def := tag_string_of_style !point_id style :: !points_def
    | Line l -> add_poly (); lines_def := tag_string_of_style !id style :: !lines_def
    | Polygon p -> add_poly(); polygons_def := tag_string_of_style !id style :: !polygons_def
  ) style_definitions;
  let typ_def = String.concat "\n" !typ_def in
  let points_def = String.concat "\n" !points_def in
  let lines_def = String.concat "\n" !lines_def in
  let polygons_def = String.concat "\n" !polygons_def in
  (try
    Unix.mkdir directory 0o774;
  with Unix.Unix_error(err, _, _) ->
    (match err with
    | Unix.EEXIST -> ()
    | _ -> raise (Failure "Create style map failed")));
  let out = open_out (directory ^ "typfile.txt") in
  output_string out "[_id]\nFID=909\nProductCode=1\nCodePage=1252\n[end]\n\n";
  output_string out "[_drawOrder]\n";
  output_string out (String.concat "" !render_levels);
  output_string out "[end]\n\n";
  output_string out typ_def;
  close_out out;
  let out = open_out (directory ^ "points") in
  output_string out points_def;
  let out = open_out (directory ^ "lines") in
  output_string out lines_def;
  close_out out;
  let out = open_out (directory ^ "polygons") in
  output_string out polygons_def;
  close_out out;
  let out = open_out (directory ^ "options") in
  output_string out "levels=0:24, 1:23, 2:22, 3:20, 4:16, 5:14, 6:10";
  close_out out;
  let out = open_out (directory ^ "version") in
  output_string out "";
  close_out out

