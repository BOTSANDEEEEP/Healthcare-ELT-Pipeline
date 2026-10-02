#!/bin/bash
set -e

PROJECT_HOME="/home/sandeep/healthcare-elt"

echo "========== HEALTHCARE ELT PIPELINE STARTED =========="

echo "Step 1: Loading RAW data..."
bash "$PROJECT_HOME/scripts/load_raw.sh"

echo "Step 2: Running Hive transformation..."
hive -f "$PROJECT_HOME/scripts/transform_hive.sql"

echo "Step 3: Verifying analytics output..."
hive -e "SET mapreduce.framework.name=local; SELECT * FROM healthcare_elt.patient_analytics;"

echo "========== HEALTHCARE ELT PIPELINE COMPLETED =========="
