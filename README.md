# Azure Container Apps IaC

Microservicio REST en ASP.NET Core/.NET 8 desplegado en Azure Container Apps. Terraform aprovisiona los servicios Azure; la aplicación usa Managed Identity para Key Vault, Azure Files, ACR y Azure SQL.

## Estructura

```text
src/AzureContainerApps.Api/   API .NET 8 y SVG de ejemplo
terraform/                    Infraestructura como código
scripts/Deploy.ps1            Publicar, crear/push de imagen y actualizar la app
docs/                         Arquitectura y operación
Dockerfile                    Imagen multi-stage con runtime .NET
```

## Requisitos

- .NET 8 SDK
- Terraform >= 1.5
- Azure CLI autenticada (`az login`) con permisos para crear recursos y asignar roles
- Docker Desktop con el motor Linux iniciado
- Una suscripción Azure que permita crear Container Apps, ACR, Key Vault y Storage

## Despliegue inicial

1. Inicia sesión en Azure y configura la suscripción:

   ```powershell
   az login
   az account set --subscription "<subscription-id>"
   az provider register --namespace Microsoft.KeyVault --subscription "<subscription-id>" --wait
   az provider register --namespace Microsoft.App --subscription "<subscription-id>" --wait
   az provider register --namespace Microsoft.ManagedIdentity --subscription "<subscription-id>" --wait
   az provider register --namespace Microsoft.ContainerRegistry --subscription "<subscription-id>" --wait
   az provider register --namespace Microsoft.Storage --subscription "<subscription-id>" --wait
   az provider show --namespace Microsoft.KeyVault --subscription "<subscription-id>" --query registrationState --output tsv
   ```

   Sustituye el marcador por el mismo ID configurado en `subscription_id` de `terraform.tfvars`. Verifica que el registro de los proveedores necesarios se complete antes de volver a ejecutar `terraform apply`. Terraform está configurado para no registrar proveedores automáticamente. El usuario necesita permiso para registrarlos en la suscripción; si no lo tiene, solicita a un administrador que registre `Microsoft.KeyVault`, `Microsoft.App`, `Microsoft.ManagedIdentity`, `Microsoft.ContainerRegistry` y `Microsoft.Storage`.

2. Copia `terraform/terraform.tfvars.example` a `terraform/terraform.tfvars` y completa los valores de la suscripción y el tenant de Microsoft Entra.

3. Inicializa y crea la infraestructura:

   ```powershell
   terraform -chdir=terraform init
   terraform -chdir=terraform validate
   terraform -chdir=terraform plan
   terraform -chdir=terraform apply
   ```

   El bloque `import` de `terraform/resource_group.tf` adopta el Resource Group que ya existe en la suscripción configurada. Si despliegas en una suscripción nueva donde ese grupo no existe, elimina ese bloque antes del primer `apply` para que Terraform pueda crearlo.

   El primer apply crea una Container App con una imagen pública de ejemplo. El script de despliegue la reemplaza por la imagen de esta aplicación.
   Terraform usa Microsoft Entra para cargar `sample.svg` y asigna `Storage File Data Privileged Contributor` al principal que ejecuta el despliegue; si el rol todavía no se propagó y falla la carga, vuelve a ejecutar `terraform apply` unos minutos después.

4. Crea el secreto `app-message` en Key Vault desde **Azure Portal → Key Vault → Secrets → Generate/Import**. No pongas su valor en Terraform, en el repositorio ni en una línea de comandos.

5. Publica y despliega la aplicación:

   ```powershell
   .\scripts\Deploy.ps1
   ```

   El usuario de Azure CLI necesita `AcrPush` en el registro. Si aún no se ha propagado la asignación del rol, espera unos minutos e intenta de nuevo.

6. Obtén la URL y prueba los endpoints:

   ```powershell
   $url = terraform -chdir=terraform output -raw container_app_url
   Invoke-RestMethod "$url/hello"
   Invoke-RestMethod "$url/variable"
   Invoke-RestMethod "$url/secreto"
   Invoke-WebRequest "$url/imagen" -OutFile sample.svg
   ```

   Terraform ya no aprovisiona ni configura Azure SQL. El endpoint `/consulta` requiere un servidor y una base externos, configurados manualmente en la Container App; sin ellos no estará disponible.

## Desarrollo local

```powershell
dotnet run --project src/AzureContainerApps.Api
```

`/hello` y `/health` funcionan localmente sin credenciales. Para probar Key Vault, Azure Files o SQL, configura el entorno Azure y ejecuta `az login`; la identidad local debe tener los mismos roles de datos necesarios. `/variable` requiere `WELCOME_MESSAGE`.

## Contenerización manual

```powershell
dotnet publish src/AzureContainerApps.Api/AzureContainerApps.Api.csproj -c Release -o publish
docker build -t aca-api:local .
docker run --rm -p 8080:8080 -e WELCOME_MESSAGE="Hola" aca-api:local
```

## Recursos y decisiones

- Resource Group, Log Analytics y Container Apps Environment.
- Container App con ingress HTTPS público, puerto 8080 y escalado HTTP de 1 a 3 réplicas.
- ACR Basic sin usuario administrador; la identidad de la app tiene `AcrPull`.
- User Assigned Managed Identity con roles mínimos para Key Vault y Azure Files.
- Key Vault con autorización RBAC, eliminación recuperable y protección contra purga.
- Storage Account con TLS 1.2, acceso por clave deshabilitado, y un file share privado con `sample.svg`.
- El endpoint `/consulta` conserva la integración de la aplicación con Azure SQL, pero Terraform no aprovisiona SQL. Para usarlo, configura un servidor y una base externos en la Container App y concede acceso a su identidad administrada.

Consulta el [diagrama y los contratos de endpoints](docs/architecture.md) y las [notas operativas y de seguridad](docs/operations.md).
