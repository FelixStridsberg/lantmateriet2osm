open Shape

let read_all files osm =
  let read_data file osm =
    let shp = Shape.make (file ^ ".shp") (file ^ ".dbf") in
    let shp_length = (Shape.length shp) in
    let rec read_shapes x progress =
      match x with
      | 0 -> ()
      | x ->
          let (shape, info) = Shape.next shp in
          let kkod = Dbase.get_int info "KKOD" in
          let new_progress = (((shp_length - x) * 100) / shp_length) in
          if new_progress > progress then
            for i = 1 to (new_progress - progress) do
              print_string ".";
              (flush stdout)
            done;
          (match shape with
          | Polyline poly -> Osm.add_polyline_shape osm kkod poly
          | Polygon poly -> Osm.add_polygon_shape osm kkod poly);
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
  List.iteri (fun i (desc, filename) ->
    Printf.printf "\n(%d of %d) Reading: %-50s" (i + 1) (List.length files) desc;
    (flush stdout);
    read_data filename osm
  ) files;
  print_endline "All done reading!\n"


let () =
  if Array.length Sys.argv <> 2 then (
    print_endline "Usage: ./main.native settings.json"
  );

  let settings_file =  Sys.argv.(1) in
  let settings = Settings.read_settings settings_file in
  let osm = Osm.make "map.osm" in
  let files = List.assoc "files" settings in
  read_all files osm;
  Osm.close osm;
  print_endline "\nSaving styles...";
  Style.write_styles "styles/";
  print_endline "All done!"
