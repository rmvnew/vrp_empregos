local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_empregos",src)
vCLIENT = Tunnel.getInterface("vrp_empregos")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0
local coletando = false
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local caminhoneiro = {
	["Caminhoneiro"] = {
		iniciar = vec3(-615.38,-1787.23,23.69),
		pegarcaminhao2 = vec3(-613.85,-1794.4,23.67),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)
		
		for k,v in pairs(caminhoneiro) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 7.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"[~b~E~w~] PARA ENTRAR EM SERVIÇO.")
					DrawMarker(
                                27,
                                v.iniciar[1],
                                v.iniciar[2],
                                v.iniciar[3] - 0.8,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1.5,
                                1.5,
                                1.5,
                                132,
                                102,
                                226,
                                180,
                                0,
                                0,
                                0,
                                1
                            )

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						zonas = carregarZonas("Lixeiro", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao2)
				if distance2 <= 5.0 then
					time = 5
					DrawText3Ds(v.pegarcaminhao2[1],v.pegarcaminhao2[2],v.pegarcaminhao2[3]-0.1,"[~b~E~w~] PARA PEGAR O CAMINHÃO.")
					DrawMarker(
						27,
						v.pegarcaminhao2[1],
						v.pegarcaminhao2[2],
						v.pegarcaminhao2[3] - 0.8,
						0,
						0,
						0,
						0,
						0,
						0,
						1.5,
						1.5,
						1.5,
						132,
						102,
						226,
						180,
						0,
						0,
						0,
						1
					)
					if IsControlJustReleased(1, 51) and segundos <= 0 then
					TriggerEvent("Notify","importante","Aguarde o caminhão na rua", 5)
					segundos = 2
					criarVehicle(-616.93,-1806.02,23.64,245.73,"trash2",false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE LIXO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		
		if servico then
			local ped = PlayerPedId()
			local playercoords = GetEntityCoords(ped)

			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 15.0 and v.visivel then
					time = 5
					DrawMarker(21,v.coords[1],v.coords[2],v.coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

					if distance <= 1.5 and not IsPedInAnyVehicle(PlayerPedId()) then
						if IsControlJustReleased(1, 51) and segundos <= 0 and not coletando then
							segundos = 3
							zonas[k] = { coords = zonas[k].coords, visivel = false }
							removeToBlip(k)
							animLixo(true)

							SetTimeout(5000, function()
								if coletando then
									animLixo(false)
								end
							end)
						end
					end
				end
			end

			local veh = getVehicleRadius(10)
			if veh then
				local model = GetEntityModel(veh)
				local coordsVehicle = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.7, 0.0)

				if model == -1255698084 and segundos <= 0 then
					local distance = #(playercoords - coordsVehicle)
					if distance <= 5 then
						time = 5
						if IsControlJustReleased(1, 51) and not IsPedInAnyVehicle(PlayerPedId()) and segundos <= 0 and coletando then
							coletando = false
							segundos = 10
							
							SetVehicleDoorOpen(veh,5,0,0)
							vRP.playAnim(true,{{"mp_common","givetake1_a"}},false)

							Wait(1500)
							animLixo(false)
							payment("Lixeiro", 0, 1)

							Wait(1000)
							SetVehicleDoorShut(veh,5,0)
						end
					end
				end
			end

		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ANIM PEGAR LIXO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local prop = 0

function animLixo(status)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	if status then
		prop = CreateObject(600967813, x + 5.5, y + 5.5, z + 0.2, true, true, true)
		AttachEntityToEntity(prop, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 0x6F06), 0.00, 0.0, -0.7, 0.0, 0.0, 0.0, true, true, false, true, 1, true )
		RequestAnimDict("missfbi4prepp1")
		while not HasAnimDictLoaded("missfbi4prepp1") do
			Wait(0)
		end
		TaskPlayAnim(GetPlayerPed(-1), "missfbi4prepp1", "_bag_walk_garbage_man", 8.0, -8, -1, 49, 0, 0, 0, 0)
		Wait(500)
		coletando = true
	else
		vRP.DeletarObjeto()
		DetachEntity(prop, true, false)
		SetEntityCoords(prop, 0.0, 0.0, 0.0, false, false, false, true)
		coletando = false
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nCOLETOS OS ~y~LIXOS~w~ PELA CIDADE.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				servico = false
				coletando = false
				sairServico()
				deletarVehicle()
				removeBlips()
			end
		end
		
		Citizen.Wait(time)
	end
end)

Citizen.CreateThread(function()
	while true do
		local time = 1000
		if segundos >= 0 then
			segundos = segundos - 1

			if segundos <= 0 then
				segundos = 0
			end
		end
		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function getVehicleRadius(radius)
	local veh
	local vehs = getVehiclesRadius(radius)
	local min = radius+0.0001
	for _veh,dist in pairs(vehs) do
		if dist < min then
			min = dist
			veh = _veh
		end
	end
	return veh
end

function getVehiclesRadius(radius)
	local r = {}
	local px,py,pz = table.unpack(GetEntityCoords(PlayerPedId()))

	local vehs = {}
	local it,veh = FindFirstVehicle()
	if veh then
		table.insert(vehs,veh)
	end
	local ok
	repeat
		ok,veh = FindNextVehicle(it)
		if ok and veh then
			table.insert(vehs,veh)
		end
	until not ok
	EndFindVehicle(it)

	for _,veh in pairs(vehs) do
		local x,y,z = table.unpack(GetEntityCoords(veh,true))
		local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
		if distance <= radius then
			r[veh] = distance
		end
	end
	return r
end


RegisterNetEvent("vrp_empregos:cash")
AddEventHandler("vrp_empregos:cash",function (source)
	

    PlaySoundFrontend(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET", true)

end)

local pedlist = {
	{ ['x'] = -615.34, ['y'] = -1787.39, ['z'] = 23.69, ['h'] = 212.64, ['hash'] = 0x14D7B4E0, ['hash2'] = "s_m_m_dockwork_01" }
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