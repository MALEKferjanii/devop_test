@echo off
echo ========================================
echo tpFoyer DevOps Pipeline Setup
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [INFO] Docker is running...
echo.

REM Start all services
echo [STEP 1] Starting all DevOps services...
echo This includes: Jenkins, SonarQube, Nexus, MySQL, Docker Registry
docker-compose up -d

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start services
    pause
    exit /b 1
)

echo.
echo [SUCCESS] All services started!
echo.

REM Wait for services to be ready
echo [STEP 2] Waiting for services to be ready (60 seconds)...
timeout /t 60 /nobreak >nul

echo.
echo ========================================
echo Service URLs:
echo ========================================
echo Jenkins:         http://localhost:8080
echo SonarQube:       http://localhost:9000
echo Nexus:          http://localhost:8081
echo Docker Registry: http://localhost:5000
echo Application:     http://localhost:8082/tpFoyer17
echo ========================================
echo.

REM Get Jenkins initial password
echo [INFO] Getting Jenkins initial admin password...
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>nul
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Copy this password to login to Jenkins!
) else (
    echo [WARNING] Jenkins password not ready yet. Try: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
)

echo.
echo [INFO] Getting Nexus initial admin password...
timeout /t 10 /nobreak >nul
docker exec nexus cat /nexus-data/admin.password 2>nul
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Copy this password to login to Nexus!
) else (
    echo [WARNING] Nexus password not ready yet. Try later: docker exec nexus cat /nexus-data/admin.password
)

echo.
echo ========================================
echo Next Steps:
echo ========================================
echo 1. Configure Jenkins at http://localhost:8080
echo 2. Configure SonarQube at http://localhost:9000 (admin/admin)
echo 3. Configure Nexus at http://localhost:8081
echo 4. Read DEVOPS_SETUP.md for detailed instructions
echo ========================================
echo.

pause
