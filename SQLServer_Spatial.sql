/*
Introduction to SQL Spatial Data: Location Analytics

In this session we will cover Spatial Data Types available in SQL Server. 
Then we will review the basics of spatial queries and the different methods to 
create points, lines, and polygons. Finally we will demo a few examples of 
location analytics and how to integrate into other data sets.


There are two spatial data types Geometry (flat) and Geography (round).


##### Documentation and Reference Links
Microsoft SQL Documentation - Spatial Data
https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-data-sql-server
Introduction to SQL Server Spatial Data
https://www.red-gate.com/simple-talk/sql/t-sql-programming/introduction-to-sql-server-spatial-data/
SQL Server Spatial Indexes
https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-spatial-indexes/
MSSQLTips - SQL Server 2008 Geography and Geometry Data Types
https://www.mssqltips.com/sqlservertip/1847/sql-server-2008-geography-and-geometry-data-types/
SQLShack - Spatial data types in SQL Server
https://www.sqlshack.com/spatial-data-types-in-sql-server/



##### GIS Books - Alastair Aitchison
Expert SQL Server 2008 Development
https://www.apress.com/gp/book/9781430272137
Beginning Spatial with SQL Server 2008
https://www.apress.com/gp/book/9781430218296
Pro Spatial with SQL Server 11
https://www.apress.com/gp/book/9781430234913
Blog - https://alastaira.wordpress.com/



##### Open Geospatial Consortium (OGC)
https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/ogc-methods-on-geometry-instances?view=sql-server-2017
International not for profit organization
Quality open standard for the global geospatial community

Simple Feature Access
Part 1: Common Architecture
http://www.opengeospatial.org/standards/sfa
Part 2: SQL Option
http://www.opengeospatial.org/standards/sfs
More information at their web site
https://www.opengeospatial.org



##### Spatial Reference Identifiers
SRIDs are used to locate geographical entities
The most common is GPS
Global Positioning System
World Geodetic System: WGS84
SRID 4326 
SRIDs are maintained by
European Petroleum Survey Group (EPSG)
International Association of Oil and Gas Producers (IOGP)
http://www.epsg.org/



##### GIS File Formats and QGIS Desktop viewer
Shapefile
Topologically Integrated Geographic Encoding and Referencing (TIGER)
GeoJSON
Keyhole Markup Language (KML)
Geography Markup Language (GML) 

Quantum GIS (QGIS) - www.qgis.org
Free and open source geographic information system
*/




-- Create some spatial data - Point, Line, and Polygon
SELECT geography::STPointFromText('POINT(-122.34900 47.65100)', 4326); --.STBuffer(10);
SELECT geography::STLineFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326);
SELECT geography::STPolyFromText('POLYGON((-122.358 47.653, -122.348 47.649, -122.348 47.658, -122.358 47.658, -122.358 47.653))', 4326);







/*
##### GDAL and Quantum GIS
https://gdal.org
GDAL is a translator library for raster and vector geospatial data formats that 
is released under an X/MIT style Open Source License by the Open Source 
Geospatial Foundation. As a library, it presents a single raster abstract data 
model and single vector abstract data model to the calling application for all 
supported formats. It also comes with a variety of useful command line 
utilities for data translation and processing. 

Quantum GIS (QGIS) - https://www.qgis.org
Free and open source geographic information system

https://www.qgis.org/en/site/forusers/download.html

This will install OSGeo4W which is a binary distribution of a broad set of 
open source geospatial software for Windows environments.
https://trac.osgeo.org/osgeo4w/

The tool that will be used to load and convert data is called ogr2ogr.
This should be installed here = C:\OSGeo4W64 and in the bin folder is ogr2ogr.

Documentation for ogr2ogr can be found here. https://gdal.org/programs/ogr2ogr.html



##### Demo - United States Wind Turbine and Highways - Data downloads

TIGER/Line Shapefile, 2017, nation, U.S., Current State and Equivalent National
https://www2.census.gov/geo/tiger/TIGER2017/STATE/tl_2017_us_state.zip

United States Census Bureau - TIGER2016 Primary Roads - Highway 
http://www2.census.gov/geo/tiger/TIGER2016/PRIMARYROADS/tl_2016_us_primaryroads.zip

United States Wind Turbine Database
https://eerscmap.usgs.gov/uswtdb/assets/data/uswtdbSHP.zip

*/

