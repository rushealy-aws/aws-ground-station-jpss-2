variable "aws_region" {
  description = "AWS region for Ground Station resources"
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store satellite data"
  type        = string
  default     = "jpss2-satellite-data"
}

variable "dataflow_endpoint_group_name" {
  description = "Name of the dataflow endpoint group"
  type        = string
  default     = "jpss2-dataflow-endpoint-group"
}

variable "mission_profile_name" {
  description = "Name of the mission profile"
  type        = string
  default     = "jpss2-mission-profile"
}

variable "contact_profile_name" {
  description = "Name of the contact profile"
  type        = string
  default     = "jpss2-contact-profile"
}

variable "tracking_config_name" {
  description = "Name of the tracking configuration"
  type        = string
  default     = "jpss2-tracking-config"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "JPSS-2"
    Environment = "Production"
    Managed_By  = "Terraform"
  }
}
