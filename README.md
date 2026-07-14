# Multicloud Tag Module

A comprehensive Terraform module for managing consistent tagging across multicloud environments (AWS, Azure, GCP). This module provides a centralized, validated approach to tagging with support for environment-based naming, mandatory tags, and cloud-specific formatting.

## Features

- **Multicloud Support**: Native formatting for AWS, Azure, and GCP resources
- **6-Character Name Prefix**: Automatically generated from environment and application names for resource naming
- **Validated Inputs**: Comprehensive validation for all tag inputs
- **Flexible Tagging**: Core tags, optional tags, and additional custom tags
- **Cloud-Specific Formats**: Different tag formats optimized for each cloud provider
- **Mandatory Tags**: Enforce specific tags in output
- **Tag Categorization**: Organized views of tags by type (identity, metadata, billing, organization)
- **ASG Compatibility**: Special formatting for AWS Auto Scaling Groups

## Usage

### Basic Example

```hcl
module "tags" {
  source = "./cloudtags"

  environment = "dev"
  application = "myapp"
  owner       = "platform-team"
}
```

### Complete Example

```hcl
module "tags" {
  source = "./cloudtags"

  # Required variables
  environment = "production"
  application = "webapp"
  owner       = "backend-team"

  # Optional variables
  created_by        = "terraform"
  cost_center       = "CC-12345"
  cloud_provider    = "aws"
  project           = "digital-transformation"
  team              = "backend"
  business_unit     = "engineering"
  terraform_version = "1.5.0"

  # Additional custom tags
  additional_tags = {
    "DataClassification" = "confidential"
    "BackupPolicy"       = "daily"
    "ComplianceGroup"    = "hipaa"
  }

  # Enforce specific tags
  mandatory_tags = ["Environment", "Application", "Owner"]

  # Optional tag prefix (e.g., for multi-tenant scenarios)
  tag_name_prefix = "myorg-"
}

# Use in AWS resources
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = merge(
    module.tags.tags,
    {
      Name = "${module.tags.name_prefix}-server-001"
    }
  )
}

# Use with AWS ASG
resource "aws_autoscaling_group" "example" {
  name                = "${module.tags.name_prefix}-asg"
  min_size            = 1
  max_size            = 5
  desired_capacity    = 3
  vpc_zone_identifier = var.subnet_ids

  tag = module.tags.tags_list
}

# Use in Azure resources
resource "azurerm_resource_group" "example" {
  name       = "${module.tags.name_prefix}-rg"
  location   = "East US"

  tags = module.tags.azure_tags
}

# Use in GCP resources
resource "google_compute_instance" "example" {
  name         = "${module.tags.name_prefix}-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  labels = module.tags.gcp_labels
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `environment` | The environment (dev, staging, prod, etc.) | `string` | Yes | - |
| `application` | Application name and/or identifier | `string` | Yes | - |
| `owner` | Owner or team responsible for this resource | `string` | Yes | - |
| `created_by` | Framework or method that created the resource | `string` | No | `"terraform"` |
| `cost_center` | Cost center or billing code for chargeback | `string` | No | `""` |
| `cloud_provider` | Cloud provider (aws, azure, gcp, or empty) | `string` | No | `""` |
| `project` | Project name or identifier | `string` | No | `""` |
| `team` | Team or department managing this resource | `string` | No | `""` |
| `business_unit` | Business unit or organization | `string` | No | `""` |
| `terraform_version` | Version of Terraform used | `string` | No | `""` |
| `additional_tags` | Additional optional tags as key-value pairs | `map(string)` | No | `{}` |
| `mandatory_tags` | List of tag keys that must be present | `list(string)` | No | `[]` |
| `tag_name_prefix` | Prefix to apply to all tag keys | `string` | No | `""` |

## Outputs

| Name | Description |
|------|-------------|
| `tags` | Map of tags suitable for AWS, Azure, and other resources |
| `tags_list` | Tags formatted as a list for AWS Auto Scaling Groups |
| `name_prefix` | 6-character prefix derived from environment and application |
| `environment` | The environment value |
| `application` | The application name value |
| `core_tags` | Core tags always included |
| `optional_tags` | Optional tags based on inputs |
| `tags_by_category` | Tags organized by category (identity, metadata, billing, organization) |
| `aws_tags` | Tags formatted for AWS resources |
| `azure_tags` | Tags formatted for Azure resources |
| `gcp_labels` | Labels formatted for GCP resources |
| `tag_count` | Total number of tags |
| `tag_keys` | Sorted list of all tag keys |

## Name Prefix Generation

The `name_prefix` output generates a 6-character identifier from the environment and application:

- Takes the first 3 characters of the environment (lowercased)
- Takes the first 3 characters of the application (lowercased)
- Combines them to create a maximum 6-character prefix

**Examples:**
- `environment = "dev"`, `application = "webapp"` → `devweb`
- `environment = "production"`, `application = "backend"` → `prodba`
- `environment = "staging"`, `application = "api"` → `stagapi`

## Tag Structure

### Core Tags (Always Included)
- `Environment`: The deployment environment
- `Application`: The application name
- `Owner`: The responsible owner/team
- `CreatedBy`: The tool/framework used
- `ManagedBy`: Always set to "Terraform"

### Optional Tags (Included if Provided)
- `CostCenter`: For billing and cost allocation
- `CloudProvider`: The cloud provider being used
- `Project`: Associated project
- `Team`: Responsible team
- `BusinessUnit`: Business organization
- `TerraformVersion`: Terraform version used

### Additional Tags
Custom tags provided via `additional_tags` variable with highest priority.

## Cloud Provider Support

### AWS
- Uses standard tag map format
- Supports ASG-specific formatting via `tags_list`
- Compatible with all AWS resources

### Azure
- Uses standard tag map format
- Meets Azure naming requirements
- Compatible with all Azure resources

### GCP
- Converts to lowercase labels with hyphens
- Meets GCP label naming restrictions
- Automatically formats via `gcp_labels` output

## Validation Rules

All inputs are validated for:
- Non-empty strings (trimmed)
- Maximum length constraints
- Format requirements (e.g., cloud provider values)

Mandatory tag validation ensures that all specified required tags are present in the final output.

## Examples

### Development Environment

```hcl
module "tags_dev" {
  source = "./cloudtags"

