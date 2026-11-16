# Arquitectura

```text
Cliente HTTPS
    |
    v
Azure Container Apps (ingress público, puerto 8080, 1-3 réplicas)
    |-- identidad administrada asignada por el usuario
    |      |-- Key Vault (Key Vault Secrets User)
    |      |-- Azure Files (Storage File Data Privileged Reader)
    |      `-- ACR (AcrPull)
    `-- logs de aplicación --> Log Analytics

Azure SQL externo (opcional) --> `/consulta`

Desarrollador --> Azure Container Registry (az acr login / AcrPush)
```

La aplicación obtiene las credenciales de Azure con `DefaultAzureCredential`. En Azure Container Apps se selecciona la identidad asignada por el usuario mediante `AZURE_CLIENT_ID`; no se configuran claves de Storage ni contraseñas de base de datos en el contenedor. El secreto de demostración se crea directamente en Key Vault y se recupera en tiempo de ejecución. Terraform no aprovisiona Azure SQL; `/consulta` solo funciona si se configura una base externa.

## Endpoints

| Ruta | Resultado |
|---|---|
| `GET /hello` | Saludo JSON |
| `GET /variable` | Valor de `WELCOME_MESSAGE` |
| `GET /secreto` | Secreto `app-message` (o `KEY_VAULT_SECRET_NAME`) desde Key Vault |
| `GET /imagen` | Contenido del archivo privado `images/sample.svg` en Azure Files |
| `GET /consulta` | Nombre de la base y hora UTC mediante una consulta SQL fija |
| `GET /health` | Estado de salud |

El endpoint `/consulta` no acepta SQL proporcionado por el cliente. Para habilitarlo, configura `SQL_SERVER_FQDN` y `SQL_DATABASE` en la Container App y concede a su identidad el rol `db_datareader` en la base externa.
