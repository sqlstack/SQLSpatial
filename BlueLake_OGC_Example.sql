USE master
GO
CREATE DATABASE BlueLake
GO
USE BlueLake
GO

CREATE TABLE spatial_ref_sys (
srid INTEGER NOT NULL PRIMARY KEY,
auth_name CHARACTER VARYING(25),
auth_srid INTEGER,
srtext CHARACTER VARYING(4000));

-- Lakes
CREATE TABLE lakes (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
shore GEOMETRY);

-- Road Segments
CREATE TABLE road_segments (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
aliases CHARACTER VARYING(64),
num_lanes INTEGER,
centerline GEOMETRY);

-- Divided Routes
CREATE TABLE divided_routes (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
num_lanes INTEGER,
centerlines GEOMETRY);

-- Forests
CREATE TABLE forests (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
boundary GEOMETRY);

-- Bridges
CREATE TABLE bridges (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
position GEOMETRY);

-- Streams
CREATE TABLE streams (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
centerline GEOMETRY);

-- Buildings
CREATE TABLE buildings (
fid INTEGER NOT NULL PRIMARY KEY,
address CHARACTER VARYING(64),
position GEOMETRY,
footprint GEOMETRY);

-- Ponds
CREATE TABLE ponds (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
type CHARACTER VARYING(64),
shores GEOMETRY);

-- Named Places
CREATE TABLE named_places (
fid INTEGER NOT NULL PRIMARY KEY,
name CHARACTER VARYING(64),
boundary GEOMETRY);

-- Map Neatline
CREATE TABLE map_neatlines (
fid INTEGER NOT NULL PRIMARY KEY,
neatline GEOMETRY);






-- Spatial Reference System
INSERT INTO spatial_ref_sys VALUES
(101, 'POSC', 32214, 'PROJCS["UTM_ZONE_14N",
GEOGCS["World Geodetic System 72",
DATUM["WGS_72",
ELLIPSOID["NWL_10D", 6378135, 298.26]],
PRIMEM["Greenwich", 0],
UNIT["Meter", 1.0]],
PROJECTION["Transverse_Mercator"],
PARAMETER["False_Easting", 500000.0],
PARAMETER["False_Northing", 0.0],
PARAMETER["Central_Meridian", -99.0],
PARAMETER["Scale_Factor", 0.9996],
PARAMETER["Latitude_of_origin", 0.0],
UNIT["Meter", 1.0]]');

-- Lakes
INSERT INTO lakes VALUES (101, 'BLUE LAKE', geometry::STPolyFromText('POLYGON( (52 18,66 23,73 9,48 6,52 18), (59 18,67 18,67 13,59 13,59 18) )',101));

-- Road segments
INSERT INTO road_segments VALUES(102, 'Route 5', NULL, 2, geometry::STLineFromText('LINESTRING( 0 18, 10 21, 16 23, 28 26, 44 31 )' ,101));
INSERT INTO road_segments VALUES(103, 'Route 5', 'Main Street', 4, geometry::STLineFromText('LINESTRING( 44 31, 56 34, 70 38 )' ,101));
INSERT INTO road_segments VALUES(104, 'Route 5', NULL, 2, geometry::STLineFromText('LINESTRING( 70 38, 72 48 )' ,101));
INSERT INTO road_segments VALUES(105, 'Main Street', NULL, 4, geometry::STLineFromText('LINESTRING( 70 38, 84 42 )' ,101));
INSERT INTO road_segments VALUES(106, 'Dirt Road by Green Forest', NULL, 1, geometry::STLineFromText('LINESTRING( 28 26, 28 0 )',101));

-- DividedRoutes
INSERT INTO divided_routes VALUES(119, 'Route 75', 4, geometry::STMLineFromText('MULTILINESTRING((10 48,10 21,10 0),(16 0,16 23,16 48))', 101));

-- Forests
INSERT INTO forests VALUES(109, 'Green Forest', geometry::STMPolyFromText('MULTIPOLYGON(((28 26,28 0,84 0,84 42,28 26),(52 18,66 23,73 9,48 6,52 18)),((59 18,67 18,67 13,59 13,59 18)))',101));

-- Bridges
INSERT INTO bridges VALUES(110, 'Cam Bridge', geometry::STPointFromText('POINT( 44 31 )', 101));

-- Streams
INSERT INTO streams VALUES(111, 'Cam Stream', geometry::STLineFromText('LINESTRING( 38 48, 44 41, 41 36, 44 31, 52 18 )', 101));
INSERT INTO streams VALUES(112, NULL, geometry::STLineFromText('LINESTRING( 76 0, 78 4, 73 9 )', 101));

