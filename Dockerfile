#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Base image
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine AS base
WORKDIR /app
EXPOSE 8080

ENV ASPNETCORE_URLS=http://*:8080
ENV COMPlus_EnableDiagnostics=0

# Build image
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["DemoApp.csproj", "."]
RUN dotnet restore
COPY . .
RUN dotnet build DemoApp.csproj -c Release -o /app/build

# Publish image
FROM build AS publish
RUN dotnet publish DemoApp.csproj -c Release -o /app/publish

# Final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .


# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the ownership and permissions of the working directory
RUN chown -R appuser:appgroup /app && chmod -R 755 /app

# Switch to the non-root user
USER appuser

ENTRYPOINT ["dotnet", "DemoApp.dll"]
