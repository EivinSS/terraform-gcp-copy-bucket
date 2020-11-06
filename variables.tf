variable gcp_project_id {
  type        = string
  description = "GCP Project ID"
  default     = "entur-disaster-dev"
}

variable gcf_source_bucket {
  type        = string
  description = "Source bucket name"
  default     = "gcf_cource_code"
}

variable gcp_source_zip_name {
    type      = string
    description = "zipfile-name"
    default   = "gcp_source_zip"
}

variable path {
    default   = "/mnt/c/Users/E180047/Documents/GitHub/terraform-gcp-copy-bucket"
}