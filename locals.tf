locals {
  # Generate a 6-character name prefix from env and app-short
  # Format: {env_code:3}{app-short:3} - exactly 6 characters
  env_code              = lower(var.env)
  app_short_code        = lower(var.app-short)
  name_prefix_generated = "${local.env_code}${local.app_short_code}"

  # Mandatory core tags (always included)
  core_tags2 = {
    env              = var.env
    project          = var.project
    "app-name"       = var.app-name
    "business-owner" = var.business-owner
    "tech-owner"     = var.tech-owner
    "business-unit"  = var.business-unit
    "cost-center"    = var.cost-center

    automation = var.automation
  }

  # backup and schedule are added only when backup != "none" and schedule is set
  backup_tags = local.backup_enabled && local.schedule_set ? { backup = var.backup, schedule = var.schedule } : {}

  core_tags1 = merge(local.core_tags2, local.backup_tags)
  core_tags  = var.compliance != "none" ? merge(local.core_tags1, { compliance = var.compliance }) : local.core_tags1

  # Merge all tags in order: core, optional, additional (additional has highest priority)
  all_tags = merge(
    local.core_tags,
    var.additional-tags
  )

  # Final tags (no name prefix applied to keys - prefix is only for resource naming)
  final_tags = local.all_tags

  backup_enabled = var.backup != "none"
  schedule_set   = var.schedule != ""

  # Validation: schedule is only valid if backup != "none"
  schedule_requires_backup = local.schedule_set && !local.backup_enabled

  # Validation: schedule is required if backup != "none"
  backup_requires_schedule = local.backup_enabled && !local.schedule_set

  # All validation errors
  validation_errors = concat(
    local.schedule_requires_backup ? ["schedule cannot be set if backup is 'none'"] : [],
    local.backup_requires_schedule ? ["schedule is required if backup is not 'none'"] : []
  )
}
