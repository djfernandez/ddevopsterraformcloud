FROM scratch AS published
COPY publish/ /app/

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080 \
    DOTNET_EnableDiagnostics=0
EXPOSE 8080
USER $APP_UID
COPY --from=published /app/ .
ENTRYPOINT ["dotnet", "AzureContainerApps.Api.dll"]
