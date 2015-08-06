/**
 * Bioko CIMS Data Extraction Queries
 * 
 * The following queries were developed to enable MCDI staff to do a bulk
 * extraction of data from ODK form tables. They were originally developed as a
 * temporary replacement for a failing data extraction process using Pentaho.
 * While they offered some relief, these original queries started failling
 * themselves.
 * 
 * Jul/Aug 2015 - After identifying the root causes of the query failures, Brent
 * Atkinson and Smita Sukhadeve modified some of these and tuned the relevant
 * database tables to allow extremely slow or failing queries to perform better.
 * Not all queries were optimized/rewritten, and as the data grows some will
 * need to be rewritten and/or the database re-tuned. In general, bulk export
 * is inherently expensive and a better approach would be targeted queries
 * rather than bulks dumps.
 **/


/**
 * Dump the individual forms. This extracts all individuals collected during the
 * given date range (modify the range for your needs). The group-by subquery is
 * only necessary to eliminate duplicate submissions. It removes duplicates
 * based on collection date/time and ext id.
 */
SELECT
  i.*
FROM
  odk_prod.INDIVIDUAL_CORE i
JOIN
  (SELECT 
    MAX(_URI) as _URI
  FROM 
    odk_prod.INDIVIDUAL_CORE
  GROUP BY
    COLLECTION_DATE_TIME, ENTITY_EXT_ID) max_uri on max_uri._URI = i._URI
WHERE
  i.COLLECTION_DATE_TIME >= date('2014-06-02')
  and i.COLLECTION_DATE_TIME < date('2016-06-08');


/**
 * Dump the bed net forms with not sprayed answers. This extracts all bed net
 * forms collected during the given date range (modify the range for your
 * needs). The group-by subquery is only necessary to eliminate duplicate
 * submissions. It removes duplicates based on ext id.
 * 
 * Note: Execution time can be significantly improved if sorting by distribution
 * date isn't essential and can be performed outside of this query.
 */
SELECT
  i.*, n.*
FROM odk_prod.BED_NET_CORE i 
JOIN
  (SELECT 
    MAX(_URI) as _URI
  FROM 
    odk_prod.BED_NET_CORE
  GROUP BY
    LOCATION_EXT_ID) max_uri ON max_uri._URI = i._URI  
LEFT JOIN 
  odk_prod.BED_NET_WHY_NOT_SPRAYED n ON n._PARENT_AURI = max_uri._URI 
WHERE
  DISTRIBUTION_DATE_TIME >= date('2014-01-01')
  and DISTRIBUTION_DATE_TIME < date('2016-01-01')
ORDER BY 
  DISTRIBUTION_DATE_TIME;


/**
 * Dump the bed net forms without sub-elements. This extracts all bed net forms
 * collected during the given date range (modify the range for your needs). The
 * group-by subquery is only necessary to eliminate duplicate submissions. It
 * removes duplicates based on ext id.
 * 
 * Note: Execution time can be significantly improved if sorting by distribution
 * date is possible outside of this query.
 */
SELECT
  i.*
FROM
  odk_prod.BED_NET_CORE i
JOIN
  (SELECT 
    MAX(_URI) as _URI
  FROM 
    odk_prod.BED_NET_CORE
  GROUP BY
    LOCATION_EXT_ID) max_uri ON max_uri._URI = i._URI
WHERE 
  i.DISTRIBUTION_DATE_TIME >= date('2014-01-01')
  AND i.DISTRIBUTION_DATE_TIME < date('2016-01-01')
ORDER BY i.DISTRIBUTION_DATE_TIME;


/**
 * Dump counts for bed nets.
 */
SELECT 
  LOCATION_EXT_ID as `UNIQUEBID`,
  NET_CODE as `Net code`, 
  NETS_SUPPLIED as `Nets Supplied`,
  COALESCE(NETS_HUNG,0)  as `Nets Hung`
FROM 
  odk_prod.BED_NET_CORE;

/**
 * Dump the death forms. This extracts all forms collected during the given date
 * range (modify it for your needs). It removes duplicates based on ext id.
 */
SELECT 
  * 
FROM 
  odk_prod.DEATH_CORE
WHERE 
  COLLECTION_DATE_TIME >= date('2014-01-01')
  AND COLLECTION_DATE_TIME < date('2016-01-01')
GROUP BY 
  ENTITY_EXT_ID
ORDER BY 
  COLLECTION_DATE_TIME;


/**
 * Dump the in-migration forms. This extracts all forms collected during the
 * given date range (modify it for your needs). It removes diuplicates based on
 * ext id.
 */
SELECT 
  * 
FROM 
  odk_prod.IN_MIGRATION_CORE
WHERE 
  COLLECTION_DATE_TIME >= date('2014-01-01')
  AND COLLECTION_DATE_TIME < date('2016-01-01')
GROUP BY 
  ENTITY_EXT_ID
ORDER BY 
  COLLECTION_DATE_TIME;


/**
 * Dump the location forms. This extracts all forms collected during the given
 * date range (modify it for your needs).
 */
SELECT 
  * 
FROM 
  odk_prod.LOCATION_CORE 
WHERE 
  COLLECTION_DATE_TIME >= date('2014-01-01')
  AND COLLECTION_DATE_TIME < date('2016-01-01')
ORDER BY
  COLLECTION_DATE_TIME;


/**
 * Dump the location evaluation forms. This extracts all forms collected during
 * the given date range (modify it for your needs). It removes duplicates based
 * on ext ids.
 */
SELECT 
  * 
FROM 
  odk_prod.LOCATION_EVALUATION_CORE ec
JOIN
  odk_prod.LOCATION_EVALUATION_EVALUATION ee ON ee._PARENT_AURI = ec._URI
WHERE
  COLLECTION_DATE_TIME >= date('2014-01-01')
  AND COLLECTION_DATE_TIME < date('2016-01-01')
GROUP BY 
  ENTITY_EXT_ID
ORDER BY 
  COLLECTION_DATE_TIME;


/**
 * Dump the out-migration forms. This extracts all forms collected during the
 * given date range (modify it for your needs). It removes duplicates ased on
 * ext ids.
 */
SELECT
  * 
FROM 
  odk_prod.OUT_MIGRATION_CORE 
WHERE 
  OUT_MIGRATION_DATE >= date('2014-01-01')
  AND OUT_MIGRATION_DATE < date('2016-01-01')
GROUP BY 
  ENTITY_EXT_ID
ORDER BY 
  OUT_MIGRATION_DATE;


/**
 * Dump the pregnancy observation forms. This extracts all forms collected
 * during the given date range (modify it for your needs). It removes duplicates
 * based on ext id/creation date.
 */
SELECT 
  * 
FROM 
  odk_prod.PREGNANCY_OBSERVATION_CORE 
WHERE 
  RECORDED_DATE >= date('2014-01-01')
  AND RECORDED_DATE < date('2016-01-01')
GROUP BY 
  INDIVIDUAL_EXT_ID, _CREATION_DATE
ORDER BY 
  RECORDED_DATE;


/**
 * Dump the visit forms. This extracts all forms collected for the given date
 * range (modify it for your needs). It removes dulicates based on ext id.
 */
SELECT 
  * 
FROM 
  odk_prod.VISIT_CORE 
WHERE
  VISIT_DATE >= date('2014-01-01')
  AND VISIT_DATE < date('2016-01-01')
GROUP BY
  ENTITY_EXT_ID
ORDER BY
  VISIT_DATE;

