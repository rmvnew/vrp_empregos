------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0
local selecionado = 0
local blips = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lenhador = {
	["Lenhador"] = {
		iniciar = vec3(-841.65,5401.1,34.62),
		pegarcaminhao = vec3(-794.1,5410.68,34.22),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(lenhador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					-- DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"Aperte ~b~E~w~ para entrar em serviço.")
					DrawMarker(2,v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.20, 0,0, 0,0, 0,0, 0.5, 0.4, 0.5, 229, 35, 149, 80, 1, 0, 0, 0)

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						zonas = carregarZonas("Lenhador", false)
						selecionado = math.random(#zonas)
						CriandoBlipLenhador(selecionado)
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

						criarVehicle(-806.59,5411.33,33.99,59.27,"phantom", false)
						criarVehicle(-788.79,5401.0,34.27,90.11,"trailerlogs", true)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE COLETAR MADEIRA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico then
			local distance = #(playercoords - zonas[selecionado].coords)
			if distance <= 150.0 then -- 30.0
				time = 5
				DrawMarker(20,zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3],0,0,0,0,180.0,130.0,0.5,1.0,0.5, 165,95,29,180 ,1,0,0,1)

				if distance <= 2.5 then
					if GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_HATCHET") then
					if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
						segundos = 5
						vRP._playAnim(false,{{"melee@hatchet@streamed_core","plyr_front_takedown_b"}},true)

						local finished = vRP.taskBar(3500, math.random(1,3))
						if finished then
							local finished = vRP.taskBar(3500, math.random(1,3))
							if finished then
								local finished = vRP.taskBar(2500, math.random(1,3))
								if finished then
									RemoveBlip(blips)
									payment("Lenhador", 0, selecionado)

									selecionado = math.random(#zonas)
									CriandoBlipLenhador(selecionado)
								end
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
			drawTxt("~w~Aperte ~r~F7~w~ se deseja finalizar o expediente.\nColete as ~y~madeiras~w~ pelos pontos do mapa.", 0.215,0.94)

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

function CriandoBlipLenhador(selecionado)
	blips = AddBlipForCoord(zonas[selecionado].coords[1],zonas[selecionado].coords[2],zonas[selecionado].coords[3])
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Lenhador")
	EndTextCommandSetBlipName(blips)
end