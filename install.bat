@echo off
echo Iniciando instalacao do Tokyo Box UI...

:: Verifica se o PowerShell está disponível
powershell -Command "exit" 2>nul
if %errorlevel% neq 0 (
    echo PowerShell nao encontrado. Por favor, instale o PowerShell.
    pause
    exit /b 1
)

:: Obtém o diretório atual
set "CURRENT_DIR=%~dp0"

:: Executa o script PowerShell com bypass de política de execução e diretório correto
powershell -ExecutionPolicy Bypass -Command "& {Set-Location -LiteralPath '%CURRENT_DIR%'; & '%CURRENT_DIR%install.ps1'}"

:: Se houver erro, aguarda antes de fechar
if %errorlevel% neq 0 (
    echo.
    echo Ocorreu um erro durante a instalacao.
    echo.
    echo Se o erro estiver relacionado ao diretorio, tente:
    echo 1. Abrir o PowerShell como administrador
    echo 2. Navegar ate a pasta do projeto
    echo 3. Executar: Set-ExecutionPolicy Bypass -Scope Process -Force
    echo 4. Executar: .\install.ps1
    pause
) 