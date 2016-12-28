type t
type record

val make : string -> t

val next : t -> record

val record_count : t -> int

val get_int : record -> string -> int

val close : t -> unit
