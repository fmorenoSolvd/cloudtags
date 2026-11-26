# Multicloud Tag Module

Terraform module that validates a fixed set of tagging inputs and produces a consistent tag set for AWS, Azure, and GCP resources. It also generates a 6-character name prefix.

Source for this document: `variables.tf`, `locals.tf`, `outputs.tf`, `main.tf`, `versions.tf`.

- Usage examples and a checklist: [QUICKSTART.md](QUICKSTART.md)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| hashicorp/null | >= 3.0 |

## Usage

```hcl
module "tags" {
  source = "git::https://github.com/fmorenoSolvd/cloudtags.git"

  env            = "prd"
  app-short      = "pay"
  app-name       = "payments"
  project        = "payments"
  business-owner = "fmoreno"
  tech-owner     = "jsmith"
  business-unit  = "aie"
  cost-center    = "1000001234"
}

resource "aws_instance" "example" {
  # ...
  tags = module.tags.tags
}
```

## Inputs

All input names use lowercase words separated by hyphens.

### Required

| Name | Description | Validation |
|------|-------------|------------|
| `env` | Environment code | One of `prd`, `stg`, `uat`, `qa`, `dev`, `snd` (case-insensitive) |
| `project` | Project name | Non-empty, max 10 characters |
| `app-short` | Application short code | Exactly 3 letters, case-insensitive |
| `app-name` | Application name | Non-empty, max 10 characters |
| `business-owner` | Business owner username | Non-empty, max 128 characters, no `@` |
| `tech-owner` | Technical owner username | Non-empty, max 128 characters, no `@` |
| `business-unit` | Business unit code | 2–3 letters, case-insensitive (e.g. `aie`, `hr`, `it`) |
| `cost-center` | Cost center code | Digits only, non-empty, max 10 digits |

### Optional

| Name | Default | Description | Validation |
|------|---------|-------------|------------|
| `automation` | `"none"` | IaC tool managing the resource | One of `none`, `tofu`, `cfmt`, `pulu`, `bice` |
| `backup` | `"none"` | Backup frequency | One of `none`, `daily`, `weekly`, `monthly` |
| `schedule` | `""` | Backup schedule in crontab format | Empty, or 5 crontab fields. Must not be set when `backup = "none"` (see Validation below) |
| `compliance` | `"none"` | Regulatory compliance requirement | Empty, or one of `hipaa`, `gdpr`, `soc2`, `none` |
| `additional-tags` | `{}` | Extra tags as a map of strings | Keys 1–256 chars, values 1–1024 chars, all non-empty |

> `compliance` is emitted as a `compliance` tag when it is not `"none"`. See [Known gaps](#known-gaps) for the empty-string case.

## Tags

Tags are built from `core_tags`, then `additional-tags` are merged last and override any earlier key with the same name.

| Tag key | Source input | Always present |
|---------|--------------|----------------|
| `env` | `env` | Yes |
| `project` | `project` | Yes |
| `business-owner` | `business-owner` | Yes |
| `tech-owner` | `tech-owner` | Yes |
| `business-unit` | `business-unit` | Yes |
| `app-name` | `app-name` | Yes |
| `cost-center` | `cost-center` | Yes |
| `automation` | `automation` | Yes |
| `backup` | `backup` | Yes |
| `schedule` | `schedule` | Yes, may be an empty string (see Known gaps) |
| `compliance` | `compliance` | Only if not `"none"` |
| *(any)* | `additional-tags` keys | Only if set. Keys are passed through unchanged |

`app-short` is not a tag. It is used for the name prefix and output values.

## Outputs

| Name | Description |
|------|-------------|
| `tags` | Map of all tags. Use for most resources. |
| `tags_list` | List of `{ key, value, propagate_at_launch = true }`. Use for AWS Auto Scaling Groups. |
| `aws_tags` | Same as `tags`. |
| `azure_tags` | Same as `tags`. |
| `gcp_labels` | Tags with keys and values lowercased and spaces replaced by hyphens. |
| `core_tags` | The core tag map, before `additional-tags` are merged. |
| `tags_by_category` | Tags grouped into `identity`, `organization`, `billing`, `infrastructure`, `optional`. |
| `name_prefix` | 6-character prefix: first 3 chars of `env` + `app-short` (lowercased). |
| `env` | Echo of `env`. |
| `app_short` | Echo of `app-short`. |
| `app_name` | Echo of `app-name`. |
| `project` | Echo of `project`. |
| `tag_count` | Number of tags in the final map. |
| `tag_keys` | Sorted list of tag keys. |

Output names use underscores; only inputs and tag keys use hyphens.

## Name prefix

`name_prefix` = `lower(env)` + `lower(app-short)`, for example `prdpay`.

## Validation

Input validation runs when the module is planned. Each rule is listed under Inputs.

A cross-input rule is enforced at apply time through a `null_resource` that runs `local-exec` and exits with an error:

- `schedule` set while `backup = "none"` fails with `schedule cannot be set when backup is "none"`.

## Known gaps

- **Empty values become tags.** `schedule` is always added to the core tags, so it is present as `""` when unset. `compliance` is added when it is not `"none"`, so the empty string passes validation and becomes `compliance = ""`.
- **`gcp_labels` and crontab values.** Lowercasing and space-to-hyphen replacement applies to values too. For example, `schedule = "0 3 * * *"` becomes `"0-3-*-*-*"`. GCP label values may not allow `*`, so check this before using `gcp_labels` with `schedule`.
- **`additional-tags` keys are not normalized.** Keys such as `Team` are kept as written.
- **Schedule check happens at apply time**, not during input validation.

## Files

| File | Purpose |
|------|---------|
| `variables.tf` | Input declarations and validation |
| `locals.tf` | Tag maps, name prefix, cross-input checks |
| `outputs.tf` | Module outputs |
| `main.tf` | `null_resource` checks for cross-input errors |
| `versions.tf` | Terraform and provider versions |
| `QUICKSTART.md` | Usage examples and checklist |
| `LICENSE` | License |
