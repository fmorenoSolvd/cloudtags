# Quick Start

See [README.md](README.md) for the full input, output, and validation reference.

## Required inputs

Every module call must set these eight inputs:

| Input | Example | Rule |
|-------|---------|------|
| `env` | `prd` | One of `prd`, `stg`, `uat`, `qa`, `dev`, `snd` |
| `app-short` | `pay` | Exactly 3 letters |
| `app-name` | `payments` | Max 10 characters |
| `project` | `payments` | Max 10 characters |
| `business-owner` | `fmoreno` | Username, no `@` |
| `tech-owner` | `jsmith` | Username, no `@` |
| `business-unit` | `aie` | 2–3 letters |
| `cost-center` | `1000001234` | Digits only, max 10 |

## Optional inputs

| Input | Default | Allowed values |
|-------|---------|----------------|
| `automation` | `"none"` | `none`, `tofu`, `cfmt`, `pulu`, `bice` |
| `backup` | `"none"` | `none`, `daily`, `weekly`, `monthly` |
| `schedule` | `""` | Crontab, only when `backup` is not `"none"` |
| `compliance` | `"none"` | `hipaa`, `gdpr`, `soc2`, `none` (validated only; not emitted as a tag) |
| `additional-tags` | `{}` | Map of string keys to string values |

## Minimal configuration

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
```

Resulting tags:

```hcl
{
  "env"            = "prd"
  "app-name"       = "payments"
  "project"        = "payments"
  "business-owner" = "fmoreno"
  "tech-owner"     = "jsmith"
  "business-unit"  = "aie"
  "cost-center"    = "1000001234"
  "automation"     = "none"
  "backup"         = "none"
}
```

`module.tags.name_prefix` is `"prdpay"`.

## Complete configuration

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

  automation     = "tofu"
  backup         = "daily"
  schedule       = "0 3 * * *"

  additional-tags = {
    Team = "payments"
  }
}
```

This adds `automation = "tofu"`, `backup = "daily"`, `schedule = "0 3 * * *"`, and `Team = "payments"` to the tag map.

## Using the tags

```hcl
resource "aws_instance" "app" {
  # ...
  tags = module.tags.tags
}

resource "aws_autoscaling_group" "app" {
  # ...
  tag = module.tags.tags_list
}
```

## Checklist

- [ ] Have the eight required values ready
- [ ] Choose `automation` (`tofu`, `cfmt`, `pulu`, `bice`, or `none`)
- [ ] Choose `backup` (`daily`, `weekly`, `monthly`, or `none`)
- [ ] If `backup` is not `none`, set `schedule` in crontab format
- [ ] If `backup` is `none`, leave `schedule` empty (apply fails otherwise)
- [ ] Run `terraform plan` to check validation
