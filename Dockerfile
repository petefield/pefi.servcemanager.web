# Stage 1: Build
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy just the project file and restore
COPY ["src/pefi.servicemanager.web.csproj", "."]


# COPY the ZscalerRootCertificate if it exists in the build context.
COPY ["Zscaler Root CA.*", "ZscalerRootCertificate.crt"] 
# If the cert does exist, install in it, so that Nuget can use it
RUN if [ -f "ZscalerRootCertificate.crt" ]; then cp ZscalerRootCertificate.crt /usr/local/share/ca-certificates/ && update-ca-certificates --fresh ; fi

RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN dotnet nuget add source --username petefield --password $GITHUB_TOKEN --store-password-in-clear-text --name petefield "https://nuget.pkg.github.com/petefield/index.json"


RUN dotnet restore "pefi.servicemanager.web.csproj"

# Copy everything else and build
COPY ./src .

RUN dotnet publish "pefi.servicemanager.web.csproj"  -c Release -o /app/publish

# Stage 2: Serve
FROM nginx:alpine
WORKDIR /var/www/web
COPY --from=build /app/publish/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80