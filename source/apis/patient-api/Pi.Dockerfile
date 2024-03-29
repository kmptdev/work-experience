FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Kmpt.WorkExperience.PatientApi.csproj", "Kmpt.WorkExperience.PatientApi.csproj"]
RUN dotnet restore "Kmpt.WorkExperience.PatientApi.csproj"
COPY . .
RUN dotnet build "Kmpt.WorkExperience.PatientApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Kmpt.WorkExperience.PatientApi.csproj" -c Release -o /app/publish -r linux-arm64 --self-contained

FROM mcr.microsoft.com/dotnet/aspnet:7.0.8-bullseye-slim-arm32v7 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Kmpt.WorkExperience.PatientApi.dll"]
