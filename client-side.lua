local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_empregos",src)
vSERVER = Tunnel.getInterface("vrp_empregos")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local zonas = {}
local blips = {}
local namedServico = nil
local veiculoS = 0
local veiculoS2 = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECAR EM SERVICO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function checkInService()
	if namedServico == nil then
		return true
	else
		TriggerEvent("Notify","importante","Você precisa sair do serviço atual para iniciar outro.", 5)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CARREGAR ZONAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function carregarZonas(tipo,blip)
    if cfg.config[tipo] then
        zonas = cfg.config[tipo].rotas
		namedServico = tipo

		for k,v in pairs(zonas) do
			zonas[k] = { coords = v.coords, visivel = true }
		end

        if blip then
            for k,v in pairs(zonas) do
				if v.visivel then
					blips[k] = AddBlipForCoord(v.coords[1],v.coords[2],v.coords[3])
					SetBlipSprite(blips[k], 1)
					SetBlipAsShortRange(blips[k] ,true)
					SetBlipColour(blips[k] ,5)
					SetBlipScale(blips[k], 0.3)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString("Coleta")
					EndTextCommandSetBlipName(blips[k])
				end
            end
        end
		

        return zonas
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- REMOVER BLIPS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function removeBlips()
	if #blips > 0 then
		local i = 0
		while i <= #blips do
			RemoveBlip(blips[i])
			i = i + 1
		end
	end
end

function removeToBlip(id)
	if blips[id] then
		RemoveBlip(blips[id])
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CRIAR VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local veiculoAtual
function criarVehicle(x,y,z,h,veiculo, extra)
	-- local checkPos = GetClosestVehicle(x,y,z,3.001,0,71)
	if veiculoAtual and DoesEntityExist(veiculoAtual) then
		-- TriggerEvent("Notify","importante","Todas as vagas estão ocupadas no momento.", 5)
		TriggerEvent("Notify", "importante", "Você já possui um veículo ativo.", 5)
		return false
	else
		if veiculo then
			local mhash = GetHashKey(veiculo)
			while not HasModelLoaded(mhash) do
				RequestModel(mhash)
				Citizen.Wait(10)
			end

			if HasModelLoaded(mhash) then
				local nveh = CreateVehicle(mhash,x,y,z,h,true,false)

				SetVehicleOnGroundProperly(nveh)
				SetVehicleNumberPlateText(nveh, vSERVER.checkPlate())
				SetEntityAsMissionEntity(nveh,true,true)
				SetModelAsNoLongerNeeded(mhash)

				if extra then
					veiculoS2 = nveh
				else
					veiculoS = nveh
				end
				veiculoAtual = nveh
				return nveh
			end
		end
	end
	return false
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETAR VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function deletarVehicle()
	if veiculoS > 0 then
		TriggerServerEvent("bm_module:deleteVehicles", VehToNet(veiculoS))
		veiculoS = 0
	end

	if veiculoS2 > 0 then
		TriggerServerEvent("bm_module:deleteVehicles", VehToNet(veiculoS2))
		veiculoS2 = 0
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SAIR DE SERVICO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function sairServico()
	namedServico = nil
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTOS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkInServico()
	return namedServico
end

function payment(tipo, quantidade, selecionado, mode)
	return vSERVER.payment(tipo, quantidade, selecionado, mode)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTRAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,x,y)
	local res_x, res_y = GetActiveScreenResolution()

	SetTextFont(4)
	SetTextScale(0.3,0.3)
	SetTextColour(255,255,255,255)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)

	if res_x >= 2000 then
		DrawText(x+0.076,y)
	else
		DrawText(x,y)
	end
end

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,255)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text))/370
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,150)
end


local pedlist = {
	{ ['x'] = -615.34, ['y'] = -1787.39, ['z'] = 23.69, ['h'] = 212.64, ['hash'] = 0x14D7B4E0, ['hash2'] = "s_m_m_dockwork_01" },
	{ ['x'] = 71.11, ['y'] = 108.36, ['z'] = 79.19, ['h'] = 340.38, ['hash'] = 0x1A021B83, ['hash2'] = "s_m_m_cntrybar_01" },
	{ ['x'] = 751.93, ['y'] = 6458.95, ['z'] = 31.53, ['h'] = 57.62, ['hash'] = 0x2DC6D3E7, ['hash2'] = "ig_oneil" },
	{ ['x'] = -841.72, ['y'] = 5401.01, ['z'] = 34.61, ['h'] = 299.15, ['hash'] = 0x0DE9A30A, ['hash2'] = "s_m_m_ammucountry" },
}

 

CreateThread(function()
	for k,v in pairs(pedlist) do
	 RequestModel(GetHashKey(v.hash2))
	 while not HasModelLoaded(GetHashKey(v.hash2)) do Wait(100) end
	 ped = CreatePed(4,v.hash,v.x,v.y,v.z-1,v.h,false,true)
	 peds = ped
	 FreezeEntityPosition(ped,true)
	 SetEntityInvincible(ped,true)
	 SetBlockingOfNonTemporaryEvents(ped,true)
	end
   end)




function alert()
	TriggerClientEvent("Notify",source,"importante","Você precisa de um machado para essa atividade!",10)
end