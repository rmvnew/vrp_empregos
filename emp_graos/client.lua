------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0
local coletando = false

local blips = {}
local selecionado = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local graos = {
	["Graos"] = {
		iniciar = vec3(751.76,6459.06,31.53),
		pegarcaminhao = vec3(748.89,6454.23,31.97),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)
		
		for k, v in pairs(graos) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1], v.iniciar[2], v.iniciar[3] - 0.1, "[~b~E~w~] PARA ENTRAR EM SERVIÇO.")
		
					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 2
						servico = true
						zonas = carregarZonas("Graos", false)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarcaminhao[1], v.pegarcaminhao[2], v.pegarcaminhao[3] - 0.1, "[~b~E~w~] PARA PEGAR O CAMINHÃO.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 2
						criarVehicle(742.94, 6454.68, 31.89, 89.105, "tractor2", false)
		
						selecionado = 1
						CriandoBlipGraos(selecionado)
		
						-- Remover o texto do maker somente se for igual ao do segundo DrawText3Ds
						if v.pegarcaminhao[1] == 742.94 and v.pegarcaminhao[2] == 6454.68 and v.pegarcaminhao[3] == 31.79 then
							RemoveText3Ds(v.pegarcaminhao[1], v.pegarcaminhao[2], v.pegarcaminhao[3] - 0.1)
						end
					end
				end
			end
		end
		

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE GRãOS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		
		if servico then
			local ped = PlayerPedId()
			local playercoords = GetEntityCoords(ped)

			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 15.0 and v.visivel and IsPedInAnyVehicle(PlayerPedId()) then
					time = 5
					DrawMarker(21,zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 255,201,0, 180 ,1,0,0,1)

					if distance <= 1.5 then
						if IsControlJustReleased(1, 51) and segundos <= 0 and not coletando then
							segundos = 3

							local vehicle = GetPlayersLastVehicle()
							if IsVehicleModel(vehicle,GetHashKey("tractor2")) then
								TriggerEvent("progress", 2)
								--SetVehicleUndriveable(vehicle, true)
								SetTimeout(10*100, function()
									--SetVehicleUndriveable(vehicle, false)
									payment("Graos", 0, selecionado)						
									selecionado = math.random(#zonas)
									RemoveBlip(blips)
									CriandoBlipGraos(selecionado)
								end)
							end
						end
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nCOLETOS OS ~y~GRAOS~w~ PELA HORTA.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				servico = false
				coletando = false
				sairServico()
				deletarVehicle()
				RemoveBlip(blips)
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
function CriandoBlipGraos(selecionado)
	blips = AddBlipForCoord(zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3])
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Graos")
	EndTextCommandSetBlipName(blips)
end