#!/usr/bin/env bash

set -e

export SHELL  # makes 'parallel' stop complaining about $SHELL being unset

cd `dirname $0`
source utils.sh

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_OUTPUT_SRID="${NB_OUTPUT_SRID:-2163}"
NB_MAX_TRIP_DISTANCE="${NB_MAX_TRIP_DISTANCE:-3300}"
NB_MAX_DEVIATION="${NB_MAX_DEVIATION:-0.3}"             # maximum low stress deviation (percentage)
TOLERANCE_COLLEGES="${TOLERANCE_COLLEGES:-100}"         # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_COMM_CTR="${TOLERANCE_COMM_CTR:-50}"          # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_MEDICAL="${TOLERANCE_MEDICAL:-50}"            # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_PARKS="${TOLERANCE_PARKS:-50}"                # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_RETAIL="${TOLERANCE_RETAIL:-50}"              # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_UNIVERSITIES="${TOLERANCE_UNIVERSITIES:-150}" # cluster tolerance given in units of $NB_OUTPUT_SRID
MIN_PATH_LENGTH="${MIN_PATH_LENGTH:-4800}"              # minimum path length to be considered for recreation access
MIN_PATH_BBOX="${MIN_PATH_BBOX:-3300}"                  # minimum corner-to-corner span of path bounding box to be considered for recreation access
BLOCK_ROAD_BUFFER="${BLOCK_ROAD_BUFFER:-15}"            # buffer distance to find roads associated with a block
BLOCK_ROAD_MIN_LENGTH="${BLOCK_ROAD_MIN_LENGTH:-30}"    # minimum length road must overlap with block buffer to be associated

# Limit custom output formatting for `time` command
export TIME="\nTIMING: %C\nTIMING:\t%E elapsed %Kkb mem\n"

update_status "BUILDING" "Building network"
/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/build_network.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v block_road_buffer="${BLOCK_ROAD_BUFFER}" \
  -v block_road_min_length="${BLOCK_ROAD_MIN_LENGTH}" \
  -f ../connectivity/census_blocks.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/connected_census_blocks_prep.sql

update_status "CONNECTIVITY" "Connected census blocks"
/usr/bin/time parallel<<EOF
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=0 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=1 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=2 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=3 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=4 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=5 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=6 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=7 -v nb_max_trip_distance="${NB_MAX_TRIP_DISTANCE}" -v nb_max_deviation="${NB_MAX_DEVIATION}" -f ../connectivity/connected_census_blocks_calc.sql
EOF

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/connected_census_blocks_cleanup.sql

update_status "METRICS" "Access: population"
/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_population.sql

update_status "METRICS" "Access: jobs"
/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/census_block_jobs.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_jobs.sql

update_status "METRICS" "Destinations"
/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_COLLEGES}" \
  -f ../connectivity/destinations/colleges.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_COMM_CTR}" \
  -f ../connectivity/destinations/community_centers.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_MEDICAL}" \
  -f ../connectivity/destinations/medical.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_PARKS}" \
  -f ../connectivity/destinations/parks.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_RETAIL}" \
  -f ../connectivity/destinations/retail.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/schools.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/social_services.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/supermarkets.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_UNIVERSITIES}" \
  -f ../connectivity/destinations/universities.sql

update_status "METRICS" "Access: colleges"
/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_colleges.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_community_centers.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_medical.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_parks.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_retail.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_schools.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_social_services.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_supermarkets.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v min_path_length="${MIN_PATH_LENGTH}" \
  -v min_bbox_length="${MIN_PATH_BBOX}" \
  -f ../connectivity/access_trails.sql

/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_universities.sql

update_status "METRICS" "Overall scores"
/usr/bin/time psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/overall_scores.sql
