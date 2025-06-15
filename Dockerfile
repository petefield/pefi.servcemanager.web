# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy just the project file and restore
COPY ["src/pefi.servicemanager.web.csproj", "."]

RUN  dotnet nuget add source \
        --username petefield  \
        # --password \
        --store-password-in-clear-text \
        --name petefield "https://nuget.pkg.github.com/petefield/index.json" 

RUN dotnet restore "pefi.servicemanager.web.csproj"

# Copy everything else and build
COPY ./src .
RUN dotnet build "pefi.servicemanager.web.csproj" 

RUN dotnet publish "pefi.servicemanager.web.csproj" -c Release -o /app/publish

# Stage 2: Serve
FROM nginx:alpine
WORKDIR /var/www/web
COPY --from=build /app/publish/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80