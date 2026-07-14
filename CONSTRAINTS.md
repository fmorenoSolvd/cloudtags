# Tag Constraints & Organizational Standards

## At a Glance

- **8 REQUIRED Inputs:** env, app_short, app_name, project, business_owner, tech_owner, business_unit, cost_center
- **4 OPTIONAL Inputs:** automation (default: "none"), backup (default: "none"), classification (default: empty), schedule (default: empty)
- **Generated Outputs:** 12 tags + name_prefix (6 characters)

---

## Mandatory Inputs (REQUIRED - No Defaults)

All 8 of these inputs MUST be provided in every module call:


### 1. env (Environment Code) - REQUIRED
**Description:** Three-letter environment code  
**Type:** String  
**Max Length:** 3 characters  
**Format:** Lowercase letters only  
**Allowed Values:**
- `prd` - Production
- `stg` - Stage/Staging
- `uat` - User Acceptance Test
- `qa` - Quality Assurance
- `dev` - Development
- `snd` - Sandbox

**Example:** `env = "prd"`

---

### 2. app_short (Application Short Code) - REQUIRED
**Description:** Application short code (3 letters, lowercase)  
**Type:** String  
**Max Length:** Exactly 3 characters  
**Format:** Lowercase letters only  

Used in the 6-character name prefix generation.

**Example:** `app_short = "pay"`

**Validation Examples:**
- ✓ `app_short = "pay"` - Correct (3 lowercase letters)
- ✗ `app_short = "payments"` - Invalid (too long)
- ✗ `app_short = "pa"` - Invalid (too short)
- ✗ `app_short = "PAY"` - Invalid (not lowercase)

**Common App Codes:**
- `pay` - Payments
- `api` - API service
- `web` - Web application
- `dat` - Data pipeline
- `els` - Elasticsearch
- `wal` - Wallet
- `aut` - Authentication

---

### 3. app_name (Application Complete Name) - REQUIRED
**Description:** Application complete name or identifier  
**Type:** String  
**Max Length:** 10 characters  
**Format:** Any characters  

**Example:** `app_name = "payments"`

**Validation Examples:**
- ✓ `app_name = "payments"` - Correct
- ✓ `app_name = "api-service"` - Correct (with hyphen)
- ✗ `app_name = "payment-processing-system"` - Invalid (>10 chars)

**Name Prefix Generation:** The module generates a 6-character name prefix combining:
- All 3 characters of `env` code (e.g., `prd`)
- All 3 characters of `app_short` code (e.g., `pay`)
- Result: `prdpay`

---

### 4. project (Project Name) - REQUIRED
**Description:** Project name or identifier  
**Type:** String  
**Max Length:** 10 characters  
**Format:** Any characters  

**Example:** `project = "payments"`

---

### 5. business_owner (Business Owner) - REQUIRED
**Description:** Business owner responsible for the resource  
**Type:** String  
**Max Length:** 128 characters  
**Format:** Username without domain  
**Requirement:** No `@` symbol (domain must be stripped)

**Example:** `business_owner = "fmoreno"`

**Validation Examples:**
- ✓ `business_owner = "fmoreno"` - Correct
- ✗ `business_owner = "fmoreno@company.com"` - Invalid (Contains @)

---

### 6. tech_owner (Technical Owner) - REQUIRED
**Description:** Technical owner/engineer responsible for the resource  
**Type:** String  
**Max Length:** 128 characters  
**Format:** Username without domain  
**Requirement:** No `@` symbol (domain must be stripped)

**Example:** `tech_owner = "jsmith"`

**Validation Examples:**
- ✓ `tech_owner = "jsmith"` - Correct
- ✗ `tech_owner = "jsmith@company.com"` - Invalid (Contains @)

---

### 7. business_unit (Business Unit Code) - REQUIRED
**Description:** Business unit or department code  
**Type:** String  
**Max Length:** 3 characters  
**Format:** Lowercase letters (2-3 characters)  
**Allowed Values:**
- `aie` - AI Engineering
- `hr` - Human Resources
- `it` - IT Internal
- *(Additional values per organization chart; WIP)*

**Example:** `business_unit = "aie"`

**Validation Examples:**
- ✓ `business_unit = "aie"` - Correct
- ✗ `business_unit = "finance"` - Invalid (Too long)
- ✗ `business_unit = "AIE"` - Invalid (Not lowercase)

---

