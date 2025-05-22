provider "aws" {
  region = var.aws_region
}

# S3 bucket for satellite data
resource "aws_s3_bucket" "satellite_data" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "satellite_data" {
  bucket = aws_s3_bucket.satellite_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "satellite_data" {
  bucket = aws_s3_bucket.satellite_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "satellite_data" {
  bucket = aws_s3_bucket.satellite_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for Ground Station
resource "aws_iam_role" "ground_station" {
  name = "ground-station-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "groundstation.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  path                = "/service-role/"

  tags = var.tags
}

# Ground Station Dataflow Endpoint Group
resource "aws_groundstation_dataflow_endpoint_group" "jpss2" {
  name = var.dataflow_endpoint_group_name

  endpoint_details {
    security_details {
      role_arn = aws_iam_role.ground_station.arn
    }

    endpoint {
      name    = "S3-Downlink"
      address = aws_s3_bucket.satellite_data.bucket_domain_name
      port    = 443
      mtu     = 1500
    }
  }

  tags = var.tags
}

# Ground Station Tracking Configuration
resource "aws_groundstation_config" "tracking" {
  name = var.tracking_config_name

  tracking_config {
    autotrack = "PREFERRED"
  }

  tags = var.tags
}

# Antenna Downlink Configuration
resource "aws_groundstation_config" "antenna_downlink" {
  name = "jpss2-antenna-downlink-config"

  antenna_downlink_config {
    spectrum_config {
      bandwidth {
        units = "MHz"
        value = 40
      }
      center_frequency {
        units = "MHz"
        value = 7812.0
      }
      polarization = "RIGHT_HAND"
    }
  }

  tags = var.tags
}

# S3 Recording Configuration
resource "aws_groundstation_config" "s3_recording" {
  name = "jpss2-s3-recording-config"

  s3_recording_config {
    bucket_arn = aws_s3_bucket.satellite_data.arn
    role_arn   = aws_iam_role.ground_station.arn
    prefix     = "jpss2-data/"
  }

  tags = var.tags
}

# Contact Profile
resource "aws_groundstation_mission_profile" "contact" {
  name = var.contact_profile_name

  contact_post_pass_duration_seconds  = 120
  contact_pre_pass_duration_seconds   = 120
  minimum_viable_contact_duration_seconds = 180

  tracking_config_arn = aws_groundstation_config.tracking.arn

  dataflow_edges {
    source      = aws_groundstation_config.antenna_downlink.arn
    destination = aws_groundstation_config.s3_recording.arn
  }

  tags = var.tags

  depends_on = [
    aws_groundstation_config.tracking,
    aws_groundstation_config.antenna_downlink,
    aws_groundstation_config.s3_recording
  ]
}

# Mission Profile
resource "aws_groundstation_mission_profile" "jpss2" {
  name = var.mission_profile_name

  contact_post_pass_duration_seconds  = 120
  contact_pre_pass_duration_seconds   = 120
  minimum_viable_contact_duration_seconds = 180

  tracking_config_arn = aws_groundstation_config.tracking.arn

  dataflow_edges {
    source      = aws_groundstation_config.antenna_downlink.arn
    destination = aws_groundstation_config.s3_recording.arn
  }

  tags = var.tags

  depends_on = [
    aws_groundstation_mission_profile.contact,
    aws_groundstation_config.tracking,
    aws_groundstation_config.antenna_downlink,
    aws_groundstation_config.s3_recording
  ]
}
