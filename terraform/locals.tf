locals {
  compact_name = replace(var.project_name, "-", "")
  suffix       = random_string.suffix.result
  tags = {
    project       = var.project_name
    environment   = var.environment
    managed_by    = var.creadopor
    departamento  = var.departamento
  }
}