### 8. cost_center (Cost Center Code) - REQUIRED
**Description:** Cost center code for billing and chargeback  
**Type:** String (numeric)  
**Max Length:** 10 digits  
**Format:** Numeric digits only  
**Requirement:** Non-empty, must be digits only

**Example:** `cost_center = "1000001234"`

**Validation Examples:**
- ✓ `cost_center = "1000001234"` - Correct
- ✗ `cost_center = "CC-1000"` - Invalid (Contains letters)
- ✗ `cost_center = "10000000000"` - Invalid (11 digits)
- ✗ `cost_center = ""` - Invalid (Empty)

---

## Optional Inputs (With Defaults)

These 4 inputs are optional and have default values if not specified:

---

### automation (Optional - Default: "none")
**Description:** Infrastructure-as-Code (IaC) tool used  
**Type:** String  
**Max Length:** 5 characters  
**Format:** Lowercase letters  
**Default Value:** `"none"`
**Allowed Values:**
- `none` - No IaC automation (manually created)
- `tofu` - Terraform or OpenTofu
- `cfmt` - AWS CloudFormation
- `pulu` - Pulumi
- `bice` - Azure Bicep

**When to Provide:** Only if the resource is managed by an IaC tool.

**Example:**
```hcl
automation = "tofu"    # Override default
# OR omit entirely for default "none"
```

---

### backup (Optional - Default: "none")
**Description:** Automatic backup schedule  
**Type:** String  
**Format:** Predefined values  
**Default Value:** `"none"`
**Allowed Values:**
- `none` - No automated backups
- `daily` - Daily backups
- `weekly` - Weekly backups
- `monthly` - Monthly backups

**Special Constraint:** 
- If `backup = "none"`, the `schedule` tag MUST be empty
- If `backup != "none"`, the optional `schedule` tag can be provided

**When to Provide:** When the resource requires automated backups.

**Example:**
```hcl
backup = "daily"    # Override default
# OR omit entirely for default "none"
```

---

### classification (Optional - Default: Empty String)
**Description:** Sensitive data classification  
**Type:** String  
**Default Value:** `""` (empty string, tag not included)
**Allowed Values:**
- `public` - Public, non-sensitive data
- `confidential` - Confidential business data
- `restricted` - Restricted/proprietary data
- `""` - Empty (not included in tags)

**When to Provide:** Only for resources handling sensitive data.

**Example:**
```hcl
classification = "confidential"    # Override default
# OR omit entirely for default empty string
```

---

### schedule (Optional - Default: Empty String)
**Description:** Backup schedule in crontab format  
**Type:** String  
**Default Value:** `""` (empty string, tag not included)
**Format:** Valid crontab expression  
**Requirement:** Only valid if `backup != "none"`

**Crontab Format:** `minute hour day month day_of_week`

**Valid Examples:**
```hcl
schedule = "0 4 * * SUN"      # Every Sunday at 4 AM UTC
schedule = "0 0 * * *"        # Daily at midnight UTC
schedule = "0 2 * * MON-FRI"  # Monday-Friday at 2 AM UTC
schedule = "0 */6 * * *"      # Every 6 hours
```

**When to Provide:** Only if `backup != "none"`.

**Validation Error (INVALID):**
```hcl
backup = "none"
schedule = "0 4 * * SUN"  # ✗ FAILS - schedule not allowed with backup="none"
```

**Valid Example:**
```hcl
backup = "daily"
schedule = "0 4 * * *"  # ✓ Valid - daily backups at 4 AM UTC
```


All resources tagged with this module MUST include the following mandatory tags:

### 1. env (Environment Code)
**Description:** Three-letter environment code  
**Type:** String  
**Max Length:** 3 characters  
**Format:** Lowercase letters only  
**Allowed Values:**
- `prd` - Production
- `stg` - Stage/Staging
- `uat` - User Acceptance Test
- `qa` - Quality Assurance
- `dev` - Development
- `snd` - Sandbox

**Example:** `prd`, `dev`, `stg`

```hcl
env = "prd"
```

---

### 2. app
**Description:** Application short name (3 letters, lowercase)  
**Type:** String  
**Max Length:** Exactly 3 characters  
**Format:** Lowercase letters only  
**Example:** `pay` (for payments), `api` (for api-gateway), `web` (for web-app)

```hcl
app = "pay"
```

**Validation Examples:**
- ✓ `app = "pay"` - Correct (3 lowercase letters)
- ✗ `app = "payments"` - Invalid (too long)
- ✗ `app = "pa"` - Invalid (too short)
- ✗ `app = "PAY"` - Invalid (not lowercase)

