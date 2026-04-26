# ──────────────────────────────────────────────────────────────────────────────
# Global configuration
# ──────────────────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix applied to all created AWS resource names."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the compute environment. Leave null to use the default VPC subnets."
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "Security group IDs for Batch instances. Leave null to use the default VPC security group."
  type        = list(string)
  default     = null
}

# ──────────────────────────────────────────────────────────────────────────────
# Compute environment configuration
# ──────────────────────────────────────────────────────────────────────────────

variable "comp_env_use_spot" {
  description = "Whether to use Spot Instances for the compute environment."
  type        = bool
  default     = true
}

variable "comp_env_max_concurrent_jobs" {
  description = "Maximum number of concurrent jobs allowed in the job queue. Will determine the max vcpu limit."
  type        = number
  default     = 4
}

variable "comp_env_instance_types" {
  description = "EC2 instance types to use."
  type        = list(string)
  default     = ["g4dn.xlarge", "g5.xlarge", "g6.xlarge"]
}


# ──────────────────────────────────────────────────────────────────────────────
# Job configuration
# ──────────────────────────────────────────────────────────────────────────────

variable "job_image_uri" {
  description = "Container image URI for the job definition."
  type        = string
  default     = "lucactt/aws-batch-tf:latest" # For DockerHub this can be just the image name. For ECR, it should be the full URI.
}

variable "job_gpus" {
  description = "GPUs allocated per job. The chosen instance types must support this GPU count."
  type        = number
  default     = 0
}

variable "job_vcpus" {
  description = "vCPUs allocated per job."
  type        = number
  default     = 4
}

variable "memory_mib" {
  description = "Memory in MiB allocated per job."
  type        = number
  default     = 2048
}

variable "job_shared_memory_size_mib" {
  description = "Size of /dev/shm in MiB for the job container."
  type        = number
  default     = 1024
}

variable "job_max_swap_mib" {
  description = "Maximum swap space in MiB for the job container."
  type        = number
  default     = 0
}

variable "job_swappiness" {
  description = "Swappiness parameter (0-100) for the job container."
  type        = number
  default     = 0
}

variable "job_attempt_duration_seconds" {
  description = "Timeout in seconds for each job attempt."
  type        = number
  default     = 3600
}

variable "job_retry_attempts" {
  description = "Number of retry attempts for failed jobs."
  type        = number
  default     = 1
}


# ──────────────────────────────────────────────────────────────────────────────
# SQS queue configuration
# ──────────────────────────────────────────────────────────────────────────────

variable "sqs_visibility_timeout_seconds" {
  description = "Seconds a message is hidden from other consumers after being received. Should be >= job_attempt_duration_seconds to avoid double-processing."
  type        = number
  default     = 3600
}

variable "sqs_message_retention_seconds" {
  description = "Seconds SQS retains a message before deleting it. Default: 1 day."
  type        = number
  default     = 86400
}