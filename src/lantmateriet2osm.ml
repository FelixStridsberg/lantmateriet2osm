open Shape

let read_all settings files osm =
  let read_data (shp, dbf) osm =
    let shp = Shape.make shp dbf in
    let shp_length = (Shape.length shp) in
    let rec read_shapes x progress =
      match x with
      | 0 -> ()
      | x ->
          let (shape, kkod) = Shape.next shp in
          let new_progress = (((shp_length - x) * 100) / shp_length) in
          if new_progress > progress then
            for i = 1 to (new_progress - progress) do
              print_string ".";
              (flush stdout)
            done;
          match Settings.get_style_tag settings kkod with
          | None -> read_shapes (x - 1) new_progress
          | Some tag ->
              (match shape with
              | Polyline poly -> Osm.add_polyline_shape osm kkod poly tag
              | Polygon poly -> Osm.add_polygon_shape osm kkod poly tag);
              read_shapes (x - 1) new_progress
    in
    Printf.printf "%32s\n" ("(" ^ (string_of_int shp_length) ^ " object found)");
    for i = 1 to 100 do
      print_string "-"
    done;
    print_endline "";
    read_shapes shp_length 0;
    print_endline ".";
    Shape.close shp
  in
  List.iteri (fun i (ft, shp, dbf, desc) ->
    Printf.printf "\n(%d of %d) Reading: %-50s" (i + 1) (List.length files) desc;
    (flush stdout);
    read_data (shp, dbf) osm
  ) files;
  print_endline "All done reading!\n"

let () =
  if Array.length Sys.argv <> 4 then (
    print_endline "Usage: ./lantmateriet2osm lantmateriet.json style.json path\n";
    print_endline "settings.lantmateriet.json  -  Description of file layout";
    print_endline "style.json                  -  Style and details";
    print_endline "path                        -  Path to folder with map data";
    exit 1
  );

  let settings = Settings.make Sys.argv.(1) Sys.argv.(2) in
  let files = Settings.get_file_paths settings Sys.argv.(3) in
  let osm = Osm.make "map.osm" in
  try
    Settings.validate settings;
    read_all settings files osm;
    Osm.close osm;
    print_endline "\nSaving styles...";
    Style.write_styles (Settings.style_def settings) "styles/";
    print_endline "All done!"
  with Failure e ->
    Osm.close osm;
    print_endline @@ "Fatal error: " ^ e

