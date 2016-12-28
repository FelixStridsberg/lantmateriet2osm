(** Incomplete reader of the shape file format. *)

type t

type mbr = {
  min_long: float;
  min_lat: float;
  max_long: float;
  max_lat: float;
}

type point = {
  long : float;
  lat  : float;
}

type poly = {
  mbr   : mbr;
  parts : point list list
}

type shape = Polyline of poly | Polygon of poly

(** .shp filename -> .dbf filename -> t *)
val make : string -> string -> t

val length : t -> int

val next : t -> shape * Dbase.record

val close : t -> unit