**Name Prefix Generation:** The module generates a 6-character name prefix combining:
- All 3 characters of `env` code (e.g., `prd`)
- All 3 characters of `app` code (e.g., `pay`)
- Result: `prdpay`

**Common App Codes:**
- `pay` - Payments
- `api` - API service
- `web` - Web application
- `dat` - Data pipeline
- `els` - Elasticsearch
- `wal` - Wallet
- `aut` - Authentication

---

### 3. project
**Description:** Project name or identifier  
**Type:** String  
**Max Length:** 10 characters  
**Format:** Any characters  
**Example:** `analytics`, `datahub`, `payments`

```hcl
project = "payments"
```

---

### 3. business_owner
**Description:** Business owner responsible for the resource  
**Type:** String  
**Max Length:** 128 characters  
**Format:** Username without domain  
**Requirement:** No `@` symbol (domain must be stripped)

**Example:** `fmoreno`, `jsmith`, `mgarcia`

```hcl
business_owner = "fmoreno"
```

**Validation Error (INVALID):**
```hcl
business_owner = "fmoreno@company.com"  # ❌ Contains @
```

---

### 4. tech_owner
**Description:** Technical owner/engineer responsible for the resource  
**Type:** String  
**Max Length:** 128 characters  
**Format:** Username without domain  
**Requirement:** No `@` symbol (domain must be stripped)

**Example:** `jsmith`, `agarcia`, `kmurphy`

```hcl
tech_owner = "jsmith"
```

**Validation Error (INVALID):**
```hcl
tech_owner = "jsmith@company.com"  # ❌ Contains @
```

---

### 5. business_unit
**Description:** Business unit or department code  
**Type:** String  
**Max Length:** 3 characters  
**Format:** Lowercase letters  
**Allowed Values:**
- `aie` - AI Engineering
- `hr` - Human Resources
- `it` - IT Internal
- *(Additional values per organization chart; WIP)*

**Example:** `aie`, `hr`, `it`

```hcl
business_unit = "aie"
```

**Validation Error (INVALID):**
```hcl
business_unit = "finance"  # ❌ More than 3 letters
business_unit = "AIE"      # ❌ Not lowercase
```

---

### 6. cost_center
**Description:** Cost center code for billing and chargeback  
**Type:** String (numeric)  
**Max Length:** 10 digits  
**Format:** Numeric digits only  
**Requirement:** Non-empty, must be digits only

**Example:** `1234567890`, `5000`, `100001`

```hcl
cost_center = "1000001234"
```

**Validation Error (INVALID):**
```hcl
cost_center = "CC-1000"     # ❌ Contains non-numeric characters
cost_center = ""            # ❌ Empty/blank
cost_center = "12345678901" # ❌ More than 10 digits
```

---

### 7. automation
**Description:** Infrastructure-as-Code (IaC) tool used  
**Type:** String  
**Max Length:** 5 characters  
**Format:** Lowercase letters  
**Allowed Values:**
- `none` - No IaC automation
- `tofu` - Terraform or OpenTofu
- `cfmt` - AWS CloudFormation
- `pulu` - Pulumi
- `bice` - Azure Bicep

**Example:** `tofu`, `cfmt`, `none`

```hcl
automation = "tofu"
```

**Validation Error (INVALID):**
```hcl
automation = "terraform"  # ❌ Use "tofu" instead
automation = "cloudformation"  # ❌ Use "cfmt" instead
automation = "pulumi"     # ❌ Use "pulu" instead
```

---

### 8. backup
**Description:** Automatic backup schedule  
**Type:** String  
**Format:** Predefined values  
**Allowed Values:**
- `none` - No automated backups
- `daily` - Daily backups
- `weekly` - Weekly backups
- `monthly` - Monthly backups

**Example:** `daily`, `weekly`, `none`

```hcl
backup = "daily"
```

**Special Constraint:** 
- If `backup = "none"`, the `schedule` tag MUST be empty
- If `backup != "none"`, the optional `schedule` tag can be provided

**Validation Error (INVALID):**
```hcl
backup = "every-hour"  # ❌ Not an allowed value
backup = "Daily"       # ❌ Must be lowercase
```

---

## Optional Tags

Optional tags provide additional metadata when needed. They are omitted from output when not specified.

