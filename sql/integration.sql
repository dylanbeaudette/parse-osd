--
-- load parsed OSD data into SoilWeb
--
-- 2015-06-20: it appears that the "fixed" data from Skye (errors/fixed-2.csv) is no longer needed


SET search_path TO osd, public;

-- wrap in a transaction
BEGIN;

-- create new table that contains colors
-- load our parsed OSD data into this table
DROP TABLE osd.osd_colors;
CREATE TABLE osd.osd_colors (
hzname varchar(20),
top numeric,
bottom numeric,
matrix_dry_color_hue varchar(10),
matrix_dry_color_value int,
matrix_dry_color_chroma int,
matrix_wet_color_hue varchar(10),
matrix_wet_color_value int,
matrix_wet_color_chroma int,
series citext
);

\copy osd.osd_colors FROM 'parsed-data-est-colors.csv' CSV HEADER NULL 'NA'

-- just in case convert series name to upper case
UPDATE osd.osd_colors SET series = UPPER(series);

-- index
CREATE INDEX osd_colors_series_idx ON osd_colors (series);

-- 
-- QA/QC
-- 
\i 'find-errors.sql'

--
-- apply manual fixes from Skye
--
\i 'manual-fixes/notes.sql'


-- create list of distinct series in or records
DROP TABLE osd.osd_on_file;
CREATE TABLE osd.osd_on_file AS
SELECT DISTINCT series as series 
FROM osd.osd_colors 
ORDER BY series;

-- index
CREATE INDEX osd_on_file_series_idx ON osd.osd_on_file (series);

COMMIT;

-- permissions
GRANT SELECT ON osd.osd_colors TO soil;
GRANT SELECT ON osd.osd_on_file TO soil;


--
-- manual fixes
--

-- rincon
INSERT INTO osd_colors VALUES ('Ap',0,10,'10YR',4,1,'10YR',3,1,'RINCON');
UPDATE osd_colors SET matrix_dry_color_hue = '10YR', matrix_dry_color_value = 4, matrix_dry_color_chroma = 1, matrix_wet_color_hue = '10YR', matrix_wet_color_value = 3, matrix_wet_color_chroma = 1 WHERE series = 'RINCON' AND hzname = 'A12';
UPDATE osd_colors SET matrix_dry_color_hue = '10YR', matrix_dry_color_value = 4, matrix_dry_color_chroma = 2, matrix_wet_color_hue = '10YR', matrix_wet_color_value = 3, matrix_wet_color_chroma = 2 WHERE series = 'RINCON' AND hzname = 'B21t';
UPDATE osd_colors SET matrix_dry_color_hue = '10YR', matrix_dry_color_value = 4, matrix_dry_color_chroma = 2, matrix_wet_color_hue = '10YR', matrix_wet_color_value = 3, matrix_wet_color_chroma = 2 WHERE series = 'RINCON' AND hzname = 'B22t';
UPDATE osd_colors SET matrix_dry_color_hue = '10YR', matrix_dry_color_value = 5, matrix_dry_color_chroma = 3, matrix_wet_color_hue = '10YR', matrix_wet_color_value = 4, matrix_wet_color_chroma = 3 WHERE series = 'RINCON' AND hzname = 'B3tca';
UPDATE osd_colors SET matrix_dry_color_hue = '10YR', matrix_dry_color_value = 5, matrix_dry_color_chroma = 4, matrix_wet_color_hue = '10YR', matrix_wet_color_value = 4, matrix_wet_color_chroma = 4 WHERE series = 'RINCON' AND hzname = 'Cca';


-- update index
VACUUM ANALYZE osd.osd_on_file;
VACUUM ANALYZE osd.osd_colors;

