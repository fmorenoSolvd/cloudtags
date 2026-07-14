# Module Features Overview

## 6-Character Name Prefix

The module automatically generates a 6-character prefix combining environment and application abbreviations:

### Generation Logic
```
env_abbr = first 3 chars of environment (lowercase)
app_abbr = first 3 chars of application (lowercase)
name_prefix = env_abbr + app_abbr (max 6 chars total)
```

### Examples
| Environment | Application | Name Prefix |
|------------|-------------|------------|
| dev | myapp | devmya |
| production | backend | prodba |
| staging | api-gateway | stagap |
| test | elasticsearch | testey |

## Tag Categories

Tags are organized into logical categories for easy reference and management:

### 1. Identity Tags (Always Included)
- **Environment**: Deployment environment
- **Application**: Application identifier
- **Owner**: Team/person responsible

### 2. Metadata Tags (Always Included)
- **CreatedBy**: Tool/framework used (default: terraform)
- **ManagedBy**: Always "Terraform"
- **TerraformVersion**: Optional - track Terraform version for debugging

### 3. Billing Tags (Optional)
- **CostCenter**: For cost allocation and chargeback

### 4. Organization Tags (Optional)
- **Team**: Responsible team
- **Project**: Associated project
- **BusinessUnit**: Business organization
- **CloudProvider**: Cloud provider (aws/azure/gcp)

### 5. Custom Tags (Optional)
Any additional tags provided via `additional_tags` variable

## Cloud-Specific Outputs

### AWS Format
Standard key-value tag map compatible with all AWS resources:
```hcl
tags = module.tags.tags
```

### AWS Auto Scaling Groups
Special list format with propagate_at_launch flag:
```hcl
tag = module.tags.tags_list
```

### Azure Format
Standard key-value tag map for Azure resources:
```hcl
tags = module.tags.azure_tags
```

### GCP Format
Labels with lowercase keys and hyphens instead of spaces:
```hcl
labels = module.tags.gcp_labels
```

## Validation Features

### Input Validation
- All strings validated for non-empty (after trimming)
- Maximum length constraints enforced
- Cloud provider whitelist validation
- Tag key-value length validation in additional_tags

### Mandatory Tags Validation
- Ensures specified mandatory tags are present in output
- Fails deployment if mandatory tags missing
- Useful for compliance and governance

### Tag Naming
- Automatic prefix support for multi-tenant scenarios
- Space-to-hyphen conversion for GCP labels
- Case normalization for different cloud providers

## Multicloud Support

### AWS
- Native tag support
- ASG-specific formatting
- Integrates with cost allocation tags
- Compatible with AWS Systems Manager OpsCenter

### Azure
- Resource group tags
- Meets Azure naming requirements
- Compatible with Azure Policy for tag governance
- Integrates with Azure Cost Management

### GCP
- Label support with strict naming rules
- Automatic lowercase conversion
- Space-to-hyphen conversion
- Maximum 63 characters per label key/value

## Use Cases

### 1. Microservices Architecture
```hcl
module "tags" {
  source = "./cloudtags"
  
  environment = "prod"
  application = "payment-service"
  owner       = "payments-team"
  project     = "transaction-platform"
  team        = "backend"
  
  additional_tags = {
    ServiceMesh = "istio"
    CircuitBreaker = "enabled"
  }
}
```

### 2. Multi-Tenant SaaS
```hcl
module "tags" {
  source = "./cloudtags"
  
  environment    = "prod"
  application    = "saas-platform"
  owner          = "platform-team"
  tag_name_prefix = "tenant-${var.tenant_id}-"
  
  additional_tags = {
    TenantID     = var.tenant_id
    TierLevel    = var.tenant_tier
    DataResidency = var.tenant_region
  }
}
```

### 3. Cost Attribution & Chargeback
```hcl
module "tags" {
  source = "./cloudtags"
  
  environment    = "prod"
  application    = "data-warehouse"
  owner          = "analytics-team"
  cost_center    = "CC-ANALYTICS-001"
  business_unit  = "insights"
  project        = "data-lake-v2"
  
  mandatory_tags = [
    "Environment",
    "Application",
    "Owner",
    "CostCenter",
    "BusinessUnit"
  ]
}
```

