variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing the cat photos"
  type        = string
}

variable "s3_prefix" {
  description = "Key prefix within the S3 bucket to serve photos from"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "Image tag to deploy for both ECR repositories"
  type        = string
  default     = "latest"
}
