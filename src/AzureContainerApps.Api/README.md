# AzureContainerApps.Api

API REST en ASP.NET Core sobre .NET 8. La aplicación ofrece endpoints de demostración para comprobar la configuración de Azure Container Apps, Key Vault, Azure Files y, opcionalmente, Azure SQL.

## Requisitos

- .NET 8 SDK
- Para endpoints de Azure: una sesión válida de Azure (`az login`) y permisos de datos para la identidad utilizada

## Ejecutar localmente

Desde la raíz del repositorio:

```powershell
dotnet run --project src/AzureContainerApps.Api
```

La consola muestra la URL local donde escucha la API. `/hello` y `/health` no requieren configuración de Azure. `/variable` requiere `WELCOME_MESSAGE`.

## Endpoints

| Método y ruta | Descripción | Configuración necesaria |
|---|---|---|
| `GET /hello` | Devuelve un saludo. | Ninguna |
| `GET /health` | Devuelve el estado de salud. | Ninguna |
| `GET /variable` | Devuelve el valor de `WELCOME_MESSAGE`. | `WELCOME_MESSAGE` |
| `GET /secreto` | Lee el secreto de Key Vault y devuelve su valor. | `KEY_VAULT_URI`; `KEY_VAULT_SECRET_NAME` es opcional |
| `GET /imagen` | Descarga un archivo de la raíz de un Azure Files share. | `STORAGE_FILE_ENDPOINT`, `FILE_SHARE_NAME`, `FILE_NAME` |
| `GET /consulta` | Consulta el nombre de la base y la hora UTC en Azure SQL. | `SQL_SERVER_FQDN`, `SQL_DATABASE` |

La autenticación con servicios Azure usa `DefaultAzureCredential`. En Container Apps, `AZURE_CLIENT_ID` selecciona la identidad administrada asignada por el usuario. Para desarrollo local, inicia sesión con Azure CLI y asegúrate de que tu identidad tenga acceso a los recursos.

Terraform de este repositorio no aprovisiona Azure SQL. Para usar `/consulta`, configura un servidor y una base externos, asigna permisos de base de datos a la identidad de la aplicación y define las variables requeridas en Container Apps.

## Crear y desplegar la imagen

Desde la raíz del repositorio, después de aprovisionar la infraestructura y configurar el acceso `AcrPush`:

```powershell
.\scripts\Deploy.ps1
```

El script publica este proyecto, construye la imagen Docker, la sube a Azure Container Registry y actualiza la Container App. Consulta el [README principal](../../README.md) para el despliegue completo.

## Seguridad

Este proyecto es una demostración. `/secreto` devuelve el valor del secreto en la respuesta y los endpoints no implementan autenticación de usuarios. No expongas la API públicamente en producción sin añadir autenticación y controles de acceso adecuados.
