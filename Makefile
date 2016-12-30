

all:
	ocamlbuild -use-ocamlfind 'src/lantmateriet2osm.native'
	mv lantmateriet2osm.native lantmateriet2osm

debug:
	ocamlbuild -use-ocamlfind -tag annot -tag debug 'src/lantmateriet2osm.native'

clean:
	ocamlbuild -clean

