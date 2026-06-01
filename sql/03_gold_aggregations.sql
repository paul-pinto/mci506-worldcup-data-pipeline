-- ============================================================
-- 03_gold_aggregations.sql
-- Gold tables for Looker Studio dashboard.
-- ============================================================

CREATE OR REPLACE TABLE `mci506-paul-pinto.mci506_worldcup.gold_tournament_overview` AS
SELECT
  season,
  COUNT(DISTINCT fixture_id) AS total_matches,
  COUNT(DISTINCT venue_name) AS total_venues,
  COUNT(DISTINCT venue_city) AS total_cities,
  COUNT(DISTINCT home_team_id) + COUNT(DISTINCT away_team_id) AS rough_team_count,
  MIN(match_date) AS start_date,
  MAX(match_date) AS end_date,
  CURRENT_TIMESTAMP() AS generated_at
FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures`
GROUP BY season;

CREATE OR REPLACE TABLE `mci506-paul-pinto.mci506_worldcup.gold_matches_by_round` AS
SELECT
  season,
  round,
  COUNT(DISTINCT fixture_id) AS total_matches,
  MIN(match_date) AS first_match_date,
  MAX(match_date) AS last_match_date,
  CURRENT_TIMESTAMP() AS generated_at
FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures`
GROUP BY season, round
ORDER BY season, first_match_date;

CREATE OR REPLACE TABLE `mci506-paul-pinto.mci506_worldcup.gold_venue_load` AS
SELECT
  season,
  venue_name,
  venue_city,
  COUNT(DISTINCT fixture_id) AS total_matches,
  COUNTIF(LOWER(round) LIKE '%group%') AS group_stage_matches,
  COUNTIF(LOWER(round) NOT LIKE '%group%') AS knockout_matches,
  MIN(match_date) AS first_match_date,
  MAX(match_date) AS last_match_date,
  CURRENT_TIMESTAMP() AS generated_at
FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures`
GROUP BY season, venue_name, venue_city
ORDER BY total_matches DESC;

CREATE OR REPLACE TABLE `mci506-paul-pinto.mci506_worldcup.gold_team_schedule` AS
WITH team_matches AS (
  SELECT
    season,
    fixture_id,
    match_date,
    round,
    venue_name,
    venue_city,
    home_team_id AS team_id,
    home_team_name AS team_name,
    'home' AS side
  FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures`

  UNION ALL

  SELECT
    season,
    fixture_id,
    match_date,
    round,
    venue_name,
    venue_city,
    away_team_id AS team_id,
    away_team_name AS team_name,
    'away' AS side
  FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures`
),

with_rest AS (
  SELECT
    *,
    TIMESTAMP_DIFF(
      match_date,
      LAG(match_date) OVER (PARTITION BY season, team_id ORDER BY match_date),
      DAY
    ) AS rest_days
  FROM team_matches
)

SELECT
  season,
  team_id,
  team_name,
  COUNT(DISTINCT fixture_id) AS total_matches,
  COUNT(DISTINCT venue_name) AS venues_played,
  COUNT(DISTINCT venue_city) AS cities_played,
  MIN(match_date) AS first_match_date,
  MAX(match_date) AS last_match_date,
  MIN(rest_days) AS min_rest_days,
  AVG(rest_days) AS avg_rest_days,
  COUNTIF(rest_days < 4) AS short_rest_matches,
  CURRENT_TIMESTAMP() AS generated_at
FROM with_rest
GROUP BY season, team_id, team_name
ORDER BY total_matches DESC, team_name;

CREATE OR REPLACE TABLE `mci506-paul-pinto.mci506_worldcup.gold_group_summary` AS
SELECT
  season,
  group_name,
  COUNT(DISTINCT team_id) AS teams,
  AVG(points) AS avg_points,
  SUM(goals_for) AS total_goals_for,
  SUM(goals_against) AS total_goals_against,
  SUM(win) AS total_wins,
  SUM(draw) AS total_draws,
  SUM(lose) AS total_losses,
  CURRENT_TIMESTAMP() AS generated_at
FROM `mci506-paul-pinto.mci506_worldcup.silver_standings`
GROUP BY season, group_name
ORDER BY group_name;

CREATE OR REPLACE TABLE `mci506-paul-pinto.mci506_worldcup.gold_pipeline_quality` AS
WITH fixture_quality AS (
  SELECT
    'silver_fixtures' AS table_name,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT fixture_id) AS distinct_pk_count,
    COUNT(*) - COUNT(DISTINCT fixture_id) AS duplicate_pk_count,
    COUNTIF(fixture_id IS NULL) AS missing_pk_count,
    COUNTIF(match_date IS NULL) AS missing_critical_dates,
    COUNTIF(venue_name IS NULL) AS missing_critical_venues
  FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures`
),

team_quality AS (
  SELECT
    'silver_teams' AS table_name,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT team_id) AS distinct_pk_count,
    COUNT(*) - COUNT(DISTINCT team_id) AS duplicate_pk_count,
    COUNTIF(team_id IS NULL) AS missing_pk_count,
    0 AS missing_critical_dates,
    0 AS missing_critical_venues
  FROM `mci506-paul-pinto.mci506_worldcup.silver_teams`
),

standings_quality AS (
  SELECT
    'silver_standings' AS table_name,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT CONCAT(CAST(season AS STRING), '-', group_name, '-', CAST(team_id AS STRING))) AS distinct_pk_count,
    COUNT(*) - COUNT(DISTINCT CONCAT(CAST(season AS STRING), '-', group_name, '-', CAST(team_id AS STRING))) AS duplicate_pk_count,
    COUNTIF(team_id IS NULL) AS missing_pk_count,
    0 AS missing_critical_dates,
    0 AS missing_critical_venues
  FROM `mci506-paul-pinto.mci506_worldcup.silver_standings`
)

SELECT
  *,
  100
    - duplicate_pk_count * 5
    - missing_pk_count * 10
    - missing_critical_dates * 5
    - missing_critical_venues * 5
    AS quality_score,
  CURRENT_TIMESTAMP() AS generated_at
FROM fixture_quality

UNION ALL

SELECT
  *,
  100
    - duplicate_pk_count * 5
    - missing_pk_count * 10
    - missing_critical_dates * 5
    - missing_critical_venues * 5
    AS quality_score,
  CURRENT_TIMESTAMP() AS generated_at
FROM team_quality

UNION ALL

SELECT
  *,
  100
    - duplicate_pk_count * 5
    - missing_pk_count * 10
    - missing_critical_dates * 5
    - missing_critical_venues * 5
    AS quality_score,
  CURRENT_TIMESTAMP() AS generated_at
FROM standings_quality;