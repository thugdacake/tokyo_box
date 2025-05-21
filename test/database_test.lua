--[[
    Tokyo Box - Testes do Banco de Dados
    Versão 1.0.3
]]

local helper = require("test.test_helper")
local describe = describe
local it = it
local before_each = before_each
local after_each = after_each
local assert = assert

describe("Sistema de Banco de Dados", function()
    local Database = require('server/database')
    
    before_each(function()
        -- Mock para oxmysql
        _G.oxmysql = {
            query_async = function(query, params)
                return {
                    affectedRows = 1,
                    insertId = 1,
                    status = "success"
                }
            end,
            
            execute_async = function(query, params)
                return {
                    affectedRows = 1,
                    status = "success"
                }
            end
        }
    end)
    
    after_each(function()
        -- Limpar mocks após cada teste
        helper.cleanupMocks()
    end)
    
    describe("Criação de Tabelas", function()
        it("deve criar tabelas com sucesso", function()
            local result = Database.CreateTables()
            assert.is_true(result)
        end)
        
        it("deve lidar com erros do banco", function()
            -- Simula erro no banco
            _G.oxmysql.query_async = function()
                return nil, "Database error"
            end
            
            local result = Database.CreateTables()
            assert.is_false(result)
        end)
    end)
    
    describe("Verificação de Integridade", function()
        it("deve verificar se tabelas existem", function()
            local result = Database.VerifyIntegrity()
            assert.is_true(result)
        end)
        
        it("deve detectar tabelas faltando", function()
            -- Simula tabela faltando
            _G.oxmysql.query_async = function()
                return {}
            end
            
            local result = Database.VerifyIntegrity()
            assert.is_false(result)
        end)
    end)
    
    describe("Operações de Playlist", function()
        it("deve criar playlist", function()
            local playlistData = {
                name = "Test Playlist",
                created_by = "ABC123"
            }
            
            local result = Database.CreatePlaylist(playlistData)
            assert.is_true(result.success)
            assert.is_not_nil(result.playlistId)
        end)
        
        it("deve deletar playlist", function()
            local result = Database.DeletePlaylist(1, "ABC123")
            assert.is_true(result.success)
        end)
        
        it("deve adicionar música à playlist", function()
            local trackData = {
                playlist_id = 1,
                video_id = "test_video",
                title = "Test Track",
                duration = "3:30"
            }
            
            local result = Database.AddTrackToPlaylist(trackData)
            assert.is_true(result.success)
        end)
    end)
    
    describe("Operações de Favoritos", function()
        it("deve adicionar favorito", function()
            local favoriteData = {
                player_id = "ABC123",
                video_id = "test_video",
                title = "Test Video"
            }
            
            local result = Database.AddFavorite(favoriteData)
            assert.is_true(result.success)
        end)
        
        it("deve remover favorito", function()
            local result = Database.RemoveFavorite(1, "ABC123")
            assert.is_true(result.success)
        end)
        
        it("deve obter favoritos", function()
            local result = Database.GetFavoritesByPlayer("ABC123")
            assert.is_table(result)
            assert.is_true(#result > 0)
        end)
    end)
end) 