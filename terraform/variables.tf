# variable "tags" {
#   description = "Etiquetas opcionales para aplicar al componente"
#   type        = map(string)
#   default = {
#     Environment = ""
#   }
# }

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure región para el despliegue."
  type        = string
  default     = "eastus2"
}

variable "project_name" {
  description = "Identificador corto del proyecto usado en los nombres de los recursos."
  type        = string
  default     = "dfernandez-dmc"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,12}$", var.project_name))
    error_message = "project_name debe contener de 3 a 12 letras minúsculas, números o guiones."
  }
}

variable "environment" {
  description = "Nombre del entorno de despliegue."
  type        = string
  default     = "Desarrollo"
}

variable "departamento" {
  description = "Nombre del departamento que despliegue."
  type        = string
  default     = "TI"
}

variable "creadopor" {
  description = "Nombre del autor que despliegue."
  type        = string
  default     = "Danny Fernández Montoya"
}

variable "container_image" {
  description = "Imagen del contenedor utilizada para la revisión inicial; reemplázala después de subir la imagen de la aplicación."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "sql_admin_username" {
  description = "Inicio de sesión de administrador SQL de Bootstrap (no utilizado por la aplicación)."
  type        = string
  default     = "sqlbootstrap"
}

variable "sql_admin_password" {
  description = "Configura la contraseña de administrador de SQL. Proporciónala de forma segura al aplicarla; el estado de Terraform la contiene."
  type        = string
  sensitive   = true
}

variable "sql_aad_admin_login_username" {
  description = "Nombre para mostrar/inicio de sesión del administrador de Microsoft Entra para el servidor SQL."
  type        = string
}

variable "sql_aad_admin_object_id" {
  description = "ID de objeto del administrador de Microsoft Entra."
  type        = string
}

variable "tenant_id" {
  description = "ID de tenant de Microsoft Entra."
  type        = string
}

variable "key_vault_secret_name" {
  description = "Nombre del secreto del Key Vault obtenido por /secreto."
  type        = string
  default     = "app-message"
}
