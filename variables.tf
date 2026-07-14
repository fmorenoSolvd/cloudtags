variable "env" {
  description = "Environment code (three lowercase letters max). Allowed values: prd (productive), stg (stage), uat (user-acceptance test), qa (quality assurance), dev (development), snd (sandbox)"
  type        = string

  validation {
    condition     = can(regex("^(prd|stg|uat|qa|dev|snd)$", lower(var.env)))
    error_message = "Environment must be one of: prd, stg, uat, qa, dev, or snd."
  }
}

variable "project" {
  description = "Project name (ten letters max)"
  type        = string

  validation {
    condition     = length(trimspace(var.project)) > 0 && length(var.project) <= 10
    error_message = "Project must be a non-empty string of 10 characters or fewer."
  }
}

variable "app_short" {
  description = "Application short code (exactly 3 lowercase letters). Used in name prefix generation"
  type        = string

  validation {
    condition     = length(trimspace(var.app_short)) == 3 && can(regex("^[a-z]{3}$", lower(var.app_short)))
    error_message = "Application short name must be exactly 3 lowercase letters (e.g., 'pay' for payments, 'api' for api-gateway)."
  }
}

variable "app_name" {
  description = "Application complete name (max 10 characters)"
  type        = string

  validation {
    condition     = length(trimspace(var.app_name)) > 0 && length(var.app_name) <= 10
    error_message = "Application name must be a non-empty string of 10 characters or fewer (e.g., 'payments', 'api-gateway')."
  }
}

variable "business_owner" {
  description = "Business owner username (without domain, e.g., fmoreno)"
  type        = string

  validation {
    condition     = length(trimspace(var.business_owner)) > 0 && length(var.business_owner) <= 128 && !can(regex("@", var.business_owner))
    error_message = "Business owner must be a non-empty username without domain (max 128 chars), e.g., 'fmoreno' not 'fmoreno@example.com'."
  }
}

variable "tech_owner" {
  description = "Technical owner username (without domain, e.g., fmoreno)"
  type        = string

  validation {
    condition     = length(trimspace(var.tech_owner)) > 0 && length(var.tech_owner) <= 128 && !can(regex("@", var.tech_owner))
    error_message = "Tech owner must be a non-empty username without domain (max 128 chars), e.g., 'fmoreno' not 'fmoreno@example.com'."
  }
}

variable "business_unit" {
  description = "Business unit (three lowercase letters max). Allowed values: aie (AI Engineering), hr (Human Resources), it (IT Internal), etc."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,3}$", lower(var.business_unit)))
    error_message = "Business unit must be 2-3 lowercase letters, e.g., 'aie', 'hr', 'it'."
  }
}

variable "cost_center" {
  description = "Cost center code (10 digits max)"
  type        = string

  validation {
    condition     = length(trimspace(var.cost_center)) > 0 && length(var.cost_center) <= 10 && can(regex("^[0-9]+$", var.cost_center))
    error_message = "Cost center must be numeric, non-empty, and 10 digits or fewer."
  }
}

variable "automation" {
  description = "IaC Tool used (five lowercase letters max). Allowed values: none, tofu (Terraform/OpenTofu), cfmt (AWS CloudFormation), pulu (Pulumi), bice (Azure Bicep)"
  type        = string
  default     = "none"

  validation {
    condition     = can(regex("^(none|tofu|cfmt|pulu|bice)$", lower(var.automation)))
    error_message = "Automation must be one of: none, tofu, cfmt, pulu, or bice."
  }
}

variable "backup" {
  description = "Backup schedule. Allowed values: none, daily, weekly, monthly"
  type        = string
  default     = "none"

  validation {
    condition     = can(regex("^(none|daily|weekly|monthly)$", lower(var.backup)))
    error_message = "Backup must be one of: none, daily, weekly, or monthly."
  }
}

variable "classification" {
  description = "Sensitive Data Classification (optional). Allowed values: public, confidential, restricted, or empty"
  type        = string
  default     = ""

  validation {
    condition     = var.classification == "" || can(regex("^(public|confidential|restricted)$", lower(var.classification)))
    error_message = "Classification must be empty string or one of: public, confidential, restricted."
  }
}

variable "schedule" {
  description = "Backup schedule in crontab format (e.g., '0 4 * * SUN' for Sunday at 4 AM UTC). Only valid if backup is not 'none'"
  type        = string
  default     = ""

  validation {
    condition     = length(var.schedule) == 0 || can(regex("^([0-9*,/-]+\\s+){4}[0-9*,/-A-Za-z]+$", var.schedule))
    error_message = "Schedule must be empty or in valid crontab format (e.g., '0 4 * * SUN')."
  }
}

variable "additional_tags" {
  description = "Additional optional tags as key-value pairs"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.additional_tags : (
        length(trimspace(k)) > 0 && length(k) <= 256 &&
        length(trimspace(v)) > 0 && length(v) <= 1024
      )
    ])
    error_message = "All additional tags must have non-empty keys (max 256 chars) and values (max 1024 chars)."
  }
}

