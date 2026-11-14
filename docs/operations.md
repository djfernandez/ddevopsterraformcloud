# Operación y seguridad

- **Identidad:** la Container App usa una identidad administrada asignada por el usuario. Terraform asigna `AcrPull`, `Key Vault Secrets User` y `Storage File Data Privileged Reader` en sus respectivos ámbitos. El principal que ejecuta Terraform recibe `Storage File Data Privileged Contributor` en el file share para cargar la imagen.
- **Secretos:** el secreto de demostración se carga en Key Vault fuera de Terraform para no persistir su valor en el estado. No guardar secretos en el repositorio ni en `terraform.tfvars`.
- **Estado de Terraform:** `sql_admin_password` es un valor sensible pero queda almacenado en el estado de Terraform. En un entorno compartido, configurar antes un backend remoto con cifrado, RBAC y versionado; restringir el acceso al estado.
- **SQL:** el servidor requiere una cuenta de bootstrap para Azure SQL, pero la aplicación se autentica con Microsoft Entra y Managed Identity. La regla `AllowAzureServices` se incluye para facilitar la conectividad del Container Apps Environment en esta demo; es amplia. En producción, sustituirla por conectividad privada/VNet y reglas de red limitadas.
- **ACR:** el registro deshabilita la cuenta de administrador. El desarrollador que publica necesita `AcrPush`; la Container App solo obtiene `AcrPull`.
- **Storage:** `sample.svg` se almacena en un file share privado de Azure Files. El acceso por clave está deshabilitado y se fuerza TLS 1.2. La aplicación usa OAuth REST con `ShareTokenIntent.Backup`; el rol lector privilegiado omite permisos ACL de archivos y permite lectura en el ámbito asignado.
- **Escalado/costos:** las réplicas están limitadas entre 1 y 3; Log Analytics retiene 30 días. Revisar consumo y costos de SQL, ACR, logs y Container Apps en la suscripción.
- **TLS:** el ingress de Container Apps sirve HTTPS. No publicar la API con HTTP sin protección.

## Permisos SQL para la identidad de la aplicación

Una vez desplegada la infraestructura, inicia sesión en la base con el administrador de Microsoft Entra configurado en Terraform. Obtén el nombre de la identidad con `terraform -chdir=terraform output -raw identity_name` y úsalo para ejecutar:

```sql
CREATE USER [<nombre-de-la-identidad>] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [<nombre-de-la-identidad>];
```

Concede únicamente los permisos requeridos. Si se necesitan escrituras, crea un rol mínimo específico en lugar de asignar `db_owner`.
