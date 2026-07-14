# Quick Start Guide - Mandatory vs. Optional Inputs

## Input Variables Summary

### 8 REQUIRED Inputs (No Defaults)
Every module call MUST include these 8 inputs:

| Input | Type | Max Length | Allowed Values | Example |
|-------|------|-----------|-----------------|---------|
| `env` | Code | 3 chars | prd, stg, uat, qa, dev, snd | `prd` |
| `app_short` | Code | 3 chars | Lowercase letters | `pay` |
| `app_name` | Name | 10 chars | Any text | `payments` |
| `project` | Name | 10 chars | Any text | `payments` |
| `business_owner` | Username | 128 chars | No @ symbol | `fmoreno` |
| `tech_owner` | Username | 128 chars | No @ symbol | `jsmith` |
| `business_unit` | Code | 3 chars | aie, hr, it, ... | `aie` |
| `cost_center` | Numeric | 10 digits | Numbers only | `1000001234` |

### 4 OPTIONAL Inputs (With Defaults)
These inputs have default values and are NOT required:

| Input | Default | Allowed Values | When to Override |
|-------|---------|-----------------|-----------------|
| `automation` | `"none"` | none, tofu, cfmt, pulu, bice | When using IaC tools |
| `backup` | `"none"` | none, daily, weekly, monthly | When backups are needed |
| `classification` | `""` (empty) | public, confidential, restricted | For sensitive data |
| `schedule` | `""` (empty) | Crontab format | When backup ≠ "none" |

## Minimal Configuration (8 Required Only)

```hcl
module "tags_minimal" {
  source = "git::https://github.com/fmorenoSolvd/cloudtags.git"

  # 8 REQUIRED INPUTS
  env            = "prd"
  app_short      = "pay"
  app_name       = "payments"
  project        = "payments"
  business_owner = "fmoreno"
  tech_owner     = "jsmith"
  business_unit  = "aie"
  cost_center    = "1000001234"

  # OPTIONAL inputs omitted - use defaults
}

# name_prefix = "prdpay" (env + app_short)
# automation = "none" (default)
# backup = "none" (default)
```

## Complete Configuration (8 Required + 4 Optional)

```hcl
module "tags_complete" {
  source = "git::https://github.com/fmorenoSolvd/cloudtags.git"

  # 8 REQUIRED INPUTS
  env            = "prd"
  app_short      = "pay"
  app_name       = "payments"
  project        = "payments"
  business_owner = "fmoreno"
  tech_owner     = "jsmith"
  business_unit  = "aie"
  cost_center    = "1000001234"

  # 4 OPTIONAL INPUTS (override defaults)
  automation     = "tofu"
  backup         = "daily"
  classification = "restricted"
  schedule       = "0 3 * * *"
}

# name_prefix = "prdpay"
# automation = "tofu" (overridden)
# backup = "daily" (overridden)
# classification = "restricted" (added)
# schedule = "0 3 * * *" (added)
```

## Output Tags Generated

From the 8 required + 4 optional inputs, the module generates:

```hcl
# All tags map
tags = {
  env             = "prd"
  app_short       = "pay"
  app_name        = "payments"
  project         = "payments"
  business_owner  = "fmoreno"
  tech_owner      = "jsmith"
  business_unit   = "aie"
  cost_center     = "1000001234"
  automation      = "tofu"
  backup          = "daily"
  classification  = "restricted"
  schedule        = "0 3 * * *"
}

# 6-character name prefix (output only)
name_prefix = "prdpay"  # env (3) + app_short (3)

# Reference outputs
app_short = "pay"
app_name = "payments"
env = "prd"
project = "payments"
```

## Mandatory Input Details

### 1. env (Environment Code)
**Required.** Exactly 3 characters, lowercase.

```hcl
env = "prd"  # ✓ Production
env = "dev"  # ✓ Development
env = "stg"  # ✓ Staging
env = "uat"  # ✓ User Acceptance Test
env = "qa"   # ✓ Quality Assurance
env = "snd"  # ✓ Sandbox
```

### 2. app_short (Application Short Code)
**Required.** Exactly 3 lowercase letters. Used in name prefix.

```hcl
app_short = "pay"  # ✓ Payments
app_short = "api"  # ✓ API
app_short = "web"  # ✓ Web
app_short = "dat"  # ✓ Data
app_short = "els"  # ✓ Elasticsearch
app_short = "aut"  # ✓ Authentication
```

### 3. app_name (Application Complete Name)
**Required.** Max 10 characters. Complete application name.

```hcl
app_name = "payments"      # ✓ Full name
app_name = "api-service"   # ✓ With hyphen
app_name = "webapp-v2"     # ✓ With version
app_name = "data-pipe"     # ✓ Abbreviated
app_name = "elastic-srch"  # ✓ Truncated
```

### 4. project (Project Name)
**Required.** Max 10 characters. Project identifier.

```hcl
project = "payments"       # ✓ Project name
project = "analytics"      # ✓ Department name
project = "core-platform"  # ✗ Too long (12 chars)
```

### 5. business_owner (Business Owner)
**Required.** Username without domain. Max 128 characters.

```hcl
business_owner = "fmoreno"      # ✓ Correct
business_owner = "j.smith"      # ✓ With dot
business_owner = "m_garcia"     # ✓ With underscore

business_owner = "fmoreno@corp"     # ✗ Contains @
business_owner = "fmoreno@company.com"  # ✗ Domain not allowed
```

### 6. tech_owner (Technical Owner)
**Required.** Username without domain. Max 128 characters.

```hcl
tech_owner = "jsmith"           # ✓ Correct
tech_owner = "engineering-lead" # ✓ With hyphen
tech_owner = "jane.doe"         # ✓ With dot

tech_owner = "jsmith@corp"      # ✗ Contains @
```

