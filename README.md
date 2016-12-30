This project is in pre alpha state. The maps generated will lack some elements, and style and details is not yet configurable.

# Lantmäteriet's maps to osm
This is a converter to convert [Lantmäteriet's](https://www.lantmateriet.se/) maps (shape format) to the [OpenStreetMap](http://wiki.openstreetmap.org/wiki/OSM_XML) (OSM) format. (Currently only supporting the XML version, which may yield very big map files.)

Lantmäteriet, or the Swedish National Land Survey, is a government agency in Sweden.
They started releasing very detailed map data under Creative Common license during 2016.

My goal with this project is to run these detailed (and free) maps on my hiking GPS devices.

## Lantmäteriet's maps on Garmin GPS devices
This software cannot currently convert maps directly into a format that garmin devices understand (gmap). But there is an open source project called [mkgmap](http://www.mkgmap.org.uk/) which can convert from OSM to gmap.

### Example to run lantmäteriet's maps on garmin:
First download the maps from [Lantmäteriet](https://www.lantmateriet.se/sv/Kartor-och-geografisk-information/Kartor/oppna-data/hamta-oppna-geodata/#faq:gsd-terrangkartan-vektor) in `shape` format (I've only tested the terrain map). And then run:
```sh
./lantmateriet2osm lantmateriet.json style.json /path/to/map/folder/
```
`lantmateriet2osm` will create a `map.osm` file containing the map data, and a folder called `style/` containing style data for the map supported by mkgmap (currently hard coded, will implement a style.json format in the future.). To convert this to gmap you can use `mkgmap`: (for details, see docs of [mkgmap](http://www.mkgmap.org.uk/))
```sh
java -jar mkgmap.jar --family-id=909 styles/typfile.txt
java -jar splitter.jar map.osm > splitter.log
java -jar mkgmap.jar --style-file=styles --family-id=909 --gmapsupp *.pbf *.typ
```
That will generate a `gmapsupp.img` file which can be put on a garmin gps device. Never upload a generated map to the internal memory of the gps, always use external sd-card and read the documentation of mkgmap before proceeding to avoid bricking your gps.

### Warning
There is currently no support to render elements with the same item code differently.
Here is some conflicts in Lantmäteriet's maps to be aware of:
```
16 Military restricted area   -  16 Recreational buildings
17 Military shooting range    -  17 Open land
```
