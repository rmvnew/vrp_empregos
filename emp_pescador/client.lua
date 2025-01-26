------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local pescador = {
	["Pescador"] = {
		iniciar = vec3(1132.1,-557.48,56.8),
		pegarbarco = vec3(-1605.12,5257.84,2.09),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(pescador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					-- DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"Aperte ~b~E~w~ para entrar em serviço.")
					DrawMarker(2,v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.20, 0,0, 0,0, 0,0, 0.5, 0.4, 0.5, 229, 35, 149, 80, 1, 0, 0, 0)
					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						vSERVER._giveIsca(25)
						zonas = carregarZonas("Pescador", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarbarco)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarbarco[1],v.pegarbarco[2],v.pegarbarco[3]-0.1,"Aperte ~b~E~w~ para pegar o barco.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 10
						criarVehicle(-1598.53,5251.9,0.12,347.04,"dinghy", false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE PESCA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico then
			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 18.0 then
					time = 5
					drawTxt("Aperte ~b~E~w~ para pescar",0.5,0.96)
					if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
						segundos = 5
						if vSERVER.tryIsca() then
							vRP._CarregarObjeto("amb@world_human_stand_fishing@idle_a","idle_c","prop_fishing_rod_01",15,60309)

							local finished = vRP.taskBar(3500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(3500, math.random(10,20))
								if finished then
									local finished = vRP.taskBar(2500, math.random(10,20))
									if finished then
										payment("Pescador", math.random(5), k)
									end
								end
							end

							vRP._stopAnim(false)
                            vRP._DeletarObjeto()
						end

					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

function src.carregarZonas()
	zonas = {
		[1] = { coords = vec3( 1106.27,-569.12,55.34 ) },
	}
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~Aperte ~r~F7~w~ se deseja finalizar o expediente.\nColete os ~y~peixes~w~ pelos pontos do mar.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				servico = false
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