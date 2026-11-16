# Operación y seguridad

- **Identidad:** la Container App usa una identidad administrada asignada por el usuario. Terraform asigna `AcrPull`, `Key Vault Secrets User` y `Storage File Data Privileged Reader` en sus respectivos ámbitos. El principal que ejecuta Terraform recibe `Storage File Data Privileged Contributor` en el file share para cargar la imagen.
- **Secretos:** el secreto de demostración se carga en Key Vault fuera de Terraform para no persistir su valor en el estado. No guardar secretos en el repositorio ni en `terraform.tfvars`.
- **Estado de Terraform:** proteger el estado local o configurar un backend remoto con cifrado, RBAC y versionado antes de usar Terraform en un entorno compartido.
- **SQL:** Terraform no aprovisiona SQL. `/consulta` requiere un servidor y una base externos, configurados en la Container App con `SQL_SERVER_FQDN` y `SQL_DATABASE`; concede a la identidad de la aplicación solo los permisos necesarios en esa base.
- **ACR:** el registro deshabilita la cuenta de administrador. El desarrollador que publica necesita `AcrPush`; la Container App solo obtiene `AcrPull`.
- **Storage:** `sample.svg` se almacena en un file share privado de Azure Files. El acceso por clave está deshabilitado y se fuerza TLS 1.2. La aplicación usa OAuth REST con `ShareTokenIntent.Backup`; el rol lector privilegiado omite permisos ACL de archivos y permite lectura en el ámbito asignado.
- **Escalado/costos:** las réplicas están limitadas entre 1 y 3; Log Analytics retiene 30 días. Revisar consumo y costos de SQL, ACR, logs y Container Apps en la suscripción.
- **TLS:** el ingress de Container Apps sirve HTTPS. No publicar la API con HTTP sin protección.