### 4. Compliance & Governance
```hcl
module "tags" {
  source = "./cloudtags"
  
  environment = "prod"
  application = "healthcare-api"
  owner       = "compliance-team"
  
  additional_tags = {
    DataClassification = "PHI"
    ComplianceFramework = "HIPAA"
    EncryptionRequired  = "true"
    AuditLogging        = "enabled"
    BackupStrategy      = "daily"
    DisasterRecovery    = "required"
  }
  
  mandatory_tags = [
    "Environment",
    "Application",
    "DataClassification",
    "ComplianceFramework"
  ]
}
```

### 5. Development Environment
```hcl
module "tags" {
  source = "./cloudtags"
  
  environment = "dev"
  application = "feature-branch"
  owner       = "dev-team"
  
  additional_tags = {
    AutoShutdown = "true"
    TempResource = "true"
    RetentionDays = "7"
  }
}
```

## Integration Patterns

### Pattern 1: Shared Across Modules
```hcl
module "tags" {
  source = "./cloudtags"
  environment = "prod"
  application = "microservices"
  owner = "platform"
}

module "vpc" {
  source = "./modules/vpc"
  tags = module.tags.tags
  name_prefix = module.tags.name_prefix
}

module "database" {
  source = "./modules/database"
  tags = module.tags.tags
  name_prefix = module.tags.name_prefix
}
```

### Pattern 2: Environment Specific
```hcl
module "tags_dev" {
  source = "./cloudtags"
  environment = "dev"
  application = var.app_name
  owner = "dev-team"
}

module "tags_prod" {
  source = "./cloudtags"
  environment = "prod"
  application = var.app_name
  owner = "ops-team"
  mandatory_tags = ["CostCenter", "Environment"]
}
```

### Pattern 3: Multi-Region
```hcl
module "tags_region" {
  source = "./cloudtags"
  environment = var.environment
  application = var.application
  owner = var.owner
  
  additional_tags = {
    Region = var.aws_region
    RegionType = var.region_type # "primary" or "dr"
  }
}
```

## Output Reference

| Output | Use Case |
|--------|----------|
| `tags` | Primary output for most use cases |
| `tags_list` | AWS ASG and EC2 launch template tags |
| `name_prefix` | Resource naming prefix |
| `tags_by_category` | Understanding tag organization |
| `aws_tags` | Explicit AWS tagging |
| `azure_tags` | Explicit Azure tagging |
| `gcp_labels` | GCP-specific labels |
| `tag_count` | Auditing tag counts |
| `tag_keys` | Reference of all applied tags |

## Best Practices

1. **Define organization standards** - Document required tags and mandatory tags at organization level
2. **Use consistent naming** - Keep environment and application names consistent across teams
3. **Leverage name_prefix** - Use for standardized resource naming
4. **Implement mandatory tags** - Enforce compliance requirements via mandatory_tags variable
5. **Cost attribution** - Always populate cost_center for billing
6. **Team accountability** - Use owner and team for clear responsibility
7. **Version tracking** - Populate terraform_version for debugging
8. **Documentation** - Use additional_tags for compliance and compliance-related metadata

## Troubleshooting

### "Missing mandatory tags" error
- Check that all specified mandatory_tags keys exist in the module outputs
- Ensure tag key names match exactly (case-sensitive)
- Verify additional_tags are not overriding core tags

### Name prefix not as expected
- Name prefix is exactly 6 characters (first 3 of env + first 3 of app)
- Spaces in names are removed before truncation
- All characters are lowercased

### GCP label failures
- GCP labels are automatically converted to lowercase
- Spaces become hyphens
- Special characters should be avoided
- Module handles this automatically via gcp_labels output

### Azure tag rejections
- Avoid special characters in tag values
- Keep tag values under 1024 characters
- Use gcp_labels output for GCP, azure_tags for Azure

