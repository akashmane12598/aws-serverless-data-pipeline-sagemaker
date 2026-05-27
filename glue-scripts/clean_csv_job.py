import sys
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lower, trim

args = getResolvedOptions(
    sys.argv,
    ["JOB_NAME", "S3_BUCKET", "INPUT_KEY", "OUTPUT_KEY"]
)

s3_bucket = args["S3_BUCKET"]
input_key = args["INPUT_KEY"]
output_key = args["OUTPUT_KEY"]

input_path = f"s3://{s3_bucket}/{input_key}"
output_path = f"s3://{s3_bucket}/{output_key}"

spark = SparkSession.builder.appName(args["JOB_NAME"]).getOrCreate()

df = spark.read.option("header", "true").option("inferSchema", "true").csv(input_path)

df_cleaned = (
    df.dropDuplicates()
      .dropna(subset=["sensor_id", "timestamp", "temperature", "humidity", "pressure", "status"])
      .withColumn("status", lower(trim(col("status"))))
      .filter(col("temperature").between(-50, 150))
      .filter(col("humidity").between(0, 100))
      .filter(col("pressure").between(900, 1100))
      .filter(col("status").isin("normal", "warning", "critical"))
)

df_cleaned.coalesce(1).write.mode("overwrite").option("header", "true").csv(output_path)