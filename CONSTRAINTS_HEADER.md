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

