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
 
 
 -- example queries
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
