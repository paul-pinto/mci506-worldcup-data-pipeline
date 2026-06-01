-- ============================================================
-- 02_silver_transform.sql
-- Native Silver tables with incremental deduplication.
-- Required pattern: WHERE NOT EXISTS.
-- ============================================================

CREATE TABLE IF NOT EXISTS `mci506-paul-pinto.mci506_worldcup.silver_fixtures` (
  fixture_id INT64,
  referee STRING,
  timezone STRING,
  match_date TIMESTAMP,
  match_timestamp INT64,
  venue_id INT64,
  venue_name STRING,
  venue_city STRING,
  status_long STRING,
  status_short STRING,
  elapsed INT64,
  league_id INT64,
  league_name STRING,
  country STRING,
  season INT64,
  round STRING,
  home_team_id INT64,
  home_team_name STRING,
  home_team_winner BOOL,
  away_team_id INT64,
  away_team_name STRING,
  away_team_winner BOOL,
  goals_home INT64,
  goals_away INT64,
  fulltime_home INT64,
  fulltime_away INT64,
  ingestion_timestamp TIMESTAMP
);

INSERT INTO `mci506-paul-pinto.mci506_worldcup.silver_fixtures`
SELECT
  SAFE_CAST(fixture_id AS INT64) AS fixture_id,
  CAST(referee AS STRING) AS referee,
  CAST(timezone AS STRING) AS timezone,
  SAFE_CAST(match_date AS TIMESTAMP) AS match_date,
  SAFE_CAST(timestamp AS INT64) AS match_timestamp,
  SAFE_CAST(venue_id AS INT64) AS venue_id,
  CAST(venue_name AS STRING) AS venue_name,
  CAST(venue_city AS STRING) AS venue_city,
  CAST(status_long AS STRING) AS status_long,
  CAST(status_short AS STRING) AS status_short,
  SAFE_CAST(elapsed AS INT64) AS elapsed,
  SAFE_CAST(league_id AS INT64) AS league_id,
  CAST(league_name AS STRING) AS league_name,
  CAST(country AS STRING) AS country,
  SAFE_CAST(season AS INT64) AS season,
  CAST(round AS STRING) AS round,
  SAFE_CAST(home_team_id AS INT64) AS home_team_id,
  CAST(home_team_name AS STRING) AS home_team_name,
  SAFE_CAST(home_team_winner AS BOOL) AS home_team_winner,
  SAFE_CAST(away_team_id AS INT64) AS away_team_id,
  CAST(away_team_name AS STRING) AS away_team_name,
  SAFE_CAST(away_team_winner AS BOOL) AS away_team_winner,
  SAFE_CAST(goals_home AS INT64) AS goals_home,
  SAFE_CAST(goals_away AS INT64) AS goals_away,
  SAFE_CAST(fulltime_home AS INT64) AS fulltime_home,
  SAFE_CAST(fulltime_away AS INT64) AS fulltime_away,
  CURRENT_TIMESTAMP() AS ingestion_timestamp
FROM `mci506-paul-pinto.mci506_worldcup.ext_fixtures_flat` ext
WHERE NOT EXISTS (
  SELECT 1
  FROM `mci506-paul-pinto.mci506_worldcup.silver_fixtures` s
  WHERE s.fixture_id = SAFE_CAST(ext.fixture_id AS INT64)
);

CREATE TABLE IF NOT EXISTS `mci506-paul-pinto.mci506_worldcup.silver_teams` (
  team_id INT64,
  team_name STRING,
  team_code STRING,
  team_country STRING,
  team_founded INT64,
  team_national BOOL,
  team_logo STRING,
  venue_id INT64,
  venue_name STRING,
  venue_address STRING,
  venue_city STRING,
  venue_capacity INT64,
  venue_surface STRING,
  venue_image STRING,
  ingestion_timestamp TIMESTAMP
);

INSERT INTO `mci506-paul-pinto.mci506_worldcup.silver_teams`
SELECT
  SAFE_CAST(team_id AS INT64) AS team_id,
  CAST(team_name AS STRING) AS team_name,
  CAST(team_code AS STRING) AS team_code,
  CAST(team_country AS STRING) AS team_country,
  SAFE_CAST(team_founded AS INT64) AS team_founded,
  SAFE_CAST(team_national AS BOOL) AS team_national,
  CAST(team_logo AS STRING) AS team_logo,
  SAFE_CAST(venue_id AS INT64) AS venue_id,
  CAST(venue_name AS STRING) AS venue_name,
  CAST(venue_address AS STRING) AS venue_address,
  CAST(venue_city AS STRING) AS venue_city,
  SAFE_CAST(venue_capacity AS INT64) AS venue_capacity,
  CAST(venue_surface AS STRING) AS venue_surface,
  CAST(venue_image AS STRING) AS venue_image,
  CURRENT_TIMESTAMP() AS ingestion_timestamp
FROM `mci506-paul-pinto.mci506_worldcup.ext_teams_flat` ext
WHERE NOT EXISTS (
  SELECT 1
  FROM `mci506-paul-pinto.mci506_worldcup.silver_teams` s
  WHERE s.team_id = SAFE_CAST(ext.team_id AS INT64)
);

CREATE TABLE IF NOT EXISTS `mci506-paul-pinto.mci506_worldcup.silver_standings` (
  league_id INT64,
  league_name STRING,
  country STRING,
  season INT64,
  group_name STRING,
  rank INT64,
  team_id INT64,
  team_name STRING,
  points INT64,
  goals_diff INT64,
  form STRING,
  status STRING,
  description STRING,
  played INT64,
  win INT64,
  draw INT64,
  lose INT64,
  goals_for INT64,
  goals_against INT64,
  update_timestamp TIMESTAMP,
  ingestion_timestamp TIMESTAMP
);

INSERT INTO `mci506-paul-pinto.mci506_worldcup.silver_standings`
SELECT
  SAFE_CAST(league_id AS INT64) AS league_id,
  CAST(league_name AS STRING) AS league_name,
  CAST(country AS STRING) AS country,
  SAFE_CAST(season AS INT64) AS season,
  CAST(`group` AS STRING) AS group_name,
  SAFE_CAST(rank AS INT64) AS rank,
  SAFE_CAST(team_id AS INT64) AS team_id,
  CAST(team_name AS STRING) AS team_name,
  SAFE_CAST(points AS INT64) AS points,
  SAFE_CAST(goals_diff AS INT64) AS goals_diff,
  CAST(form AS STRING) AS form,
  CAST(status AS STRING) AS status,
  CAST(description AS STRING) AS description,
  SAFE_CAST(played AS INT64) AS played,
  SAFE_CAST(win AS INT64) AS win,
  SAFE_CAST(draw AS INT64) AS draw,
  SAFE_CAST(lose AS INT64) AS lose,
  SAFE_CAST(goals_for AS INT64) AS goals_for,
  SAFE_CAST(goals_against AS INT64) AS goals_against,
  SAFE_CAST(`update` AS TIMESTAMP) AS update_timestamp,
  CURRENT_TIMESTAMP() AS ingestion_timestamp
FROM `mci506-paul-pinto.mci506_worldcup.ext_standings_flat` ext
WHERE NOT EXISTS (
  SELECT 1
  FROM `mci506-paul-pinto.mci506_worldcup.silver_standings` s
  WHERE s.season = SAFE_CAST(ext.season AS INT64)
    AND s.group_name = CAST(ext.`group` AS STRING)
    AND s.team_id = SAFE_CAST(ext.team_id AS INT64)
);