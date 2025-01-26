------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0
local blips = {}
local selecionado = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local taxista = {
	["Taxista"] = {
		iniciar = vec3(895.21,-178.85,74.71),
		pegartaxi = vec3(900.12,-170.89,74.08)
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(taxista) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawMarker(2,v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.20, 0,0, 0,0, 0,0, 0.5, 0.4, 0.5, 229, 35, 149, 80, 1, 0, 0, 0)

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 5
						servico = true

						zonas = carregarZonas("Taxista", false)
						selecionado = math.random(#zonas)
						CriandoBlipTaxista(selecionado)
					end
				end
			else
				local distance2 = #(playercoords - v.pegartaxi)
				if distance2 <= 2.0 then
					time = 5
					-- DrawText3Ds(v.pegartaxi[1],v.pegartaxi[2],v.pegartaxi[3]-0.1,"Aperte ~b~E~w~ para pegar o taxi.")
					DrawMarker(2,v.pegartaxi[1],v.pegartaxi[2],v.pegartaxi[3]-0.20, 0,0, 0,0, 0,0, 0.5, 0.4, 0.5, 229, 35, 149, 80, 1, 0, 0, 0)
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 5
						criarVehicle(897.53,-183.54,73.38,237.22,"taxi", false)
					end
				end

			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico and segundos <= 0 then
			local distance = #(playercoords - zonas[selecionado].coords)
			if distance <= 30.0 then
				time = 5
				DrawMarker(21,zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

				if distance <= 5.0 then
					if IsControlJustReleased(1, 51) and segundos <= 0 and IsPedInAnyVehicle(PlayerPedId()) then
						segundos = 15

						local vehicle = GetPlayersLastVehicle()
						if GetPedInVehicleSeat(vehicle, -1) then
							if IsVehicleModel(vehicle,GetHashKey("taxi")) then
								TriggerEvent("progress", 10)
								-- SetVehicleUndriveable(vehicle, true)

								SetTimeout(1*1000, function()
									RemoveBlip(blips)
									SetVehicleUndriveable(vehicle, false)
									payment("Taxista", 0, selecionado)

									selecionado = math.random(#zonas)
									CriandoBlipTaxista(selecionado)
								end)
							else
								TriggerEvent("Notify","importante","Você não pode fazer entrega utilizando outro veiculo", 5)
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
			drawTxt("~w~Aperte ~r~F7~w~ se deseja finalizar o expediente.\nEntregue os ~y~passageiros~w~ pela cidade.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				servico = false
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

function CriandoBlipTaxista(selecionado)
	blips = AddBlipForCoord(zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3])
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Taxista")
	EndTextCommandSetBlipName(blips)
end