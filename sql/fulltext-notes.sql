-- note: these files will contain non-ASCII characters
-- load after setting:  set client_encoding to 'latin1'
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
 vacuum ANALYZE osd_fulltext ;
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
 
 VACUUM ANALYZE osd_fulltext2 ;
 -- permissions
 grant SELECT ON osd.osd_fulltext2 to soil;
 
 
 
 
 -- chain multiple full text searches and rankings
 -- not very fast
SELECT series, sum(rank) as score
FROM (
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', typical_pedon), to_tsquery('english', 'Bt')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', typical_pedon) @@ to_tsquery('english', 'Bt')
	ORDER BY rank DESC
	LIMIT 20
	) as a
UNION ALL
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', ric), to_tsquery('english', 'Bt')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', ric) @@ to_tsquery('english', 'Bt')
	ORDER BY rank DESC
	LIMIT 20
	) as a
UNION ALL
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', competing_series), to_tsquery('english', 'argillic')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', competing_series) @@ to_tsquery('english', 'argillic')
	ORDER BY rank DESC
	LIMIT 20
	) as a
UNION ALL
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', geog_location), to_tsquery('english', 'hills')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', geog_location) @@ to_tsquery('english', 'hills')
	ORDER BY rank DESC
	LIMIT 20
	) as a
) as b
GROUP BY series
ORDER BY score DESC;





SELECT series
FROM osd_fulltext2 
WHERE to_tsvector('english', geog_assoc_soils) @@ to_tsquery('english', 'amador');

 
 
SELECT series, ts_rank(to_tsvector('english', geog_assoc_soils), to_tsquery('english', 'amador'), 32) AS rank
FROM osd_fulltext2
WHERE to_tsvector('english', geog_assoc_soils) @@ to_tsquery('english', 'amador')
ORDER BY rank DESC
LIMIT 10;

 
 
 
 -- note that the 2 argument version of to_tsXXX is used
SELECT series 
FROM osd_fulltext 
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyolite & amador');

SELECT series 
FROM osd.osd_fulltext 
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyolite & amador'::tsvector);

-- basic ranking
SELECT series, ts_rank_cd(to_tsvector('english', fulltext), to_tsquery('english', 'thermic & rhyo:* & amador')) AS rank
FROM osd_fulltext
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyo:* & amador')
ORDER BY rank DESC
LIMIT 10;

-- normalized ranking
SELECT series, ts_rank_cd(to_tsvector('english', fulltext), to_tsquery('english', 'thermic & rhyo:* & tuff:* & xer:*'), 32) AS rank
FROM osd_fulltext
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyo:* & tuff:* & xer:*')
ORDER BY rank DESC
LIMIT 10;