### 1. classification
**Description:** Sensitive data classification  
**Type:** String  
**Default:** Empty (not included in tags if not specified)  
**Allowed Values:**
- `public` - Public, non-sensitive data
- `confidential` - Confidential business data
- `restricted` - Restricted/proprietary data

**Example:**
```hcl
classification = "public"
classification = "confidential"
classification = "restricted"
```

**When to Use:**
- Database or storage resources containing sensitive data
- Services processing personal information
- Systems with compliance requirements

---

### 2. schedule
**Description:** Backup schedule in crontab format  
**Type:** String  
**Default:** Empty (omitted if not specified)  
**Format:** Valid crontab expression  
**Requirement:** Only valid if `backup != "none"`

**Crontab Format:** `minute hour day month day_of_week`

**Examples:**
```hcl
# Every Sunday at 4 AM UTC
schedule = "0 4 * * SUN"

# Daily at midnight UTC
schedule = "0 0 * * *"

# Monday through Friday at 2 AM UTC
schedule = "0 2 * * MON-FRI"

# Every 6 hours
schedule = "0 */6 * * *"
```

**Validation Error (INVALID):**
```hcl
backup = "none"
schedule = "0 4 * * SUN"  # ❌ schedule cannot be set if backup is "none"
```

**Valid Example:**
```hcl
backup = "daily"
schedule = "0 4 * * *"  # ✓ Valid: daily backups at 4 AM UTC
```

---

## Complete Tag Example

### Minimal Configuration (Only Mandatory)
```hcl
module "tags" {
  source = "./modules/cloudtags"

  # Mandatory tags
  env             = "prd"
  project         = "payments"
  business_owner  = "fmoreno"
  tech_owner      = "jsmith"
  business_unit   = "aie"
  cost_center     = "1000001234"
  automation      = "tofu"
  backup          = "daily"
}
```

**Output Tags:**
```
env             = "prd"
project         = "payments"
business_owner  = "fmoreno"
tech_owner      = "jsmith"
business_unit   = "aie"
cost_center     = "1000001234"
automation      = "tofu"
backup          = "daily"
name_prefix     = "prdpay"  # Generated: prd + pay
```

### Complete Configuration (with Optional)
```hcl
module "tags" {
  source = "./modules/cloudtags"

  # Mandatory tags
  env             = "prd"
  project         = "analytics"
  business_owner  = "mgarcia"
  tech_owner      = "agarcia"
  business_unit   = "hr"
  cost_center     = "2000000001"
  automation      = "tofu"
  backup          = "weekly"

  # Optional tags
  classification  = "confidential"
  schedule        = "0 2 * * SUN"  # Sunday at 2 AM UTC
}
```

**Output Tags:**
```
env             = "prd"
project         = "analytics"
business_owner  = "mgarcia"
tech_owner      = "agarcia"
business_unit   = "hr"
cost_center     = "2000000001"
automation      = "tofu"
backup          = "weekly"
classification  = "confidential"
schedule        = "0 2 * * SUN"
name_prefix     = "prdan"  # Generated: prd + ana
```

---

## Validation Rules Summary

| Tag | Type | Max Length | Format | Validation |
|-----|------|-----------|--------|-----------|
| env | Mandatory | 3 | Lowercase | One of: prd, stg, uat, qa, dev, snd |
| project | Mandatory | 10 | Any | Non-empty string |
| business_owner | Mandatory | 128 | Username | No @ symbol |
| tech_owner | Mandatory | 128 | Username | No @ symbol |
| business_unit | Mandatory | 3 | Lowercase | 2-3 letters, e.g., aie, hr, it |
| cost_center | Mandatory | 10 | Numeric | Digits only, non-empty |
| automation | Mandatory | 5 | Lowercase | One of: none, tofu, cfmt, pulu, bice |
| backup | Mandatory | 7 | Lowercase | One of: none, daily, weekly, monthly |
| classification | Optional | - | Lowercase | One of: public, confidential, restricted |
| schedule | Optional | - | Crontab | Valid crontab format, only if backup != none |

---

## Conditional Validation Rules

### Schedule Dependency
- **Requirement:** `schedule` can only be set if `backup != "none"`
- **Validation:** Module will fail deployment if this constraint is violated

**VALID:**
```hcl
backup = "daily"
schedule = "0 4 * * *"
```

**INVALID:**
```hcl
backup = "none"
schedule = "0 4 * * *"  # ❌ Fails validation
```

---

