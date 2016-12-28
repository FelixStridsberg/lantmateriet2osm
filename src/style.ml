(* This file is a mess, the styles are hard coded, I'm planing on moving them to a json file instead. *)

(* Todo move to some kind of style.json *)
(* Todo implement zoom levels as list *)

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

type map_object = Line of line | Polygon of polygon

type style = {
  tag          : string * string;
  render_order : int;
  zoom_level   : string;
  description  : string;
  map_object   : map_object;
  xpm          : xpm;
}

type style_names =
    Way_highway | Way_class1 | Way_class2 | Way_class3 | Way_street
  | Way_street_big | Way_trail | Way_marked_trail | Way_lighted_trail | Way_bicycle_path
  | Power_line
  | Water_stream_class1 | Water_stream_class2 | Water_stream_class3
  | Building_big
  | Natural_water | Natural_marsh | Natural_forest | Natural_field
  | Landuse_farmland | Landuse_residential1 | Landuse_residential2 | Landuse_residential3
  | Landuse_industrial | Landuse_recreational
  | Data_height_curve

let styles_list = [
  (Way_highway, {
    tag = ("way", "highway");
    description = "Highway";
    zoom_level = "6";
    render_order = 6;
    map_object = Line {
      line_width = Some "3";
      border_width = Some "1";
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #FFFFFF";
        "b c #E85625";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Way_class1, {
    tag = ("way", "class1");
    description = "Class 1 road";
    zoom_level = "4";
    render_order = 6;
    map_object = Line {
      line_width = Some "2";
      border_width = Some "1";
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #F49F8A";
        "b c #E85625";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Way_class2, {
      tag = ("way", "class2");
      description = "Class 2 road";
      zoom_level = "3";
      render_order = 6;
      map_object = Line {
        line_width = Some "1";
        border_width = Some "1";
        use_orientation = Some "Y";
      };
      xpm = {
        width = 0;
        height = 0;
        colors = [
          "a c #F49F8A";
          "b c #E85625";
        ];
        color_name_len = 1;
        bitmap = [];
      }
  });
  (Way_class3, {
    tag = ("way", "class3");
    description = "Class 3 road";
    zoom_level = "3";
    render_order = 7;
    map_object = Line {
      line_width = Some "2";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #E85625";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Way_street, {
    tag = ("way", "street");
    description = "Street";
    zoom_level = "2";
    render_order = 5;
    map_object = Line {
      line_width = Some "1";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #000000";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Way_street_big, {
    tag = ("way", "street_big");
    description = "Big street";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = Some "1";
      border_width = Some "1";
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #FFFFFF";
        "b c #000000";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Way_trail, {
    tag = ("way", "trail");
    description = "Trail";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = None;
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 32;
      height = 1;
      colors = [
        "a c #000000";
        "b c none";
      ];
      color_name_len = 1;
      bitmap = [
        "aabbaabbaabbaabbaabbaabbaabbaabb"
      ];
    }
  });
  (Way_marked_trail, {
    tag = ("way", "marked_trail");
    description = "Marked trail";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = None;
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 32;
      height = 1;
      colors = [
        "a c #000000";
        "b c none";
      ];
      color_name_len = 1;
      bitmap = [
        "aaaabbbbaaaabbbbaaaabbbbaaaabbbb"
      ];
    }
  });
  (Way_lighted_trail, {
    tag = ("way", "lighted_trail");
    description = "Marked trail";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = None;
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 32;
      height = 1;
      colors = [
        "a c #93831D";
        "b c none";
      ];
      color_name_len = 1;
      bitmap = [
          "aaaabbbbaaaabbbbaaaabbbbaaaabbbb"
      ];
    }
  });
  (Way_bicycle_path, {
    tag = ("way", "bicycle");
    description = "Bicycle path";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = Some "1";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #000000";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Power_line, {
    tag = ("power", "line");
    description = "Power line";
    zoom_level = "2";
    render_order = 8;
    map_object = Line {
      line_width = None;
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 32;
      height = 5;
      colors = [
        "a c #000000";
        ". c none";
      ];
      color_name_len = 1;
      bitmap = [
        "aa..............................";
        "aa..............................";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aa..............................";
        "aa..............................";
      ];
    }
  });
  (Water_stream_class1, {
    tag = ("water", "stream_class1");
    description = "Water stream class 1";
    zoom_level = "3";
    render_order = 6;
    map_object = Line {
      line_width = Some "2";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #0099FF";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Water_stream_class2, {
    tag = ("water", "stream_class2");
    description = "Water stream class 2";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = Some "1";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #0099FF";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Water_stream_class3, {
    tag = ("water", "stream_class3");
    description = "Water stream class 3";
    zoom_level = "2";
    render_order = 6;
    map_object = Line {
      line_width = Some "1";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #0099FF";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Data_height_curve, {
    tag = ("data", "height_curve");
    description = "Trail";
    zoom_level = "0";
    render_order = 6;
    map_object = Line {
      line_width = Some "1";
      border_width = None;
      use_orientation = Some "Y";
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #6A5800";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Building_big, {
    tag = ("building", "big");
    description = "Big building";
    zoom_level = "2";
    render_order = 6;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #555555";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Natural_water, {
    tag = ("natural", "water");
    description = "Water";
    zoom_level = "4";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #0099FF";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Natural_marsh, {
    tag = ("natural", "marsh");
    description = "Water";
    zoom_level = "4";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 32;
      height = 32;
      colors = [
        "a   c #CAEAFF";
        "b   c #0099ff";
      ];
      color_name_len = 1;
      bitmap = [
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
      ];
    }
  });
  (Natural_forest, {
    tag = ("natural", "forest");
    description = "Forest";
    zoom_level = "4";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #33CC33";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Natural_field, {
    tag = ("natural", "field");
    description = "Field";
    zoom_level = "3";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #E3E5BB";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Landuse_residential1, {
    tag = ("landuse", "residential1");
    description = "Residential class 1";
    zoom_level = "3";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #BBBBBB";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Landuse_residential2, {
      tag = ("landuse", "residential2");
      description = "Residential class 2";
      zoom_level = "3";
      render_order = 1;
      map_object = Polygon {
        font_style = NoLabel
      };
      xpm = {
        width = 0;
        height = 0;
        colors = [
          "a c #999999";
        ];
        color_name_len = 1;
        bitmap = [];
      }
  });
  (Landuse_residential3, {
      tag = ("landuse", "residential3");
      description = "Residential class 3";
      zoom_level = "3";
      render_order = 1;
      map_object = Polygon {
        font_style = NoLabel
      };
      xpm = {
        width = 0;
        height = 0;
        colors = [
          "a c #666666";
        ];
        color_name_len = 1;
        bitmap = [];
      }
  });
  (Landuse_farmland, {
      tag = ("landuse", "farmland");
      description = "Farm land";
      zoom_level = "3";
      render_order = 1;
      map_object = Polygon {
        font_style = NoLabel
      };
      xpm = {
        width = 0;
        height = 0;
        colors = [
          "a c #E6E38C";
        ];
        color_name_len = 1;
        bitmap = [];
      }
  });
  (Landuse_industrial, {
    tag = ("landuse", "industrial");
    description = "Industrial";
    zoom_level = "3";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #AB7280";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
  (Landuse_recreational, {
    tag = ("landuse", "recreational");
    description = "Recreational";
    zoom_level = "3";
    render_order = 1;
    map_object = Polygon {
      font_style = NoLabel
    };
    xpm = {
      width = 0;
      height = 0;
      colors = [
        "a c #D2FDC8";
      ];
      color_name_len = 1;
      bitmap = [];
    }
  });
]


let attributes style_name =
  try
    let style = List.assoc style_name styles_list in
    style.tag
  with Not_found -> raise (Failure ("Style not found."))

let string_of_optional_attr key oattr =
  match oattr with
  | Some value -> Printf.sprintf "%s=%s\n" key value
  | None -> ""

let string_of_xpm xpm =
  (Printf.sprintf "Xpm=\"%d %d %d %d\"\n" xpm.width xpm.height (List.length xpm.colors) xpm.color_name_len) ^
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
      id style.description (string_of_line l) (string_of_xpm style.xpm)
  | Polygon p -> Printf.sprintf "[_polygon]\nType=0x%x\nString=0x04,\"%s\"\n%s%s[end]\n"
      id style.description (string_of_polygon p) (string_of_xpm style.xpm)


let tag_string_of_style id style =
  let key, value = style.tag in
  Printf.sprintf "%s=%s [0x%x level %s]" key value id style.zoom_level

let render_order_of_style id style =
  Printf.sprintf "Type=0x%x,%d\n" id style.render_order

let tag_of_style style =
  style.tag

let write_styles directory =
  let typ_def = ref [] in
  let render_levels = ref [] in
  let lines_def = ref [] in
  let polygons_def = ref [] in
  List.iteri (fun id (name, style) ->
    let id = id + 1 in
    typ_def := typ_string_of_style id style :: !typ_def;
    render_levels := render_order_of_style id style :: !render_levels;
    match style.map_object with
    | Line l -> lines_def := tag_string_of_style id style :: !lines_def;
    | Polygon p -> polygons_def := tag_string_of_style id style :: !polygons_def;
  ) styles_list;
  let typ_def = String.concat "\n" !typ_def in
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
  let out = open_out (directory ^ "lines") in
  output_string out lines_def;
  close_out out;
  let out = open_out (directory ^ "polygons") in
  output_string out polygons_def;
  close_out out;
  let out = open_out (directory ^ "options") in
  output_string out "levels=0:24, 1:23, 2:22, 3:20, 4:16, 5:14, 6:10";
  close_out out

