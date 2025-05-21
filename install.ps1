# Obtém o diretório do script e escapa os colchetes
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = $scriptPath -replace '\[', '``[' -replace '\]', '``]'

# Muda para o diretório do script
try {
    Set-Location -LiteralPath $scriptPath
} catch {
    Write-Host "Erro ao mudar para o diretório: $scriptPath"
    Write-Host "Tentando método alternativo..."
    
    # Método alternativo usando cd
    $currentDir = Get-Location
    Write-Host "Diretório atual: $currentDir"
    
    # Verifica se estamos no diretório correto
    if (-not (Test-Path "package.json")) {
        Write-Host "Erro: package.json não encontrado."
        Write-Host "Por favor, certifique-se de que você está no diretório correto do projeto."
        Write-Host "O arquivo package.json deve estar neste diretório."
        exit 1
    }
}

# Verifica se o package.json existe
if (-not (Test-Path "package.json")) {
    Write-Host "Erro: package.json não encontrado no diretório atual."
    Write-Host "Diretório atual: $(Get-Location)"
    Write-Host "Por favor, execute este script no diretório raiz do projeto."
    exit 1
}

# Verifica se o pnpm está instalado
if (!(Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando pnpm..."
    npm install -g pnpm
}

# Verifica se o Node.js está instalado
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js não encontrado. Por favor, instale o Node.js 18 ou superior."
    Write-Host "Download: https://nodejs.org/"
    exit 1
}

# Verifica a versão do Node.js
$nodeVersion = (node -v).Substring(1)
$requiredVersion = "18.0.0"
if ([version]$nodeVersion -lt [version]$requiredVersion) {
    Write-Host "Node.js versão $nodeVersion encontrada. Versão $requiredVersion ou superior é necessária."
    Write-Host "Por favor, atualize o Node.js: https://nodejs.org/"
    exit 1
}

Write-Host "Diretório atual: $(Get-Location)"
Write-Host "Instalando dependências..."
pnpm install

Write-Host "Construindo o projeto..."
pnpm build

Write-Host "Iniciando o servidor..."
pnpm start 