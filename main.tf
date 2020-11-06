terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  version = "3.5.0"

  project = "entur-disaster-dev"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

# GCS Bucket for GC-Function source code

resource "google_storage_bucket" "source_code" {
  name                        = var.gcf_source_bucket
  project                     = var.gcp_project_id
  force_destroy               = true
  location                    = "EU"

  versioning {
    enabled = false
  }
}

# ZIP python source code to the bucket

data "archive_file" "code" {
  type        = "zip"
  output_path = "gcp_source_zip/source_code"

  source {
    content  = "file(/main.py)"
    filename = "main.py"
  }

  source {
    content  = "file(/requirements.txt)"
    filename = "requirements.txt"
  }
}

resource "google_storage_bucket_object" "source_code" {
  name       = var.gcp_source_zip_name
  bucket     = google_storage_bucket.source_code.name
  source     = var.gcp_source_zip_name
  depends_on = [data.archive_file.code]
}

