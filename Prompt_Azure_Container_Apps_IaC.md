# Prompt - Evaluación Final IaC con Azure Container Apps

Actúa como un Arquitecto Cloud Senior especializado en Azure, Terraform, Docker, DevOps, Azure Container Apps y .NET 8.

Necesito desarrollar una solución completa para una evaluación final de Infraestructura como Código (IaC) utilizando exclusivamente Azure Container Apps como plataforma de despliegue.

Debes diseñar la arquitectura, generar el código, la infraestructura Terraform, la contenerización, la documentación y los scripts de despliegue siguiendo buenas prácticas de seguridad, observabilidad, automatización y cloud native.

# Objetivo General

Desarrollar un microservicio REST en ASP.NET Core (.NET 8) desplegado sobre Azure Container Apps, integrando Azure Key Vault, Azure Storage Account y Azure Container Registry (ACR), con toda la infraestructura aprovisionada mediante Terraform.

# Requerimientos Funcionales

## Endpoint /hello
Retorna un saludo.

## Endpoint /variable
Retorna una variable de entorno configurada en Azure Container Apps.

## Endpoint /secreto
Debe obtener un secreto almacenado en Azure Key Vault.

Requisitos:
- Utilizar Azure Key Vault.
- Crear Key Vault mediante Terraform.
- Configurar acceso mediante Managed Identity.
- No almacenar secretos en el código.
- Utilizar Azure SDK para Key Vault.

## Endpoint /imagen
Debe obtener una imagen almacenada en Azure Files dentro de una Azure Storage Account.

Requisitos:
- Crear Storage Account mediante Terraform.
- Crear un file share mediante Terraform.
- Cargar una imagen de ejemplo.
- Retornar el contenido de la imagen.

## Endpoint /consulta (Opcional)
Debe conectarse a una base de datos y ejecutar una consulta simple.

# Contenerización

Generar:
- Dockerfile Multi Stage
- .dockerignore
- Imagen optimizada para producción

# Infraestructura Azure

Toda la infraestructura debe generarse con Terraform.

## Recursos Obligatorios
- Resource Group
- Log Analytics Workspace
- Container App Environment
- Azure Container App
- Azure Container Registry (ACR)
- Managed Identity
- Azure Key Vault
- Azure Storage Account
- Azure Files share

## Recursos Opcionales
- Azure SQL Database
- Application Insights

# Terraform

Generar:
- providers.tf
- variables.tf
- main.tf
- outputs.tf
- terraform.tfvars.example
- locals.tf (si es necesario)

# Azure Container Apps

Configurar:
- Ingress HTTP público
- Puerto 8080
- Escalado automático
- Réplicas mínimas = 1
- Réplicas máximas = 3
- Variables de entorno
- Integración con Managed Identity

# Azure Container Registry

Crear mediante Terraform.

Implementar autenticación entre Container App y ACR utilizando Managed Identity.

# Script Automatizado de Despliegue

Crear script Bash o PowerShell que ejecute:
1. dotnet publish
2. docker build
3. docker tag
4. docker push hacia ACR
5. actualización de Azure Container App

# Git Ignore Terraform

Excluir:
- .terraform/
- *.tfstate
- *.tfstate.*
- terraform.tfvars
- crash.log
- override.tf
- override.tf.json

# Repositorios Esperados

## Repositorio Aplicación
- /src
- /docs
- Dockerfile
- .dockerignore
- README.md

## Repositorio Infraestructura
- /terraform
- providers.tf
- main.tf
- variables.tf
- outputs.tf
- README.md

# Documentación

Generar README completo para aplicación e infraestructura.

# Arquitectura

Usuario
   |
   v
Azure Container Apps
   |
   +--> Managed Identity
              |
              +--> Azure Key Vault
              +--> Azure Storage Account
   |
   +--> Azure Container Registry

# Entregables

1. Código fuente completo ASP.NET Core .NET 8.
2. Controladores y endpoints.
3. Servicios para Key Vault.
4. Servicios para Azure Files.
5. Dockerfile funcional.
6. Terraform completo.
7. Script automático de despliegue.
8. Diagrama de arquitectura.
9. README de aplicación.
10. README de infraestructura.
11. Explicación detallada de cada recurso Azure utilizado.
12. Guía paso a paso para desplegar desde cero en Azure.
13. Buenas prácticas de seguridad, costos y operación.
