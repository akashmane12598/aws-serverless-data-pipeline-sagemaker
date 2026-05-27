import sys
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession

args = getResolvedOptions(
    sys.argv,
    ["JOB_NAME", "S3_BUCKET", "INPUT_PREFIX", "OUTPUT_PREFIX"]
)

s3_bucket = args["S3_BUCKET"]
input_prefix = args["INPUT_PREFIX"]
output_prefix = args["OUTPUT_PREFIX"]

input_path = f"s3://{s3_bucket}/{input_prefix}"
output_path = f"s3://{s3_bucket}/{output_prefix}"

spark = SparkSession.builder.appName(args["JOB_NAME"]).getOrCreate()

df = spark.read.option("header", "true").option("inferSchema", "true").csv(input_path)

df.write.mode("overwrite").parquet(output_path)