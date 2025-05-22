output "mission_profile_arn" {
  description = "ARN of the created mission profile"
  value       = aws_groundstation_mission_profile.jpss2.arn
}

output "dataflow_endpoint_group_arn" {
  description = "ARN of the created dataflow endpoint group"
  value       = aws_groundstation_dataflow_endpoint_group.jpss2.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for satellite data"
  value       = aws_s3_bucket.satellite_data.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for satellite data"
  value       = aws_s3_bucket.satellite_data.arn
}
