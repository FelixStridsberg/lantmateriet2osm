

all:
	ocamlbuild -use-ocamlfind 'src/lantmateriet2osm.native'

debug:
	ocamlbuild -use-ocamlfind -tag annot -tag debug 'src/lantmateriet2osm.native'

clean:
	ocamlbuild -clean