  environment    = "dev"
  application    = "backend"
  owner          = "backend-team"
  cloud_provider = "aws"
  team           = "engineering"

  additional_tags = {
    "AutoShutdown" = "true"
    "RetentionDays" = "7"
  }
}
```

### Production Environment

```hcl
module "tags_prod" {
  source = "./cloudtags"

  environment      = "prod"
  application      = "webapp"
  owner            = "platform-team"
  cost_center      = "CC-PROD-001"
  cloud_provider   = "aws"
  team             = "platform"
  business_unit    = "operations"
  terraform_version = "1.5.0"

  mandatory_tags = [
    "Environment",
    "Application",
    "Owner",
    "CostCenter"
  ]

  additional_tags = {
    "Backup"           = "daily"
    "BackupRetention"  = "30"
    "DisasterRecovery" = "required"
    "Monitoring"       = "enhanced"
  }
}
```

### Multi-Tenant SaaS

```hcl
module "tags_tenant" {
  source = "./cloudtags"

  environment     = "prod"
  application     = "saas-api"
  owner           = "platform-team"
  project         = var.tenant_id
  tag_name_prefix = "tenant-"

  additional_tags = {
    "TenantID"  = var.tenant_id
    "TierLevel" = var.tenant_tier
  }
}
```

## Best Practices

1. **Consistency**: Use this module across all infrastructure code for consistent tagging
2. **Mandatory Tags**: Define mandatory tags per organization to enforce compliance
3. **Naming**: Use the `name_prefix` output for consistent resource naming
4. **Cost Attribution**: Always populate `cost_center` for billing and chargeback
5. **Team Tracking**: Use `owner` and `team` for RACI matrices and escalations
6. **Versioning**: Track the Terraform version using `terraform_version` for troubleshooting
7. **Environment Separation**: Use different modules per environment to prevent accidental cross-environment tag mixing

## Troubleshooting

### Missing Mandatory Tags Error
If you receive an error about missing mandatory tags:
1. Check that you've specified all required `mandatory_tags` keys
2. Ensure the keys match the tag names in the module output
3. Verify that additional tags aren't being merged with incompatible keys

### Name Prefix Truncation
The name prefix is limited to 6 characters. For longer identifiers:
- Use the `environment` and `application` outputs separately
- Create additional outputs in your root module

### Cloud Provider Specific Issues

**GCP Labels**: If labels are rejected, remember that GCP converts them to lowercase with hyphens. The module handles this automatically via the `gcp_labels` output.

**Azure**: Ensure cost_center and other values don't contain special characters that Azure prohibits.

**AWS**: The `tags_list` output is specifically formatted for Auto Scaling Groups with `propagate_at_launch = true`.

## License

This module is provided as-is for use in your infrastructure projects.
