ADD JAR /opt/apache-hive-3.1.3-bin/hcatalog/share/hcatalog/hive-hcatalog-core-3.1.3.jar;
CREATE DATABASE IF NOT EXISTS healthcare_elt;
USE healthcare_elt;

-- Execution settings for WSL local mode
SET mapreduce.framework.name=local;
SET mapreduce.task.io.sort.mb=32;
SET hive.auto.convert.join=false;

-- 1. Create Raw Patients External Table
CREATE EXTERNAL TABLE IF NOT EXISTS patients_raw (
    age INT,
    city STRING,
    gender STRING,
    patient_id STRING,
    patient_name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/healthcare-elt/raw/patients';
-- 2. Create Raw Visits External Table (JSON SerDe)
CREATE EXTERNAL TABLE IF NOT EXISTS visits_raw (
    visit_id STRING,
    patient_id STRING,
    doctor STRING,
    department STRING,
    diagnosis STRING,
    amount DOUBLE,
    visit_date STRING
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
LOCATION '/healthcare-elt/raw/visits';

-- 3. Create Analytics Target Table
DROP TABLE IF EXISTS patient_analytics;

CREATE TABLE patient_analytics (
    patient_id STRING,
    patient_name STRING,
    city STRING,
    total_visits INT,
    total_spent DOUBLE
)
STORED AS PARQUET;

-- 4. Execute Transformation (ELT)
INSERT OVERWRITE TABLE patient_analytics
SELECT
    p.patient_id,
    p.patient_name,
    p.city,
    COUNT(v.visit_id) AS total_visits,
    SUM(v.amount) AS total_spent
FROM patients_raw p
JOIN visits_raw v
ON p.patient_id = v.patient_id
GROUP BY
    p.patient_id,
    p.patient_name,
    p.city;
