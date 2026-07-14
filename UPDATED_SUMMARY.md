# Module Update Summary - Organizational Tag Constraints

## What Changed

The multicloud tag module has been completely restructured to enforce strict organizational tagging standards with specific, validated tag names and values.

### Previous vs. New Tag Structure

#### Previous (Generic)
```hcl
module "tags" {
  environment    = "dev"
  application    = "myapp"
  owner          = "team-name"
  # + optional custom tags
}
```

#### New (Organizational Standards)
```hcl
module "tags" {
  # MANDATORY TAGS (8 required)
  env            = "dev"
  project        = "payments"
  business_owner = "fmoreno"
  tech_owner     = "jsmith"
  business_unit  = "aie"
  cost_center    = "1000001234"
  automation     = "tofu"
  backup         = "daily"
  
  # OPTIONAL TAGS (2 optional)
  classification = "confidential"
  schedule       = "0 4 * * *"
}
```

---

## 8 Mandatory Tags (Required)

All resources MUST include these tags:

### 1. **env** - Environment Code
- **Type:** 3-character code (lowercase)
- **Allowed Values:** `prd`, `stg`, `uat`, `qa`, `dev`, `snd`
- **Example:** `env = "prd"`
- **Validation:** Must be exact match to allowed values

### 2. **project** - Project Name
- **Type:** String (max 10 characters)
- **Format:** Any text
- **Example:** `project = "payments"`
- **Validation:** Non-empty, max 10 chars
- **Name Prefix:** First 3 chars used in 6-char prefix

### 3. **business_owner** - Business Owner
- **Type:** Username (max 128 characters)
- **Format:** Username WITHOUT domain
- **Example:** `business_owner = "fmoreno"`
- **Validation:** No @ symbol allowed
- **Invalid Examples:** `fmoreno@company.com`, `jsmith@example.com`

### 4. **tech_owner** - Technical Owner
- **Type:** Username (max 128 characters)
- **Format:** Username WITHOUT domain
- **Example:** `tech_owner = "jsmith"`
- **Validation:** No @ symbol allowed
- **Invalid Examples:** `jsmith@example.com`

### 5. **business_unit** - Business Unit Code
- **Type:** 2-3 character code (lowercase)
- **Allowed Values:**
  - `aie` - AI Engineering
  - `hr` - Human Resources
  - `it` - IT Internal
  - *More per org chart (WIP)*
- **Example:** `business_unit = "aie"`
- **Validation:** 2-3 letters, lowercase only

### 6. **cost_center** - Cost Center Code
- **Type:** Numeric (max 10 digits)
- **Format:** Digits only
- **Example:** `cost_center = "1000001234"`
- **Validation:** Non-empty, numeric only
- **Invalid Examples:** `CC-1000`, `10000000000` (>10 digits)

### 7. **automation** - IaC Tool
- **Type:** 5-character code (lowercase)
- **Allowed Values:**
  - `none` - Manual (not IaC managed)
  - `tofu` - Terraform/OpenTofu
  - `cfmt` - AWS CloudFormation
  - `pulu` - Pulumi
  - `bice` - Azure Bicep
- **Example:** `automation = "tofu"`
- **Validation:** Must be exact match

### 8. **backup** - Backup Schedule
- **Type:** Predefined values (lowercase)
- **Allowed Values:** `none`, `daily`, `weekly`, `monthly`
- **Example:** `backup = "daily"`
- **Validation:** Must be exact match
- **Constraint:** If `backup = "none"`, schedule must be empty

---

## 2 Optional Tags

Include only when needed:

### 1. **classification** - Data Classification
- **Type:** Lowercase text
- **Allowed Values:** `public`, `confidential`, `restricted`
- **Example:** `classification = "confidential"`
- **When to Use:** Resources handling sensitive data
- **Default:** Omitted if not specified

### 2. **schedule** - Backup Schedule (Crontab Format)
- **Type:** Crontab expression string
- **Format:** `minute hour day month day_of_week`
- **Example:** `schedule = "0 4 * * *"` (daily at 4 AM UTC)
- **When to Use:** Only if `backup != "none"`
- **Constraint:** Invalid if backup is "none"
- **Default:** Omitted if not specified
- **Valid Examples:**
  - `"0 4 * * *"` - Daily at 4 AM
  - `"0 4 * * SUN"` - Sunday at 4 AM
  - `"0 2 * * MON-FRI"` - Weekdays at 2 AM
  - `"0 */6 * * *"` - Every 6 hours

---

## Key Validations

| Constraint | Impact | Description |
|-----------|--------|-------------|
| **Username Format** | business_owner, tech_owner | Must NOT contain @ symbol (domain must be stripped) |
| **Numeric Cost Center** | cost_center | Digits only, max 10 characters |
| **Exact Enum Values** | env, automation, backup | Must match exactly (case-sensitive) |
| **Business Unit Length** | business_unit | 2-3 characters, lowercase only |
| **Schedule Dependency** | schedule | Only valid if `backup != "none"` |
| **Project Length** | project | Max 10 characters |

---

## 6-Character Name Prefix Generation

The module generates a name prefix from mandatory tags:

**Formula:** `{env_code:3}{project_abbr:3}`

