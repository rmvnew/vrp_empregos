local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_empregos",src)
vCLIENT = Tunnel.getInterface("vrp_empregos")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECAR PLACA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkPlate()
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if identity then
        return identity.registro
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTOS EMPREGOS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local minerios = {
    [1] = { "bronze", math.random(2,5) },
    [2] = { "ferro", math.random(2,5) },
    [3] = { "ouro", math.random(2,4) },
    [4] = { "diamante", math.random(2,4) },
    [5] = { "rubi", math.random(1,3) },
    [6] = { "safira", math.random(1,3) }
}

local peixes = {
    [1] = { "pacu" },
    [2] = { "tilapia" },
    [3] = { "salmao" },
    [4] = { "tucunare" },
    [5] = { "dourado" }
}
local cooldown = {}
function src.payment(tipo, quantidade, selecionado, mode)
    local source = source
    local user_id = vRP.getUserId(source)

    if tipo == "Taxista" then
        if cooldown[user_id] then
            if (cooldown[user_id] - os.time()) > 0 then
                DropPlayer(source, "Opaa, Até mais :)")
                vRP.sendLog("", "```prolog\n[FLOW]\n[TAXISTA][USER_ID]: "..user_id.."\n[EMPREGO]: "..tipo.."\n[CDS ATUAL]: "..GetEntityCoords(GetPlayerPed(source)).."```")
            
                return
            end
        end

        cooldown[user_id] = os.time() + 10
    end
    
    if tipo ~= "Lixeiro" or tipo ~= "Graos" then
        if selecionado == nil or not cfg.config[tipo] then
            if GetPlayerPed(source) > 0 then
                --vRP.setBanned(user_id, true)
                DropPlayer(source, "Opaa, Até mais :)")
                vRP.sendLog("", "```prolog\n[FLOW]\n[USER_ID]: "..user_id.."\n[EMPREGO]: "..tipo.."\n[CDS ATUAL]: "..GetEntityCoords(GetPlayerPed(source)).."```")
            end
            return
        end

        if not cfg.config[tipo].rotas[selecionado] then
            if GetPlayerPed(source) > 0 then
                --vRP.setBanned(user_id, true)
                DropPlayer(source, "Opaa, Até mais :)")
                vRP.sendLog("", "```prolog\n[FLOW]\n[USER_ID]: "..user_id.."\n[EMPREGO]: "..tipo.."\n[CDS ATUAL]: "..GetEntityCoords(GetPlayerPed(source)).."```")
            end
            return
        end

        if cfg.config[tipo].rotas[selecionado] then
            local distance = #(GetEntityCoords(GetPlayerPed(source)) - cfg.config[tipo].rotas[selecionado].coords)
            if distance >= 500 then
                if GetPlayerPed(source) > 0 then
                    --vRP.setBanned(user_id, true)
                    DropPlayer(source, "Opaa, Até mais :)")
                    vRP.sendLog("", "```prolog\n[FLOW]\n[USER_ID]: "..user_id.."\n[EMPREGO]: "..tipo.."\n[CDS ATUAL]: "..GetEntityCoords(GetPlayerPed(source)).."\n[CDS DA ROTA]: "..cfg.config[tipo].rotas[selecionado].coords.."\n[DISTANCIA]: "..distance.."```")
                end
                return
            end
        end
    end


    if user_id then
        local status, time = exports['vrp']:getCooldown(user_id, "empregos")
        if GetPlayerPing(source) > 0 and status then
            exports['vrp']:setCooldown(user_id, "empregos", 3)
            
            if tipo == "Lixeiro" then
                 local nuser_id = {}
                 local valor = cfg.config[tipo].price
                 local count = 1
                 local nplayers = vRPclient.getNearestPlayers(source, 8)

                 for k,v in pairs(nplayers) do
                     if vCLIENT.checkInServico(parseInt(k)) == tipo  then
                         nuser_id[vRP.getUserId(parseInt(k))] = true
                         count = count + 1
                     else
                         TriggerClientEvent("Notify",parseInt(k),"negado","Você não recebeu pois não esta em serviço.",5)
                     end
                 end

                 if count > 1 then
                     valor = valor/count

                     for k,v in pairs(nuser_id) do
                        --  vRP.giveMoney(parseInt(k), parseInt(valor))
                        vRP.giveInventoryItem(parseInt(k), "money", parseInt(valor), true)
                        TriggerClientEvent("vrp_empregos:cash",source)
                    end
                    
                    --  vRP.giveMoney(user_id, parseInt(valor))
                    vRP.giveInventoryItem(user_id, "money", parseInt(valor), true)
                    TriggerClientEvent("vrp_empregos:cash",source)
                else
                    --  vRP.giveMoney(user_id, parseInt(valor))
                    vRP.giveInventoryItem(user_id, "money", parseInt(valor), true)
                    TriggerClientEvent("vrp_empregos:cash",source)
                 end

            elseif tipo == "Motorista" then
                local nuser_id = {}
                local valor = cfg.config[tipo].price
                local count = 1
                local nplayers = vRPclient.getNearestPlayers(source, 8)
                for k,v in pairs(nplayers) do
                    if vCLIENT.checkInServico(parseInt(k)) == tipo then
                        nuser_id[vRP.getUserId(parseInt(k))] = true
                        count = count + 1
                    else
                        TriggerClientEvent("Notify",parseInt(k),"negado","Você não recebeu pois não esta em serviço.",5)
                    end
                end

                if count > 1 then
                    valor = valor/count

                    for k,v in pairs(nuser_id) do
                        vRP.giveInventoryItem(parseInt(k), "money", parseInt(valor), true)
                    end

                    vRP.giveInventoryItem(user_id, "money", parseInt(valor), true)
                else
                    vRP.giveInventoryItem(user_id, "money", parseInt(valor), true)
                end
            elseif tipo == "Taxista" then
                local nuser_id = {}
                local valor = cfg.config[tipo].price
                local count = 1
                local nplayers = vRPclient.getNearestPlayers(source, 8)
                for k,v in pairs(nplayers) do
                    if vCLIENT.checkInServico(parseInt(k)) == tipo then
                        nuser_id[vRP.getUserId(parseInt(k))] = true
                        count = count + 1
                    else
                        TriggerClientEvent("Notify",parseInt(k),"negado","Você não recebeu pois não esta em serviço.",5)
                    end
                end

                if count > 1 then
                    valor = valor/count

                    for k,v in pairs(nuser_id) do
                        vRP.giveInventoryItem(parseInt(k), "money", parseInt(valor), true)
                    end

                    vRP.giveInventoryItem(user_id, "money", parseInt(valor), true)
                else
                    vRP.giveInventoryItem(user_id, "money", parseInt(valor), true)
                end

            elseif tipo == "Drogas" then
                local plyCoords = GetEntityCoords(GetPlayerPed(source))
                local x,y,z = plyCoords[1],plyCoords[2],plyCoords[3]
                local policia = vRP.getUsersByPermission("perm.countpolicia")
                local valorPolicial = cfg.config[tipo].valorPorPolicia*#policia
                local chance = math.random(100)

                if mode == 1 then
                    if chance >= 75 then
                        exports['vrp']:alertPolice({ x = x, y = y, z = z, blipID = 161, blipColor = 63, blipScale = 0.5, time = 20, code = "911", title = "Vende de Drogas", name = "Um novo registro de vendas de drogas vá até o local no mapa."})
                    end

                    if vRP.tryGetInventoryItem(user_id, "maconha", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "cocaina", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "lsd", quantidade, true) then
                        local value = 2000
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "lancaperfume", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "balinha", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "heroina", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "metanfetamina", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "opio", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    elseif vRP.tryGetInventoryItem(user_id, "haxixe", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                        return true
                    else
                        TriggerClientEvent("Notify",source,"negado","Você não possui a quantia de <b>"..quantidade.." x</b> drogas.", 5)
                        return false
                    end
                else
                    if chance >= 25 then
                        exports['vrp']:alertPolice({ x = x, y = y, z = z, blipID = 161, blipColor = 63, blipScale = 0.5, time = 20, code = "911", title = "Vende de Drogas", name = "Um novo registro de vendas de drogas vá até o local no mapa."})
                    end

                    if vRP.tryGetInventoryItem(user_id, "maconha", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "cocaina", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "lsd", quantidade, true) then
                        local value = 2000+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "lancaperfume", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "balinha", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end
                    
                    if vRP.tryGetInventoryItem(user_id, "heroina", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "metanfetamina", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "opio", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    if vRP.tryGetInventoryItem(user_id, "haxixe", quantidade, true) then
                        local value = cfg.config[tipo].valorPorDroga+400
                        vRP.giveInventoryItem(user_id, "dirty_money", value*quantidade+valorPolicial, true)
                    end

                    return true
                end

            elseif tipo == "Minerador" then
                if vRP.computeInvWeight(user_id)+vRP.getItemWeight(minerios[quantidade][1]) <= vRP.getInventoryMaxWeight(user_id) then
                    vRP.giveInventoryItem(user_id, minerios[quantidade][1], minerios[quantidade][2], true)
                else
                    TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
                end
            elseif tipo == "Graos" then
                if vRP.computeInvWeight(user_id)+vRP.getItemWeight("graosimpuros") <= vRP.getInventoryMaxWeight(user_id) then
                    vRP.giveInventoryItem(user_id, "graosimpuros", math.random(1,3), true)
                else
                    TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
                end

                
            elseif tipo == "Entregador" then
                local caixas = math.random(1,4)
                if vRP.tryGetInventoryItem(user_id, "caixa", caixas, true)then
                    vRP.giveInventoryItem(user_id, "money", parseInt(cfg.config[tipo].price) * caixas, true)
                    return true
                else
                    TriggerClientEvent("Notify",source,"negado","Você não possui caixas.", 5)
                end
                
            elseif tipo == "Lenhador" then
                if vRP.computeInvWeight(user_id)+vRP.getItemWeight("madeira") <= vRP.getInventoryMaxWeight(user_id) then
                    vRP.giveInventoryItem(user_id, "madeira", 1, true)
                    return true
                else
                    TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
                end
            elseif tipo == "Pescador" then
                if vRP.computeInvWeight(user_id)+vRP.getItemWeight(peixes[quantidade][1]) <= vRP.getInventoryMaxWeight(user_id) then
                    vRP.giveInventoryItem(user_id, peixes[quantidade][1], 1, true)
                else
                    TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
                end
            elseif tipo == "Tartaruga" then
                if vRP.computeInvWeight(user_id)+vRP.getItemWeight("tartaruga") <= vRP.getInventoryMaxWeight(user_id) then
                    vRP.giveInventoryItem(user_id, "tartaruga", 1, true)
                else
                    TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
                end
            end

            return false
        else
			TriggerClientEvent( "Notify", source, "negado", "CALMA AI, ESPERE UM POUCO PARA FARMAR | TEMPO:"..time.."!", 5)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTREGADOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.giveCaixas(quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.computeInvWeight(user_id)+vRP.getItemWeight("caixa")*quantidade <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id, "caixa", quantidade, true)
        else
            TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PESCADOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.tryIsca()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.tryGetInventoryItem(user_id, "isca", 1, true) then
            return true
        else
            TriggerClientEvent("Notify",source,"negado","Acabou suas iscas, volte a central e busque mais.", 5)
        end
    end
end

function src.giveIsca(quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.computeInvWeight(user_id)+vRP.getItemWeight("isca")*quantidade <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id, "isca", quantidade, true)
        else
            TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
        end
    end
end