
let read_settings filename =
  let json = Yojson.Basic.from_file filename in
  let open Yojson.Basic.Util in
  let jfiles = json |> member "files" |> to_list in
  let base_path = json |> member "filePath" |> to_string in
  let files = List.map (fun (jfile) ->
      let name = jfile |> member "name" |> to_string in
      let file = jfile |> member "file" |> to_string in
      (name, base_path ^ file)
    ) jfiles
  in
  [("files", files)]
