output "tags" {
  description = "A map of tags to apply to resources. Standard format suitable for most resources."
  value       = local.final_tags
}

output "tags_list" {
  description = "Tags formatted as a list of maps with key and value properties. Useful for AWS Auto Scaling Groups and similar constructs."
  value = [
    for key, value in local.final_tags : {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  ]
}

output "name_prefix" {
  description = "A 6-character prefix for resource naming derived from env code (3 chars) and app_short code (3 chars). Format: {env_code:3}{app_short:3}"
  value       = local.name_prefix_generated
}

output "env" {
  description = "The environment code from inputs"
  value       = var.env
}

output "app_short" {
  description = "The application short code (3 letters) used in name prefix generation"
  value       = var.app-short
}

output "app_name" {
  description = "The application complete name from inputs"
  value       = var.app-name
}

output "project" {
  description = "The project name from inputs"
  value       = var.project
}

output "core_tags" {
  description = "Core tags that are always included"
  value       = local.core_tags
}

output "tags_by_category" {
  description = "Tags organized by category for reference"
  value = {
    identity = {
      env              = var.env
      project          = var.project
      "business-owner" = var.business-owner
      "tech-owner"     = var.tech-owner
    }
    organization = {
      "business-unit" = var.business-unit
    }
    billing = {
      "cost-center" = var.cost-center
    }
    infrastructure = {
      automation = var.automation
      backup     = var.backup
    }
    optional = {
      compliance = var.compliance != "" ? var.compliance : null
      schedule       = var.schedule != "" ? var.schedule : null
    }
  }
}

output "aws_tags" {
  description = "Tags formatted specifically for AWS resources (standard map format)"
  value       = local.final_tags
}

output "azure_tags" {
  description = "Tags formatted specifically for Azure resources (standard map format)"
  value       = local.final_tags
}

output "gcp_labels" {
  description = "Labels formatted specifically for GCP resources. GCP has stricter naming rules, so keys are lowercase and hyphens replace spaces."
  value = {
    for key, value in local.final_tags : (
      lower(replace(key, " ", "-"))
    ) => lower(replace(value, " ", "-"))
  }
}

output "tag_count" {
  description = "Total number of tags that will be applied"
  value       = length(local.final_tags)
}

output "tag_keys" {
  description = "List of all tag keys"
  value       = sort(keys(local.final_tags))
}
