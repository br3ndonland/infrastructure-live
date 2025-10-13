variable "s3_backend_bucket" {
  description = "Name of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "spacelift_organization" {
  description = "Name of Spacelift organization in which to provision resources"
  type        = string
}