-- Buildings
INSERT INTO buildings VALUES(113, '123 Main Street', geometry::STPointFromText('POINT( 52 30 )', 101), geometry::STPolyFromText('POLYGON( ( 50 31, 54 31, 54 29, 50 29, 50 31) )', 101));
INSERT INTO buildings VALUES(114, '215 Main Street', geometry::STPointFromText( 'POINT( 64 33 )', 101), geometry::STPolyFromText( 'POLYGON( ( 66 34, 62 34, 62 32, 66 32, 66 34) )', 101));

-- Ponds
INSERT INTO ponds VALUES(120, NULL, 'Stock Pond', geometry::STMPolyFromText( 'MULTIPOLYGON( ( ( 24 44, 22 42, 24 40, 24 44) ), ( ( 26 44, 26 40, 28 42, 26 44) ) )', 101));

-- Named Places
INSERT INTO named_places VALUES(117, 'Ashton', geometry::STPolyFromText( 'POLYGON( ( 62 48, 84 48, 84 30, 56 30, 56 34, 62 48) )', 101));
INSERT INTO named_places VALUES(118, 'Goose Island', geometry::STPolyFromText( 'POLYGON( ( 67 13, 67 18, 59 18, 59 13, 67 13) )', 101));

-- Map Neatlines
INSERT INTO map_neatlines VALUES(115, geometry::STPolyFromText('POLYGON( ( 0 0, 0 48, 84 48, 84 0, 0 0 ) )', 101));



-- Visualize all the tables
select name, position.STBuffer(1) from bridges 
union all select address, position.STBuffer(1) from buildings 
union all select address, footprint from buildings 
union all select name, centerlines from divided_routes 
union all select name, boundary from forests
union all select name, shore from lakes
union all select name, boundary from named_places
union all select type, shores from ponds
union all select name, centerline from road_segments
union all select name, centerline from streams



-- Conformance Item T1
SELECT f_table_name 
FROM geometry_columns;

-- Conformance Item T2
SELECT f_geometry_column 
FROM geometry_columns 
WHERE f_table_name = 'streams';

-- Conformance Item T3
SELECT coord_dimension 
FROM geometry_columns 
WHERE f_table_name = 'streams';

-- Conformance Item T4
SELECT srid 
FROM geometry_columns 
WHERE f_table_name = 'streams';

-- Conformance Item T5
SELECT srtext 
FROM SPATIAL_REF_SYS 
WHERE SRID = 101;

-- Conformance Item T6
SELECT shore.STDimension() 
FROM lakes 
WHERE name = 'Blue Lake';

-- Conformance Item T7
SELECT centerlines.STGeometryType() 
FROM divided_routes 
WHERE name = 'Route 75';

-- Conformance Item T8
SELECT boundary.STAsText() 
FROM named_places 
WHERE name = 'Goose Island';

-- Conformance Item T9
SELECT geometry::STPolyFromWKB(boundary.STAsBinary(),101).STAsText()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T10
SELECT boundary.STSrid 
FROM named_places 
WHERE name = 'Goose Island';

-- Conformance Item T11
SELECT centerline.STIsEmpty() 
FROM road_segments
WHERE name = 'Route 5'
AND aliases = 'Main Street';

-- Conformance Item T12
SELECT shore.STIsSimple()
FROM lakes
WHERE name = 'Blue Lake';

-- Conformance Item T13
SELECT boundary.STBoundary().STAsText()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T14
SELECT boundary.STEnvelope().STAsText()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T15
SELECT position.STX
FROM bridges
WHERE name = 'Cam Bridge';

-- Conformance Item T16
SELECT position.STY
FROM bridges
WHERE name = 'Cam Bridge';

-- Conformance Item T17
SELECT centerline.STStartPoint().STAsText()
FROM road_segments
WHERE fid = 102;

-- Conformance Item T18
SELECT centerline.STEndPoint().STAsText()
FROM road_segments
WHERE fid = 102;

-- Conformance Item T19
SELECT geometry::STLineFromWKB(boundary.STBoundary().STAsBinary(), boundary.STSrid).STIsClosed()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T20
SELECT geometry::STLineFromWKB(boundary.STBoundary().STAsBinary(), boundary.STSrid).STIsRing()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T21
SELECT centerline.STLength()
FROM road_segments
WHERE fid = 106;

-- Conformance Item T22
SELECT centerline.STNumPoints()
FROM road_segments
WHERE fid = 102;

-- Conformance Item T23
SELECT centerline.STPointN(1).STAsText()
FROM road_segments
WHERE fid = 102;