**Examples:**
- `env = "prd"`, `project = "payments"` → `prdpay`
- `env = "dev"`, `project = "webapp"` → `devweb`
- `env = "stg"`, `project = "analytics"` → `stgana`
- `env = "uat"`, `project = "datahub"` → `uatdat`

**Usage in Resource Names:**
```hcl
resource "aws_instance" "server" {
  tags = merge(
    module.tags.tags,
    { Name = "${module.tags.name_prefix}-server-001" }
  )
  # Name tag = "prdpay-server-001"
}
```

---

## Files Updated

### Core Module Files
- ✅ **variables.tf** - Complete rewrite with new variables and strict validation
- ✅ **locals.tf** - Updated tag structure and name prefix generation
- ✅ **main.tf** - Added schedule/backup constraint validation
- ✅ **outputs.tf** - Updated output references to new tags
- ✅ **versions.tf** - No changes

### Documentation Files
- ✅ **CONSTRAINTS.md** (NEW) - Complete tag constraints documentation
- ✅ **QUICKSTART.md** - Completely revised with organizational standards
- ✅ **README.md** - (Still valid, core module reference)
- ✅ **FEATURES.md** - (Still valid, general features)
- ✅ **MODULE_SUMMARY.txt** - (Still valid, feature overview)

---

## Migration Path

If migrating from the old tag structure:

| Old Tag | New Tag | Migration Notes |
|---------|---------|-----------------|
| `environment` | `env` | Convert: prod→prd, dev→dev, stage→stg |
| `application` | `project` | Use app name, truncate to 10 chars |
| `owner` | `business_owner` + `tech_owner` | Split into two tags, remove domain |
| `created_by` | `automation` | Map to: tofu, cfmt, pulu, bice, none |
| `team` | `business_unit` | Map to 2-3 letter code |
| `backup_policy` | `backup` | Map: daily→daily, none→none |
| `cost_center` | `cost_center` | Keep numeric, validate format |
| *new* | `classification` | Add for sensitive data resources |
| *new* | `schedule` | Add backup time in crontab format |

---

## Example: Complete Migration

### Before (Old Structure)
```hcl
module "tags_legacy" {
  environment = "production"
  application = "payment-api"
  owner       = "john.smith@company.com"
  cost_center = "CC-1000"
  created_by  = "terraform"
  
  additional_tags = {
    Team = "backend"
    Backup = "daily"
  }
}
```

### After (New Structure)
```hcl
module "tags_new" {
  # Mandatory (8 required)
  env            = "prd"           # production → prd
  project        = "payment"       # payment-api → payment (truncated)
  business_owner = "jsmith"        # Strip domain
  tech_owner     = "jsmith"        # Same as business_owner
  business_unit  = "aie"           # backend team → aie code
  cost_center    = "1000"          # CC-1000 → just 1000 (digits only)
  automation     = "tofu"          # terraform → tofu
  backup         = "daily"         # From additional_tags
  
  # Optional (as needed)
  # classification = "public"  # Only if needed
  # schedule = "0 3 * * *"    # Only if backup != none
}
```

---

## Validation Examples

### ✅ VALID Configuration
```hcl
module "tags" {
  source = "./modules/cloudtags"

  env            = "prd"
  project        = "payments"
  business_owner = "fmoreno"
  tech_owner     = "jsmith"
  business_unit  = "aie"
  cost_center    = "1000001234"
  automation     = "tofu"
  backup         = "daily"
  
  classification = "confidential"
  schedule       = "0 4 * * *"
}
```

### ❌ INVALID Configuration (Multiple Errors)
```hcl
module "tags" {
  source = "./modules/cloudtags"

  env            = "production"     # ❌ Must be "prd"
  project        = "payment-system" # ❌ 15 chars > 10 max
  business_owner = "fmoreno@corp"   # ❌ Contains @
  tech_owner     = "jsmith@corp"    # ❌ Contains @
  business_unit  = "backend"        # ❌ 7 chars > 3 max
  cost_center    = "CC-1000"        # ❌ Non-numeric
  automation     = "terraform"      # ❌ Must be "tofu"
  backup         = "every-day"      # ❌ Must be "daily"
  
  schedule       = "0 4 * * *"      # ❌ Only valid if backup != "none"
}
```

---

## Benefits of New Structure

1. **Consistency** - All orgs use same tag names and formats
2. **Compliance** - Enforced data classification and backup tracking
3. **Automation** - IaC tool tracking for governance
4. **Cost Tracking** - Centralized cost center attribution
5. **Ownership** - Clear business and tech owner assignment
6. **Naming** - Automatic 6-char prefix for resource consistency
7. **Data Security** - Optional classification for sensitive data
8. **Validation** - Strict input validation prevents errors

---

## Getting Started

1. **Read CONSTRAINTS.md** - Full documentation of all tags
2. **Review QUICKSTART.md** - Quick reference with examples
3. **Check org resources:**
   - Business unit codes (from org chart)
   - Cost center codes (from Finance)
   - Classification levels (from Security)
4. **Test with terraform plan** - Validates all constraints
5. **Deploy with confidence** - All tags guaranteed consistent

---

## Support & Questions

- **Tag values:** See CONSTRAINTS.md
- **Business units:** Check org chart or ask your manager
- **Cost centers:** Contact Finance
- **Data classification:** Contact Security
- **Terraform issues:** Check error message in CONSTRAINTS.md Troubleshooting

