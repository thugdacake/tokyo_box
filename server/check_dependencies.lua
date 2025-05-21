--[[
    Tokyo Box - Verificação de Dependências
    Versão: 1.0.0
]]

-- Verificar dependências
local function CheckDependencies()
    print("^3[Tokyo Box] Verificando dependências...^7")
    
    -- Verificar recursos obrigatórios
    for _, resource in ipairs(Config.Dependencies.required) do
        local state = GetResourceState(resource)
        if state ~= "started" then
            print("^1[Tokyo Box] Erro: Recurso obrigatório '" .. resource .. "' não está iniciado^7")
            return false
        end
    end
    
    -- Verificar recursos opcionais
    for _, resource in ipairs(Config.Dependencies.optional) do
        local state = GetResourceState(resource)
        if state ~= "started" then
            print("^3[Tokyo Box] Aviso: Recurso opcional '" .. resource .. "' não está iniciado^7")
        end
    end
    
    -- Verificar configuração
    if not Config then
        print("^1[Tokyo Box] Erro: Configuração não encontrada^7")
        return false
    end
    
    -- Verificar chave da API
    if not Config.API.key or Config.API.key == "" then
        print("^1[Tokyo Box] Erro: Chave da API do YouTube não configurada^7")
        return false
    end
    
    print("^2[Tokyo Box] Todas as dependências verificadas com sucesso^7")
    return true
end

-- Executar verificação
CreateThread(function()
    if not CheckDependencies() then
        print("^1[Tokyo Box] Erro: Falha na verificação de dependências. Parando recurso...^7")
        StopResource(GetCurrentResourceName())
        return
    end
end) 