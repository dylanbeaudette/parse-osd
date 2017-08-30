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
  
 -- assignment of weights to different fields
 -- https://blog.lateral.io/2015/05/full-text-search-in-milliseconds-with-postgresql/
  
 -- expression index
 CREATE INDEX osd_fulltext_idx ON osd.osd_fulltext USING gin(to_tsvector('english', fulltext));
 vacuum ANALYZE osd.osd_fulltext ;
 -- permissions
 grant SELECT ON osd.osd_fulltext to soil;
 
 
 -- index all columns on sections
 CREATE INDEX osd_typical_pedon_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', typical_pedon));
 CREATE INDEX osd_type_location_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', type_location));
 CREATE INDEX osd_ric_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', ric));
 CREATE INDEX osd_competing_series_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', competing_series));
 CREATE INDEX osd_geog_location_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', geog_location));
 CREATE INDEX osd_geog_assoc_soils_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', geog_assoc_soils));
 CREATE INDEX osd_drainage_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', drainage));
 CREATE INDEX osd_use_and_veg_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', use_and_veg));
 CREATE INDEX osd_distribution_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', distribution));
 CREATE INDEX osd_remarks_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', remarks));
 CREATE INDEX osd_established_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', established));
 CREATE INDEX osd_additional_data_idx ON osd.osd_fulltext2 USING gin(to_tsvector('english', additional_data));
 
 VACUUM ANALYZE osd.osd_fulltext2 ;
 -- permissions
 grant SELECT ON osd.osd_fulltext2 to soil;
 
 
 