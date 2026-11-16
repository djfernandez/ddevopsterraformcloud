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
  default     = "trabajofinal"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,12}$", var.project_name))
    error_message = "project_name debe contener de 3 a 12 letras minúsculas, números o guiones."
  }
}

variable "environment" {
  description = "Nombre del entorno de despliegue."
  type        = string
  default     = "dev"
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

variable "tenant_id" {
  description = "ID de tenant de Microsoft Entra."
  type        = string
}

variable "key_vault_secret_name" {
  description = "Nombre del secreto del Key Vault obtenido por /secreto."
  type        = string
  default     = "app-message"
}