-- Conformance Item T24
SELECT boundary.STCentroid().STAsText()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T25
SELECT boundary.STContains(boundary.STPointOnSurface())
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T26
SELECT boundary.STArea()
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T27
SELECT shore.STExteriorRing().STAsText()
FROM lakes
WHERE name = 'Blue Lake';

-- Conformance Item T28
SELECT shore.STNumInteriorRing()
FROM lakes
WHERE name = 'Blue Lake';

-- Conformance Item T29
SELECT shore.STInteriorRingN(1).STAsText()
FROM lakes
WHERE name = 'Blue Lake';

-- Conformance Item T30
SELECT centerlines.STNumGeometries()
FROM divided_routes
WHERE name = 'Route 75';

-- Conformance Item T31
SELECT centerlines.STGeometryN(2).STAsText()
FROM divided_routes
WHERE name = 'Route 75';

-- Conformance Item T32
SELECT centerlines.STIsClosed()
FROM divided_routes
WHERE name = 'Route 75';

-- Conformance Item T33
SELECT centerlines.STLength()
FROM divided_routes
WHERE name = 'Route 75';

-- Conformance Item T34
SELECT shores.STCentroid().STAsText()
FROM ponds
WHERE fid = 120;

-- Conformance Item T35
SELECT shores.STContains(shores.STPointOnSurface())
FROM ponds
WHERE fid = 120;

-- Conformance Item T36
SELECT shores.STArea()
FROM ponds
WHERE fid = 120;

-- Conformance Item T37
SELECT boundary.STEquals(geometry::STPolyFromText('POLYGON( ( 67 13, 67 18, 59 18, 59 13, 67 13) )',101))
FROM named_places
WHERE name = 'Goose Island';

-- Conformance Item T38
SELECT centerlines.STDisjoint(boundary)
FROM divided_routes, named_places
WHERE divided_routes.name = 'Route 75'
AND named_places.name = 'Ashton';

-- Conformance Item T39
SELECT centerline.STTouches(shore)
FROM streams, lakes
WHERE streams.name = 'Cam Stream'
AND lakes.name = 'Blue Lake';

-- Conformance Item T40
SELECT boundary.STWithin(footprint)
FROM named_places, buildings
WHERE named_places.name = 'Ashton'
AND buildings.address = '215 Main Street';

-- Conformance Item T41
SELECT forests.boundary.STOverlaps(named_places.boundary)
FROM forests, named_places
WHERE forests.name = 'Green Forest'
AND named_places.name = 'Ashton';

-- Conformance Item T42
SELECT road_segments.centerline.STCrosses(divided_routes.centerlines)
FROM road_segments, divided_routes
WHERE road_segments.fid = 102
AND divided_routes.name = 'Route 75';

-- Conformance Item T43
SELECT road_segments.centerline.STIntersects(divided_routes.centerlines)
FROM road_segments, divided_routes
WHERE road_segments.fid = 102
AND divided_routes.name = 'Route 75';

-- Conformance Item T44
SELECT forests.boundary.STContains(named_places.boundary)
FROM forests, named_places
WHERE forests.name = 'Green Forest'
AND named_places.name = 'Ashton';

-- Conformance Item T45
SELECT forests.boundary.STRelate(named_places.boundary,'TTTTTTTTT')
FROM forests, named_places
WHERE forests.name = 'Green Forest'
AND named_places.name = 'Ashton';

-- Conformance Item T46
SELECT position.STDistance(boundary)
FROM bridges, named_places
WHERE bridges.name = 'Cam Bridge'
AND named_places.name = 'Ashton';

-- Conformance Item T47
SELECT centerline.STIntersection(shore).STAsText()
FROM streams, lakes
WHERE streams.name = 'Cam Stream'
AND lakes.name = 'Blue Lake';

-- Conformance Item T48
SELECT named_places.boundary.STDifference(forests.boundary).STAsText()
FROM named_places, forests
WHERE named_places.name = 'Ashton'
AND forests.name = 'Green Forest';

-- Conformance Item T49
SELECT shore.STUnion(boundary).STAsText()
FROM lakes, named_places
WHERE lakes.name = 'Blue Lake'
AND named_places.name = 'Goose Island';

-- Conformance Item T50
SELECT shore.STSymDifference(boundary).STAsText()
FROM lakes, named_places
WHERE lakes.name = 'Blue Lake'
AND named_places.name = 'Ashton';

-- Conformance Item T51
SELECT count(*)
FROM buildings, bridges
WHERE bridges.position.STBuffer(15.0).STContains(buildings.footprint) = 1

-- Conformance Item T52
SELECT shore.STConvexHull().STAsText()
FROM lakes
WHERE lakes.name = 'Blue Lake';


/*
USE master
GO
DROP DATABASE BlueLake
*/

