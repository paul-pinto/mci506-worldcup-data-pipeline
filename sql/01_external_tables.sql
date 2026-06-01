-- ============================================================
-- 01_external_tables.sql
-- External tables over CSV files stored in GCS Bronze.
-- ============================================================

CREATE OR REPLACE EXTERNAL TABLE `mci506-paul-pinto.mci506_worldcup.ext_fixtures_flat`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mci506-worldcup/bronze/processed/fixtures_flat.csv'],
  skip_leading_rows = 1,
  autodetect = TRUE
);

CREATE OR REPLACE EXTERNAL TABLE `mci506-paul-pinto.mci506_worldcup.ext_teams_flat`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mci506-worldcup/bronze/processed/teams_flat.csv'],
  skip_leading_rows = 1,
  autodetect = TRUE
);

CREATE OR REPLACE EXTERNAL TABLE `mci506-paul-pinto.mci506_worldcup.ext_standings_flat`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mci506-worldcup/bronze/processed/standings_flat.csv'],
  skip_leading_rows = 1,
  autodetect = TRUE
);

CREATE OR REPLACE EXTERNAL TABLE `mci506-paul-pinto.mci506_worldcup.ext_overview`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mci506-worldcup/bronze/eda/overview.csv'],
  skip_leading_rows = 1,
  autodetect = TRUE
);

CREATE OR REPLACE EXTERNAL TABLE `mci506-paul-pinto.mci506_worldcup.ext_quality_summary`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mci506-worldcup/bronze/eda/quality_summary.csv'],
  skip_leading_rows = 1,
  autodetect = TRUE
);