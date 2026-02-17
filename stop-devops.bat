@echo off
echo ========================================
echo Stopping tpFoyer DevOps Services
echo ========================================
echo.

docker-compose down

echo.
echo [SUCCESS] All services stopped!
echo.
echo To remove all data volumes, run:
echo docker-compose down -v
echo.

pause
