locals {
  # Generate a 6-character name prefix from env and app_short
  # Format: {env_code:3}{app_short:3} - exactly 6 characters
  env_code              = lower(var.env)
  app_short_code        = lower(var.app_short)
  name_prefix_generated = "${local.env_code}${local.app_short_code}"

  # Mandatory core tags (always included)
  core_tags = {
    env            = var.env
    project        = var.project
    business_owner = var.business_owner
    tech_owner     = var.tech_owner
    business_unit  = var.business_unit
    cost_center    = var.cost_center
    automation     = var.automation
    backup         = var.backup
  }

  # Optional tags - only included if provided
  optional_tags = merge(
    var.classification != "" ? { classification = var.classification } : {},
    var.schedule != "" ? { schedule = var.schedule } : {}
  )

  # Merge all tags in order: core, optional, additional (additional has highest priority)
  all_tags = merge(
    local.core_tags,
    local.optional_tags,
    var.additional_tags
  )

  # Final tags (no name prefix applied to keys - prefix is only for resource naming)
  final_tags = local.all_tags

  # Validation: schedule is only valid if backup != "none"
  schedule_requires_backup = var.schedule != "" && var.backup == "none"

  # All validation errors
  validation_errors = concat(
    local.schedule_requires_backup ? ["schedule cannot be set if backup is 'none'"] : []
  )
}
