#!/bin/bash
set -e

echo "Starting RAW data load..."

echo "Loading JSON visits into HDFS..."
hdfs dfs -mkdir -p /healthcare-elt/raw/visits
hdfs dfs -put -f \
  /home/sandeep/healthcare-elt/data/patient_visits.json \
  /healthcare-elt/raw/visits/

echo "Importing patients from MySQL..."
hdfs dfs -rm -r -f /healthcare-elt/raw/patients

sqoop import \
  --connect jdbc:mysql://localhost:3306/healthcare \
  --username sqoop_user \
  --password-file file:///home/sandeep/.sqoop_healthcare_password \
  --table patients \
  --columns "age,city,gender,patient_id,patient_name" \
  --target-dir /healthcare-elt/raw/patients \
  --m 1

echo "RAW data load completed."
