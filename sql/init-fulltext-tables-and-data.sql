-- note: these files will contain non-ASCII characters and some syntax errors
-- the .sql files set encoding before inserts
--
-- iconv -c fulltext-data.sql > fulltext-data-clean && mv fulltext-data-clean fulltext-data.sql
-- iconv -c fulltext-section-data.sql > fulltext-section-data-clean && mv fulltext-section-data-clean fulltext-section-data.sql
--
-- run manually
-- psql -U postgres ssurgo_combined < fulltext-data.sql
-- psql -U postgres ssurgo_combined < fulltext-section-data.sql


set search_path to osd, public;
\timing

-- ideas
-- http://www.postgresql.org/docs/9.1/static/textsearch-tables.html
-- http://www.postgresql.org/docs/9.1/static/datatype-textsearch.html
-- https://www.postgresql.org/docs/current/static/textsearch-dictionaries.html

-- assignment of weights to different fields
-- https://blog.lateral.io/2015/05/full-text-search-in-milliseconds-with-postgresql/


-- expression index: use stemming dictionary
CREATE INDEX osd_fulltext_idx ON osd.osd_fulltext USING gin(to_tsvector('english', fulltext));
vacuum ANALYZE osd.osd_fulltext ;

-- permissions
grant SELECT ON osd.osd_fulltext to soil;

--
-- copy CURRENT family level classification from osd.taxa into fulltext2
--
UPDATE osd.osd_fulltext2 SET taxonomic_class = taxa.family
FROM osd.taxa
WHERE osd_fulltext2.series = taxa.seriesname;


-- a "simple" dictionary for searches, this will not aggressively stem words
-- downside: this will "miss" words that are singular / plural unless wildcard matching is used

-- solution: different types of indexing
-- "english" index for most fields
CREATE INDEX osd_typical_pedon_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', typical_pedon));
CREATE INDEX osd_brief_narrative_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', brief_narrative));
CREATE INDEX osd_type_location_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', type_location));
CREATE INDEX osd_ric_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', ric));
CREATE INDEX osd_geog_location_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', geog_location));
CREATE INDEX osd_drainage_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', drainage));
CREATE INDEX osd_distribution_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', distribution));
CREATE INDEX osd_remarks_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', remarks));
CREATE INDEX osd_established_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', established));
CREATE INDEX osd_additional_data_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', additional_data));

-- "simple" index for fields where we expect series names
CREATE INDEX osd_use_and_veg_idx ON osd.osd_fulltext2 USING gin(to_tsvector('simple', use_and_veg));
CREATE INDEX osd_competing_series_idx ON osd.osd_fulltext2 USING gin(to_tsvector('simple', competing_series));
CREATE INDEX osd_geog_assoc_soils_idx ON osd.osd_fulltext2 USING gin(to_tsvector('simple', geog_assoc_soils));
CREATE INDEX osd_taxonomic_class_idx ON osd.osd_fulltext2 USING gin(to_tsvector('simple', taxonomic_class));

VACUUM ANALYZE osd.osd_fulltext2 ;

-- permissions
grant SELECT ON osd.osd_fulltext2 to soil;


-- quick check for OSDs missing key fulltext sections
CREATE TEMP TABLE missing_sections AS
SELECT series, 
CASE WHEN  typical_pedon = '' THEN 1 ELSE 0 END as tp,
CASE WHEN  brief_narrative = '' THEN 1 ELSE 0 END as bn,
CASE WHEN  competing_series = '' THEN 1 ELSE 0 END as cs,
CASE WHEN  geog_assoc_soils = '' THEN 1 ELSE 0 END as gs
from osd.osd_fulltext2
WHERE typical_pedon  = '' 
OR brief_narrative  = '' 
OR competing_series  = '' 
OR geog_assoc_soils  = '' ;

\copy missing_sections to 'missing-section-data.csv' CSV HEADER





