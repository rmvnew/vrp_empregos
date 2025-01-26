------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local blips = {}
local zonas = {}
local segundos = 0
local selecionado = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local entregador = {
	["Entregador"] = {
		iniciar = vec3(71.06,108.74,79.19),
		pegarcaminhao = vec3(73.98,115.89,79.14),
		pegarcaixas = vec3(79.09,112.44,81.17)
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(entregador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 10.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3] + 1.2,"Aperte ~b~E~w~ para entrar em serviço.")
					
					

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 5
						servico = true
						selecionado = 1
						zonas = carregarZonas("Entregador", false)
						CriandoBlipEntregador(selecionado)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao)
				
				if  distance2 <= 4.0 then
					time = 5
					DrawText3Ds(v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3]+ 0.4,"Aperte ~b~E~w~ para pegar o caminhao.")
					DrawMarker(36,v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3] - 0.4, 0,0,0,0,0,0,1.0,1.0,1.0,10,102,255,180,0,0,0,1)

					if IsControlJustReleased(1, 51) and segundos <= 0 then
						
						segundos = 5
						criarVehicle(69.31,117.84,79.13,164.86,"speedo", false)
						

					end
				end

				local distance3 = #(playercoords - v.pegarcaixas)
				if distance3 <= 5.0 then
					time = 5
					DrawText3Ds(v.pegarcaixas[1],v.pegarcaixas[2],v.pegarcaixas[3]-0.1,"Aperte ~b~E~w~ para coletar as caixas.")
					-- DrawMarker(21,v.pegarcaixas[1],v.pegarcaixas[2],v.pegarcaixas[3]- 0.3, 0,0,0,180,0,0,1.0,1.0,1.0,10,102,255,180,0,0,0,1)
					DrawMarker(21, v.pegarcaixas[1], v.pegarcaixas[2], v.pegarcaixas[3] - 0.3, 0, 0, 0, 0, 180.0, 0, 1.0, 1.0, 1.0, 10, 102, 255, 180, 0, 0, 0, 1)

					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 5
						
						local finished = vRP.taskBar(2500, math.random(10,20))
						if finished then
							local finished = vRP.taskBar(2500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(1500, math.random(10,20))
								if finished then
									vSERVER._giveCaixas(math.random(1,3))
								end
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
-- ZONAS DE ENTREGA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico and selecionado >= 1 then
			local distance = #(playercoords - zonas[selecionado].coords)
			if distance <= 30.0 then
				time = 5
				DrawMarker(21,zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

				if distance <= 2.5 then
					if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
						segundos = 5
						local vehicle = GetPlayersLastVehicle()
						if IsVehicleModel(vehicle,GetHashKey("speedo")) then
							
							vRP.playAnim(true,{{"mp_common","givetake1_a"}},false)
							SetTimeout(3*1000, function()
								if payment("Entregador", 0, selecionado) then
									RemoveBlip(blips)

									selecionado = selecionado + 1
									if selecionado > #zonas then
										selecionado = 1
									end

									CriandoBlipEntregador(selecionado)
								end
							end)

						else
							TriggerEvent("Notify","importante","Você não pode fazer entrega utilizando outro veiculo", 5)
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
			drawTxt("~w~Aperte ~r~F7~w~ se deseja finalizar o expediente.\nEntregue as ~y~caixas~w~ pelos ponto do mapa.", 0.215,0.94)

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

function CriandoBlipEntregador(selecionado)
	blips = AddBlipForCoord(zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3])
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Entregador")
	EndTextCommandSetBlipName(blips)
end


