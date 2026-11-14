using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Storage.Files.Shares;
using Azure.Storage.Files.Shares.Models;
using Microsoft.Data.SqlClient;
using System.Data;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    var vaultUri = configuration["KEY_VAULT_URI"]
        ?? throw new InvalidOperationException("KEY_VAULT_URI is required to access Key Vault.");
    var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
    {
        ManagedIdentityClientId = configuration["AZURE_CLIENT_ID"]
    });
    return new SecretClient(new Uri(vaultUri), credential);
});
builder.Services.AddSingleton(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    var fileEndpoint = configuration["STORAGE_FILE_ENDPOINT"]
        ?? throw new InvalidOperationException("STORAGE_FILE_ENDPOINT is required to access Azure Files.");
    var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
    {
        ManagedIdentityClientId = configuration["AZURE_CLIENT_ID"]
    });
    return new ShareServiceClient(
        new Uri(fileEndpoint),
        credential,
        new ShareClientOptions { ShareTokenIntent = ShareTokenIntent.Backup });
});

var app = builder.Build();

app.MapGet("/hello", () => Results.Ok(new { message = "Hello from Azure Container Apps!" }));

app.MapGet("/variable", (IConfiguration configuration) =>
{
    var value = configuration["WELCOME_MESSAGE"];
    return string.IsNullOrWhiteSpace(value)
        ? Results.Problem("WELCOME_MESSAGE is not configured.", statusCode: StatusCodes.Status503ServiceUnavailable)
        : Results.Ok(new { name = "WELCOME_MESSAGE", value });
});

app.MapGet("/secreto", async (SecretClient client, IConfiguration configuration, CancellationToken cancellationToken) =>
{
    var secretName = configuration["KEY_VAULT_SECRET_NAME"] ?? "app-message";
    var secret = await client.GetSecretAsync(secretName, cancellationToken: cancellationToken);
    return Results.Ok(new { name = secretName, value = secret.Value.Value });
});

app.MapGet("/imagen", async (ShareServiceClient client, IConfiguration configuration, CancellationToken cancellationToken) =>
{
    var shareName = configuration["FILE_SHARE_NAME"]
        ?? throw new InvalidOperationException("FILE_SHARE_NAME is required.");
    var fileName = configuration["FILE_NAME"]
        ?? throw new InvalidOperationException("FILE_NAME is required.");
    var file = client.GetShareClient(shareName).GetRootDirectoryClient().GetFileClient(fileName);
    var download = await file.DownloadAsync(cancellationToken: cancellationToken);
    return Results.File(
        download.Value.Content,
        download.Value.ContentType ?? "application/octet-stream");
});

app.MapGet("/consulta", async (IConfiguration configuration, CancellationToken cancellationToken) =>
{
    var server = configuration["SQL_SERVER_FQDN"]
        ?? throw new InvalidOperationException("SQL_SERVER_FQDN is required to access Azure SQL.");
    var database = configuration["SQL_DATABASE"]
        ?? throw new InvalidOperationException("SQL_DATABASE is required to access Azure SQL.");
    var clientId = configuration["AZURE_CLIENT_ID"];
    var connectionString = new SqlConnectionStringBuilder
    {
        DataSource = server,
        InitialCatalog = database,
        Encrypt = true,
        TrustServerCertificate = false,
        Authentication = SqlAuthenticationMethod.ActiveDirectoryDefault,
        UserID = clientId ?? string.Empty
    };

    await using var connection = new SqlConnection(connectionString.ConnectionString);
    await connection.OpenAsync(cancellationToken);
    await using var command = connection.CreateCommand();
    command.CommandType = CommandType.Text;
    command.CommandText = "SELECT DB_NAME() AS DatabaseName, SYSUTCDATETIME() AS QueriedAtUtc";
    await using var reader = await command.ExecuteReaderAsync(cancellationToken);
    await reader.ReadAsync(cancellationToken);

    return Results.Ok(new
    {
        database = reader.GetString(0),
        queriedAtUtc = reader.GetDateTime(1)
    });
});

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.Run();