/*
1. Download the three files from the above links.
2. Extract the contents of each zip file to c:\spatial folder.
3. Create a new database called SQLSat on your SQL Server instance.
4. Run the following commands in a command prompt to load the shapefiles.
5. Make sure you change the server instance to match your instance.

These can take some time to load and using the -progress switch is helpful to know how long until complete.

C:\OSGeo4W64\bin\ogr2ogr -progress -a_srs "EPSG:4326" -overwrite -f MSSQLSpatial "MSSQL:server=LAFDATA;database=SQLSat;trusted_connection=yes;" "tl_2017_us_state.shp"
C:\OSGeo4W64\bin\ogr2ogr -progress -a_srs "EPSG:4326" -overwrite -f MSSQLSpatial "MSSQL:server=LAFDATA;database=SQLSat;trusted_connection=yes;" "tl_2016_us_primaryroads.shp"
C:\OSGeo4W64\bin\ogr2ogr -progress -a_srs "EPSG:4326" -overwrite -f MSSQLSpatial "MSSQL:server=LAFDATA;database=SQLSat;trusted_connection=yes;" "uswtdb_v2_1_20190715.shp"

Once these have been loaded we will need to create new tables to only focus on a single state.
*/

DROP DATABASE IF EXISTS [SQLSat]

CREATE DATABASE [SQLSat]


DROP TABLE IF EXISTS [dbo].[windmill]
DROP TABLE IF EXISTS [dbo].[highway]
DROP TABLE IF EXISTS [dbo].[state]


CREATE TABLE [dbo].[windmill]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[geo] [geography] NULL,
	[state] [varchar](255) NULL,
	[name] [varchar](255) NULL,
	[mfg] [varchar](255) NULL,
	CONSTRAINT [PK_windmill_ID] 
	PRIMARY KEY CLUSTERED ( [id] ASC )
)
GO

CREATE TABLE [dbo].[highway]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[geo] [geography] NULL,
	[name] [nvarchar](100) NULL,
	CONSTRAINT [PK_Highway_ID] 
	PRIMARY KEY CLUSTERED ( [id] ASC )
)
GO

CREATE TABLE [dbo].[state]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[geo] [geography] NULL,
	[name] [nvarchar](100) NULL,
	CONSTRAINT [PK_States_ID] 
	PRIMARY KEY CLUSTERED ( [id] ASC )
)
GO




INSERT INTO dbo.highway( name, geo)
SELECT FULLNAME, 
GEOGRAPHY::STGeomFromText( ogr_geometry.STAsText(), 4326)
FROM dbo.tl_2016_us_primaryroads r
CROSS APPLY (
	SELECT 
	name, 
	ogr_geometry geo
	FROM dbo.tl_2017_us_state
	WHERE name = 'Indiana'
) s
WHERE r.ogr_geometry.STIntersects(s.geo) = 1



INSERT INTO dbo.windmill (geo,state,name,mfg)
SELECT 
geography::Point(ylat,xlong,4326), 
t_state, 
p_name, 
t_manu
FROM dbo.uswtdb_v2_1_20190715 w
CROSS APPLY (
	SELECT 
	name, 
	ogr_geometry geo
	FROM dbo.tl_2017_us_state
	WHERE name = 'Indiana'
) s
WHERE w.ogr_geometry.STIntersects(s.geo) = 1




INSERT INTO dbo.state (geo,name)
SELECT 
geography::STGeomFromText(
	ogr_geometry.STUnion(
		ogr_geometry.STStartPoint()
	).STAsText(),4326) ,