### 7. business_unit (Business Unit Code)
**Required.** 2-3 lowercase letters.

```hcl
business_unit = "aie"   # ✓ AI Engineering
business_unit = "hr"    # ✓ Human Resources
business_unit = "it"    # ✓ IT Internal
business_unit = "ops"   # ✓ Operations

business_unit = "finance"  # ✗ 7 letters
business_unit = "AIE"      # ✗ Not lowercase
business_unit = "a"        # ✗ Only 1 letter
```

### 8. cost_center (Cost Center Code)
**Required.** Max 10 digits. Numeric only.

```hcl
cost_center = "1000001234"  # ✓ 10 digits
cost_center = "9999"        # ✓ Any length up to 10
cost_center = "0"           # ✓ Single digit

cost_center = "CC-1000"         # ✗ Contains letters
cost_center = "10000000000"     # ✗ 11 digits (too long)
cost_center = ""                # ✗ Empty/blank
```

## Optional Input Details

### automation (Default: "none")
Omit or use default if resource is manually created or not IaC-managed.

```hcl
# Omit entirely for default
module "tags" {
  # ... 8 required inputs ...
  # automation defaults to "none"
}

# Or override with specific tool
module "tags" {
  # ... 8 required inputs ...
  automation = "tofu"      # Terraform/OpenTofu
  automation = "cfmt"      # AWS CloudFormation
  automation = "pulu"      # Pulumi
  automation = "bice"      # Azure Bicep
}
```

### backup (Default: "none")
Omit or use default if no automated backups needed.

```hcl
# Omit entirely for default
module "tags" {
  # ... 8 required inputs ...
  # backup defaults to "none"
}

# Or override for backup schedules
module "tags" {
  # ... 8 required inputs ...
  backup = "daily"    # Daily backups
  backup = "weekly"   # Weekly backups
  backup = "monthly"  # Monthly backups
  
  # If backup != "none", can add optional schedule
  schedule = "0 3 * * *"  # Backup at 3 AM UTC
}
```

### classification (Default: Empty String)
Omit if no sensitive data. Include for sensitive resources.

```hcl
# Omit entirely for empty/not included
module "tags" {
  # ... 8 required inputs ...
  # classification defaults to empty string
}

# Or override for data classification
module "tags" {
  # ... 8 required inputs ...
  classification = "public"        # Public data
  classification = "confidential"  # Internal data
  classification = "restricted"    # Restricted/proprietary
}
```

### schedule (Default: Empty String)
Only valid if backup ≠ "none". Omit for no schedule.

```hcl
# Valid: backup = "daily" with schedule
module "tags" {
  # ... 8 required inputs ...
  backup   = "daily"
  schedule = "0 3 * * *"  # Daily at 3 AM UTC
}

# Valid: backup = "none" without schedule
module "tags" {
  # ... 8 required inputs ...
  backup = "none"
  # schedule omitted
}

# INVALID: backup = "none" with schedule
module "tags" {
  # ... 8 required inputs ...
  backup   = "none"
  schedule = "0 3 * * *"  # ✗ FAILS VALIDATION
}
```

## Real-World Examples

### Minimal Setup (Dev Environment)
```hcl
module "tags_dev" {
  source = "git::https://github.com/fmorenoSolvd/cloudtags.git"

  # 8 REQUIRED
  env            = "dev"
  app_short      = "api"
  app_name       = "api-service"
  project        = "backend"
  business_owner = "mgarcia"
  tech_owner     = "agarcia"
  business_unit  = "aie"
  cost_center    = "2000000001"

  # Defaults used: automation="none", backup="none"
}

# Outputs: name_prefix="devapi"
```

### Complete Setup (Prod Environment)
```hcl
module "tags_prod" {
  source = "git::https://github.com/fmorenoSolvd/cloudtags.git"

  # 8 REQUIRED
  env            = "prd"
  app_short      = "pay"
  app_name       = "payments"
  project        = "payments"
  business_owner = "fmoreno"
  tech_owner     = "jsmith"
  business_unit  = "aie"
  cost_center    = "1000001234"

  # 4 OPTIONAL (overridden)
  automation     = "tofu"
  backup         = "daily"
  classification = "restricted"
  schedule       = "0 3 * * *"
}

# Outputs:
# name_prefix = "prdpay"
# All 12 tags included in module.tags_prod.tags
```

## Validation Summary

| Input | Required | Validation |
|-------|----------|-----------|
| env | ✓ Yes | One of: prd, stg, uat, qa, dev, snd |
| app_short | ✓ Yes | Exactly 3 lowercase letters |
| app_name | ✓ Yes | Max 10 characters, non-empty |
| project | ✓ Yes | Max 10 characters, non-empty |
| business_owner | ✓ Yes | No @ symbol, max 128 chars |
| tech_owner | ✓ Yes | No @ symbol, max 128 chars |
| business_unit | ✓ Yes | 2-3 lowercase letters |
| cost_center | ✓ Yes | Numeric only, 10 digits max |
| automation | ✗ No | One of: none, tofu, cfmt, pulu, bice (default: none) |
| backup | ✗ No | One of: none, daily, weekly, monthly (default: none) |
| classification | ✗ No | One of: public, confidential, restricted (default: empty) |
| schedule | ✗ No | Valid crontab format (default: empty) |

## Getting Started Checklist

- [ ] Have 8 required input values ready
- [ ] Decide on automation tool (tofu, cfmt, pulu, bice, or none)
- [ ] Decide on backup strategy (daily, weekly, monthly, or none)
- [ ] If backup ≠ none, determine backup schedule (crontab format)
- [ ] If sensitive data, set classification (public, confidential, restricted)
- [ ] Run terraform plan to validate
- [ ] Deploy with confidence!

