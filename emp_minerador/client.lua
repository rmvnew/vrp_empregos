------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0
local blips = {}
local selecionado = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local minerador = {
	["Minerador"] = {
		iniciar = vec3(1054.05,-1952.6,32.1),
		pegarcaminhao = vec3(1082.93,-1949.51,31.02),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(minerador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawMarker(2,v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.20, 0,0, 0,0, 0,0, 0.5, 0.4, 0.5, 229, 35, 149, 80, 1, 0, 0, 0)

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						zonas = carregarZonas("Minerador", false)
						selecionado = #zonas
						CriandoBlipMinerador(selecionado)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao)
				if distance2 <= 2.0 then
					time = 5
					-- DrawText3Ds(v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3]-0.1,"Aperte ~b~E~w~ para pegar o caminhao.")
					DrawMarker(2,v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3]-0.20, 0,0, 0,0, 0,0, 0.5, 0.4, 0.5, 229, 35, 149, 80, 1, 0, 0, 0)
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 10
						criarVehicle(1074.19,-1949.35,30.65,146.81,"TipTruck", false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE MINERAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico and segundos <= 0 then
			local distance = #(playercoords - zonas[selecionado].coords)
			if distance <= 150.0 then
				time = 5
				DrawMarker(21,zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

				if distance <= 2.5 then
					if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
						segundos = 5
						vRP.CarregarObjeto("amb@world_human_const_drill@male@drill@base","base","prop_tool_jackham",15,28422)

						local finished = vRP.taskBar(3500, math.random(10,20))
						if finished then
							local finished = vRP.taskBar(3500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(2500, math.random(10,20))
								if finished then
									RemoveBlip(blips)
									payment("Minerador", math.random(6), selecionado)

									selecionado = math.random(#zonas)
									CriandoBlipMinerador(selecionado)
								end
							end
						end

						vRP._stopAnim(false)
						vRP._DeletarObjeto()
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
			drawTxt("~w~Aperte ~r~F7~w~ se deseja finalizar o expediente.\nColete as ~y~rochas~w~ pelos pontos do mapa.", 0.215,0.94)

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

function CriandoBlipMinerador(selecionado)
	blips = AddBlipForCoord(zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3])
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Minerador")
	EndTextCommandSetBlipName(blips)
end