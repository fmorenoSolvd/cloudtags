# Validate constraint: schedule can only be set if backup is not "none"
resource "null_resource" "schedule_validation" {
  count = local.schedule_requires_backup ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Error: schedule cannot be set when backup is \"none\"' && exit 1"
  }
}

# Validate all validation errors
resource "null_resource" "validation_errors" {
  count = length(local.validation_errors) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Validation errors: ${join("; ", local.validation_errors)}' && exit 1"
  }
}
