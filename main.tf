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

#topic
resource "google_pubsub_topic" "remote-backup-topic" {
  name    = "remote-backuppp"
  project = var.gcp_project_id
  message_storage_policy {
    allowed_persistence_regions = [var.region] # To store messages in different zone than source bucket, specify a different region than source region.
  }
}

resource "google_pubsub_subscription" "remote-backup-subscription" {
  name   = "remote-backuppp"
  topic  = google_pubsub_topic.remote-backup-topic.name
  message_retention_duration = "172800s" # 48hours
  retain_acked_messages      = false

  # Expire subscription in 3 months if inactive
  expiration_policy {
    ttl = "7776000s"
  }
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
#sd

#sdasdsa

# Zip the coud function source code
data "archive_file" "code" {
  type        = "zip"
  output_path = "${path.cwd}/${var.gcp_source_zip_name}"

  source {
    content  = file("${path.cwd}/main.py")
    filename = "main.py"
  }

  source {
    content  = file("${path.cwd}/requirements.txt")
    filename = "requirements.txt"
  }
}

resource "google_storage_bucket_object" "source_code" {
  name       = var.gcp_source_zip_name
  bucket     = google_storage_bucket.source_code.name
  source     = "${path.cwd}/${var.gcp_source_zip_name}"
  depends_on = [data.archive_file.code]
}

# Bucket 1 which files are created or changed triggers the cloud function
resource "google_storage_bucket" "live-prod1" {
  name                        = "trigger1-1"
  project                     = var.gcp_project_id
  force_destroy               = true

  versioning {
    enabled = false
  }
}

# Bucket 2 which files are created or changed triggers the cloud function
resource "google_storage_bucket" "live-prod2" {
  name                        = "trigger2-2"
  project                     = var.gcp_project_id
  force_destroy               = true

  versioning {
    enabled = false
  }
}

resource "google_cloudfunctions_function" "source_function" {

  name        = "source-publish-function-two-triggers"
  description = "sends a publish message when buckets are changed"
  region      = "europe-west1"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source_code.name
  source_archive_object = google_storage_bucket_object.source_code.name
  timeout               = 60
  entry_point           = "publish_message"

  environment_variables = {
    topic = "projects/${var.gcp_project_id}/topics/remote-backuppp"
  }

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.live-prod1.name
  }

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.live-prod2.name
  }
}