## Name Prefix Generation

The module automatically generates a **6-character name prefix** from the mandatory tags:

**Formula:** `{env_code:3}{project_abbr:3}`

| env | project | Prefix |
|-----|---------|--------|
| dev | webapp | devweb |
| prd | payments | prdpay |
| stg | analytics | stgana |
| uat | datahub | uatdat |
| qa | api | qaapi* |
| snd | framework | sndfra |

*Note: Single or two-letter project names are padded to 3 characters with the available letters.

---

## Best Practices

### 1. Consistency
- Use the same `business_owner` and `tech_owner` across related resources
- Keep `project` names consistent across all environments

### 2. Accuracy
- Ensure usernames are correct without domain suffix
- Verify cost center codes match your accounting system
- Use standardized business unit codes from organization chart

### 3. Backup Strategy
- Use `backup = "none"` only for non-critical resources
- For critical resources, set backup to `daily` or `weekly`
- Provide explicit schedules during backup windows to minimize performance impact

### 4. Classification
- Always set `classification` for resources handling sensitive data
- Use `confidential` for business-critical data
- Use `restricted` for data with regulatory requirements

### 5. Automation Tracking
- Track which IaC tool manages each resource with `automation` tag
- Use `automation = "none"` only for manually created resources
- Consider migrating manually created resources to IaC

---

## Migration Guide

### From Old Tag Schema
If migrating from a previous tagging schema, map accordingly:

| Old Tag | New Tag | Notes |
|---------|---------|-------|
| Environment | env | Convert values: dev→dev, prod→prd, stage→stg |
| Application | project | Use application name (max 10 chars) |
| Owner | business_owner | Strip domain if present |
| CreatedBy | automation | Map tool names to: tofu, cfmt, pulu, bice, none |
| Team/Department | business_unit | Map to 2-3 letter code |
| BackupPolicy | backup | Convert: daily→daily, weekly→weekly, none→none |

---

## Troubleshooting

### "env must be one of: prd, stg, uat, qa, dev, snd"
- **Issue:** Invalid environment code provided
- **Solution:** Use one of the allowed values exactly as specified

### "Cost center must be numeric, non-empty, and 10 digits or fewer"
- **Issue:** Cost center contains non-numeric characters or exceeds 10 digits
- **Solution:** Use only digits, maximum 10 characters

### "schedule cannot be set when backup is 'none'"
- **Issue:** You provided a schedule value but backup is set to "none"
- **Solution:** Either remove the schedule value or change backup to daily/weekly/monthly

### "Business unit must be 2-3 lowercase letters"
- **Issue:** Business unit code is invalid
- **Solution:** Use 2-3 lowercase letters like 'aie', 'hr', 'it'

### "must be a non-empty username without domain"
- **Issue:** Username includes domain (e.g., user@company.com)
- **Solution:** Remove the domain part, use just the username

---

## Questions & Support

For questions about tag values, organization codes, or compliance requirements:
1. Check the org chart for current business unit codes
2. Contact Finance for valid cost center codes
3. Contact Security for data classification standards
4. Review this document for allowed values and examples

---

## Default Values (No Input Required)

Some tags have sensible defaults and do NOT need to be specified unless you want to override them:

### automation (Default: "none")
If not specified, defaults to `"none"` (manual, not IaC-managed):
```hcl
automation = "tofu"  # Override default if using Terraform
# OR omit entirely for default "none"
```

### backup (Default: "none")
If not specified, defaults to `"none"` (no automatic backups):
```hcl
backup = "daily"  # Override default if you need backups
# OR omit entirely for default "none"
```

### classification (Default: Empty String)
If not specified, defaults to empty (not included in tags):
```hcl
classification = "confidential"  # Only include if needed
# OR omit entirely for empty string (not included)
```

---

## Removed Input: tag_name_prefix

The `tag_name_prefix` input has been **removed**. The `name_prefix` output is now:
- **Generated automatically** from `env` (3 chars) + `app` (3 chars)
- **Always 6 characters** (e.g., `prdpay`)
- **Output-only** - Not applied to tag keys
- **Used for resource naming** - Not tag naming

### Migration
**Before (Old):**
```hcl
module "tags" {
  tag_name_prefix = "myorg-"  # ❌ No longer supported
}
```

**After (New):**
```hcl
module "tags" {
  app = "pay"  # ✓ 3-letter app code
  # name_prefix automatically becomes "prdpay" (env + app)
}
```

