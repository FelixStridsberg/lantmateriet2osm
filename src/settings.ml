module Json = Settings_json

type kkod = int
type file_type = string
type description = string

type t = {
  shp_file_match : string;
  dbf_file_match : string;
  file_def : (file_type * description) list;
  kkod_def : (kkod * file_type * description) list;
  style_items : (kkod, string) Hashtbl.t;
  style_def: (string, Style.style) Hashtbl.t
}

let style_def t =
  t.style_def

let get_style_tag t kkod =
  try
    let stylename = Hashtbl.find t.style_items kkod in
    let style = Hashtbl.find t.style_def stylename in
    let open Style in
    Some style.tag
  with Not_found -> None

let parse_settings settings_file =
  let json = Json.make settings_file in
  let shp_file, dbf_file = Json.Settings.get_file_regex json in
  let file_def = Json.Settings.get_file_definition json in
  let kkod_def = Json.Settings.get_kkod_definition json in
  (shp_file, dbf_file, file_def, kkod_def)

let parse_style style_file =
  let json = Json.make style_file in
  let style_def = Json.Style.get_style_definitions json in
  let style_items = Json.Style.get_style_items json in
  (style_items, style_def)

let make settings_file style_file =
  let (shp_file_match, dbf_file_match, file_def, kkod_def) = parse_settings settings_file in
  let (style_items, style_def) = parse_style style_file in
  { shp_file_match; dbf_file_match;
    file_def; kkod_def; style_items; style_def; }

let kkod_defs_in_use t =
  t.kkod_def |>
    List.filter (fun (kkod, _, _) -> Hashtbl.mem t.style_items kkod)

let file_types_in_use t =
  kkod_defs_in_use t |>
    List.map (fun (_, ft, _) -> ft) |>
      List.sort_uniq (fun a b -> String.compare a b)

let kkods_in_use t =
  kkod_defs_in_use t |>
    List.map (fun (kkod, _, _) -> kkod) |>
      List.sort_uniq (fun a b -> a - b)

let get_file_paths t path =
  let find_file files file_type file_match =
    let type_reg = Str.regexp "\\{type\\}" in
    let shp_reg = Str.regexp @@ Str.replace_first type_reg file_type file_match in
    let match_ft = (fun f -> Str.string_match shp_reg f 0) in
    let filename = List.find match_ft files in
    let file_path = Filename.concat path filename in
    Unix.access file_path [Unix.R_OK;];
    file_path in
  let files = Sys.readdir path |> Array.to_list in
  let rec gather_info = function
    | [] -> []
    | ft::xs ->
        let (_, desc) = List.find (fun (t, _) -> t = ft) t.file_def in
        try
          let shp = find_file files ft t.shp_file_match in
          let dbf = find_file files ft t.dbf_file_match in
          (ft, shp, dbf, desc) :: gather_info xs
        with Not_found ->
          raise @@ Failure ("Missing file for type: '" ^ ft ^ "': " ^ desc) in
  try gather_info (file_types_in_use t)
  with Unix.Unix_error (_, s, p) ->
    raise @@ Failure ("File error, '" ^ s ^ "' on '" ^ p ^ "'")

let validate t =
  let defined_kkods = List.map (fun (kkod, _, _) -> kkod) t.kkod_def in
  let kkods = kkods_in_use t in
  List.iter (fun kkod ->
      match get_style_tag t kkod with
      | Some _ -> ()
      | None ->
          raise @@ Failure ("Style definition missing for kkod: " ^ string_of_int kkod)
    ) kkods;
  Hashtbl.iter (fun kkod _ ->
      if not (List.mem kkod defined_kkods) then
        raise @@ Failure ("Style uses undefined kkod: " ^ string_of_int kkod)
    ) t.style_items;

