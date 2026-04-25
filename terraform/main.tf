provider "aws" {
  region = var.region
}

locals {
  compute_type        = var.comp_env_use_spot ? "SPOT" : "EC2"
  allocation_strategy = var.comp_env_use_spot ? "SPOT_PRICE_CAPACITY_OPTIMIZED" : null
  bid_percentage      = var.comp_env_use_spot ? 100 : null
  max_vcpus           = var.job_vcpus * var.comp_env_max_concurrent_jobs
}

module "batch" {
  source  = "terraform-aws-modules/batch/aws"
  version = "~> 3"

  instance_iam_role_name = "${var.name_prefix}-ecs-instance"
  instance_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  service_iam_role_name  = "${var.name_prefix}-batch-service"
  create_spot_fleet_iam_role      = var.comp_env_use_spot
  spot_fleet_iam_role_name        = "${var.name_prefix}-spot"


  compute_environments = {
    ec2 = {
      name_prefix = var.name_prefix

      compute_resources = {
        type                = local.compute_type
        min_vcpus           = 0
        max_vcpus           = local.max_vcpus
        desired_vcpus       = 0
        instance_types      = var.comp_env_instance_types
        allocation_strategy = local.allocation_strategy
        bid_percentage      = local.bid_percentage

        security_group_ids = local.effective_security_group_ids
        subnets            = local.effective_subnet_ids
      }
    }
  }

  job_queues = {
    ec2_queue = {
      name     = "${var.name_prefix}-queue"
      priority = 1

      compute_environment_order = {
        0 = {
          compute_environment_key = "ec2"
        }
      }
    }
  }

  job_definitions = {
    job = {
      name           = "${var.name_prefix}-job"
      propagate_tags = true

      platform_capabilities = ["EC2"]

      container_properties = jsonencode({
        image            = var.job_image_uri
        executionRoleArn = local.effective_execution_role_arn

        resourceRequirements = [
          { type = "VCPU", value = tostring(var.job_vcpus) },
          { type = "MEMORY", value = tostring(var.memory_mib) },
          { type = "GPU", value = tostring(var.job_gpus) }
        ]

        linuxParameters = {
          sharedMemorySize = var.job_shared_memory_size_mib
          maxSwap          = var.job_max_swap_mib
          swappiness       = var.job_swappiness
        }
      })

      attempt_duration_seconds = var.job_attempt_duration_seconds
      retry_strategy = {
        attempts = var.job_retry_attempts
        evaluate_on_exit = {
          retry_error = {
            action       = "RETRY"
            on_exit_code = 1
          }
          exit_success = {
            action       = "EXIT"
            on_exit_code = 0
          }
        }
      }
    }
  }
}
