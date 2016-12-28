open Binary

exception DbTypeError of string
exception DbReadError of string
exception DbNotFound of string

type value = Int of int | String of string

type record = {
  columns : (string * value) list
}

type field_type = Number of int | String of int

type field_header = {
  name       : string;
  field_type : field_type;
}

type header = {
  fields : field_header list
}

type t = {
  input        : in_channel;
  record_count : int;
  header       : header;
}

let read_record_header input =
  let rec aux () =
    let first_byte = input_byte input in
    match first_byte with
    | 0x0D -> []
    | c ->(
        let null_regexp = Str.regexp "\x00" in
        let field_name = Str.global_replace null_regexp "" (really_input_string input 10) in
        let field_type = input_char input in
        for i = 1 to 4 do ignore (input_byte input); done; (* address in memory *)
        let field_length = input_byte input in
        ignore (input_byte input); (* Decimal count, don't need it *)
        for i = 1 to 14 do ignore (input_byte input); done; (* lan, reserved and stuff *)
        {
            name = (Char.escaped (Char.chr first_byte)) ^ field_name;
            field_type = match field_type with
                | 'C' -> (String field_length)
                | 'N' -> (Number field_length)
                | _ -> raise @@  DbTypeError ("Unsupported type: " ^ (Char.escaped field_type))
        } :: aux ()
    ) in
  let fields = aux () in
  { fields; }

let read_db_int input length =
  try
    let raw = really_input_string input length in
    int_of_string @@ String.trim raw
  with Failure x -> raise (DbReadError x)

let read_db_string input length =
  String.trim @@ really_input_string input length

let next t =
  ignore (input_byte t.input); (* Space for non deleted * for deleted *)
  let read_field ft = match ft with
    | Number l -> Int (read_db_int t.input l)
    | String l -> String (read_db_string t.input l) in
  let columns =
    List.map (fun h -> (h.name, read_field h.field_type)) t.header.fields
  in
  { columns }

let get_int record name =
  match List.assoc name record.columns with
  | Int i -> i
  | _ -> raise @@ DbTypeError (name ^ " is not an int")
  | exception Not_found -> raise @@ DbNotFound (name ^ " was not found")

let get_string record name =
  match List.assoc name record.columns with
  | String s -> s
  | _ -> raise @@ DbTypeError (name ^ " is not a string")
  | exception Not_found -> raise @@ DbNotFound (name ^ " was not found")

let make filename =
  let input = open_in filename in
  ignore (really_input_string input 4);
  let record_count = input_i32le input in
  ignore (really_input_string input 24);
  let header = read_record_header input in
  { input; record_count; header; }

let record_count t =
  t.record_count

let close t =
  close_in t.input