name	
FROM dbo.tl_2017_us_state 
WHERE name NOT IN (
'Guam',
'Puerto Rico',
'Hawaii',
'Alaska',
'United States Virgin Islands',
'Commonwealth of the Northern Mariana Islands',
'American Samoa')





--Now that we have cleaned the data, let's look at find the distance of a windmill to all highways.
SELECT 
w.id w_id,
h.id h_id,
w.geo.Lat,
w.geo.Long,
w.state ,
w.mfg ,
w.name windmill,
h.name highway,

h.geo.STDistance(w.geo) ,

h.geo ,
w.geo 

FROM (
	select top 1 * 
	from dbo.windmill
	where name = 'Roscoe'
) w
CROSS APPLY dbo.highway h
ORDER BY w.geo.STDistance(h.geo) 


-- This returned w_id = 137 and h_id = 625 being the closest. Let's look at this closer.
-- The STBuffer will create a boundary around the windmill so that it will show up.

select name, geo.STBuffer(1000) from dbo.windmill where id = 137
union all
select name, geo from dbo.highway where id = 625



-- Now let's calculate the distance between all windmills and all highways.
-- There should be 926 highways and 14,303 windmills.
-- This will produce 13,244,578 calculations (926 * 14,303)
-- The estimated amount of time is 00:29:14
SELECT 
w.id w_id,
h.id h_id,
w.state ,
w.mfg ,
w.name windmill,
h.name highway,
h.geo.STDistance(w.geo) 
FROM dbo.windmill w
CROSS APPLY dbo.highway h


-- To speed up this query we need to index the geography columns.
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-spatial-indexes/


-- 1 mile = 1609.344 meters
-- The actual amount of time was 00:12:23

SELECT 
w.id w_id,
h.id h_id,
w.state ,
w.mfg ,
w.name windmill,
h.name highway,
h.geo.STDistance(w.geo) 

from dbo.windmill w
cross apply dbo.highway h 
WHERE w.geo.STDistance(h.geo) < 1609.344 * 10.0 
order by w.geo.STDistance(h.geo) 






-- Create the indexes


DROP INDEX IF EXISTS [spx_windmill] ON [dbo].[windmill]
DROP INDEX IF EXISTS [spx_highway] ON [dbo].[highway]

CREATE SPATIAL INDEX [spx_windmill] 
ON [dbo].[windmill] ( [geo] ) 
USING GEOGRAPHY_GRID 
WITH ( 
	GRIDS = (
	     LEVEL_1 = MEDIUM,
		 LEVEL_2 = MEDIUM,
		 LEVEL_3 = MEDIUM,
		 LEVEL_4 = HIGH
    ), 
	CELLS_PER_OBJECT = 16
) 

CREATE SPATIAL INDEX [spx_highway] 
ON [dbo].[highway] ( [geo] ) 
USING GEOGRAPHY_GRID 
WITH ( 
	GRIDS = (
	     LEVEL_1 = LOW,
		 LEVEL_2 = LOW,
		 LEVEL_3 = MEDIUM,
		 LEVEL_4 = HIGH
    ), 
	CELLS_PER_OBJECT = 16
) 






-- Run the same query again
-- Lets review the statistics of the query
-- The actual amount of time is 00:00:11
set statistics time on
go

SELECT 
w.id w_id,
h.id h_id,
w.state ,
w.mfg ,
w.name windmill,
h.name highway,
h.geo.STDistance(w.geo) 

from dbo.windmill w
cross apply dbo.highway h 
WHERE w.geo.STDistance(h.geo) < 1609.344 * 10.0 
order by w.geo.STDistance(h.geo) 

set statistics time off
go



-- The actual amount of time for the entire data set is 00:01:33
SELECT 
w.state ,
COUNT(0)
FROM dbo.windmill w
CROSS APPLY dbo.highway h 
WHERE w.geo.STDistance(h.geo) < 1609.344 * 10.0 
GROUP BY w.state
ORDER BY count(0) DESC


