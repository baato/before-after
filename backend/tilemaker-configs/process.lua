-- Data processing based on openmaptiles.org schema
-- https://openmaptiles.org/schema/
-- Copyright (c) 2016, KlokanTech.com & OpenMapTiles contributors.
-- Used under CC-BY 4.0

--[[

	Specific issues:
	- aerodrome_label layer is not supported
	- boundary layer is not supported
	- render_min_height and render_height in buildings layer are not supported

	To investigate:
	- waterway names
	- parking, bicycle_parking
	- stations
	- not all POIs showing (e.g. West Oxford Community Primary School in Osney - vt2geojson shows it's in tile 14/8133/5130)
	- low zoom levels
	- anything in man_made?
	- sea stuff to do

	Possible fields for POIs:
    - name: funicular
    - name: geometry
    - name: indoor
    - name: information
    - name: layer
    - name: level
    - name: mapping_key
    - name: name
    - name: name_de
    - name: name_en
    - name: osm_id
    - name: religion
    - name: sport
    - name: station
    - name: subclass
    - name: tags
    - name: uic_ref
--]]

-- Enter/exit Tilemaker
function init_function()
end
function exit_function()
end

-- Implement Sets in tables
function Set(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- Process node tags

-- node_keys = { "amenity", "shop", "sport", "tourism", "place", "office", "natural", "addr:housenumber" }
node_keys = { "amenity", "shop", "sport", "tourism", "place", "office", "natural"}


function node_function(node)
	-- Write 'housenumber'
	-- local housenumber = node:Find("addr:housenumber")
	-- if housenumber~="" then
	-- 	node:Layer("housenumber", false)
	-- 	node:Attribute("housenumber", housenumber)
	-- end

	-- Write 'place'
	local place = node:Find("place")
	if place ~= "" then
		local rank = 5

		if     place == "continent"     then rank = 1
		elseif place == "country"       then rank = 1
		elseif place == "state"         then rank = 1
		elseif place == "city"          then rank = 2
		elseif place == "town"          then rank = 3
		elseif place == "village"       then rank = 4
		elseif place == "suburb"        then rank = 3
		elseif place == "neighbourhood" then rank = 4
		elseif place == "locality"      then rank = 4 
		elseif place == "hamlet"        then rank = 4 end

		if rank <= 3 then
			node:Layer("place", false)
		else
			node:Layer("place_detail", false)
		end
		node:AttributeNumeric("rank", rank)
		node:Attribute("class", place)
		SetNameAttributes(node)
		return
	end

	-- Write 'poi'
	local rank, class, subclass = GetPOIRank(node)
	if rank then
		if rank <= 4 then node:Layer("poi", false)
		             else node:Layer("poi_detail", false) end
 		node:Attribute("class", class)
 		node:Attribute("subclass", subclass)
 		node:AttributeNumeric("rank", rank)
		poi = true
		SetNameAttributes(node)
		return
	end

	-- Write 'mountain_peak' and 'water_name'
	local natural = node:Find("natural")
	if natural == "peak" then
		node:Layer("mountain_peak", false)
		local ele = node:Find("ele")
		if ele ~= "" then
			node:AttributeNumeric("ele", tonumber(ele) or 0)
		end
		node:AttributeNumeric("rank", 5)
		SetNameAttributes(node)
		return
	end
	if natural == "bay" then
		node:Layer("water_name", false)
		SetNameAttributes(node)
		return
	end
end

-- Process way tags

minorRoadValues = Set { "unclassified", "residential", "road" }
trackValues     = Set { "cycleway", "byway", "bridleway", "track" }
pathValues      = Set { "footway", "path" }
linkValues      = Set { "motorway_link", "trunk_link", "primary_link", "secondary_link", "tertiary_link" }

aerowayBuildings= Set { "terminal", "gate", "tower" }
landuseKeys     = Set { "school", "university", "kindergarten", "college", "library", "hospital", 
                        "railway", "cemetery", "military", "residential", "commercial", "industrial",
                        "retail", "stadium", "pitch", "playground", "theme_park", "bus_station", "zoo", "swimming", "swimming_pool" }
landcoverKeys   = { wood="wood", forest="wood",
                    wetland="wetland", 
                    beach="sand", sand="sand",
                    farmland="farmland", farm="farmland", orchard="farmland", vineyard="farmland", plant_nursery="farmland",
                    glacier="ice", ice_shelf="ice",
                    grassland="grass", grass="grass", meadow="grass", allotments="grass", park="grass", village_green="grass", recreation_ground="grass", garden="grass", golf_course="grass" }
poiTags         = { aerialway = Set { "station" },
					amenity = Set { "arts_centre", "bank","atm","bar", "bbq", "bicycle_parking", "bicycle_rental", "biergarten", "bus_station", "cafe", "cinema", "clinic", "college", "community_centre", "courthouse", "dentist", "doctors", "embassy", "events_venue", "fast_food", "ferry_terminal", "fire_station", "food_court", "fuel", "grave_yard", "hospital", "ice_cream", "kindergarten", "library", "marketplace", "motorcycle_parking", "nightclub", "nursing_home", "parking", "pharmacy", "place_of_worship", "police", "post_box", "post_office", "prison", "pub", "public_building", "recycling", "restaurant", "school", "shelter", "swimming_pool", "taxi", "telephone", "theatre", "toilets", "townhall", "university", "veterinary", "waste_basket" },
					religion = Set { "hindu", "buddhist", "muslim" },
					barrier = Set { "bollard", "border_control", "cycle_barrier", "gate", "lift_gate", "sally_port", "stile", "toll_booth" },
					building = Set { "dormitory" },
					highway = Set { "bus_stop" },
					historic = Set { "monument", "castle", "ruins" },
					landuse = Set { "basin", "brownfield", "cemetery", "reservoir", "winter_sports" },
					leisure = Set { "dog_park", "escape_game", "garden", "golf_course", "ice_rink", "hackerspace", "marina", "miniature_golf", "park", "pitch", "playground", "sports_centre", "stadium", "swimming_area", "swimming_pool", "water_park" },
					office = Set {"accountant","adoption_agency","advertising_agency","architect","association","bail_bond_agent","charity","company","consulting","coworking","diplomatic","educational_institution","employment_agency","	energy_supplier","engineer","estate_agent","financial","forestry","foundation","geodesist","government","graphic_design","guide","harbour_master","insurance","it","lawyer","logistics","moving_company","newspaper","ngo","notary","political_party","private_investigator","property_management","quango","religion","research","security","surveyor","tax","tax_advisor","	telecommunication","union","visa","water_utility"},
					railway = Set { "halt", "station", "subway_entrance", "train_station_entrance", "tram_stop" },
					shop = Set { "accessories", "alcohol", "antiques", "art", "bag", "bakery", "beauty", "bed", "beverages", "bicycle", "books", "boutique", "butcher", "camera", "car", "car_repair", "carpet", "charity", "chemist", "chocolate", "clothes", "coffee", "computer", "confectionery", "convenience", "copyshop", "cosmetics", "deli", "delicatessen", "department_store", "doityourself", "dry_cleaning", "electronics", "erotic", "fabric", "florist", "frozen_food", "furniture", "garden_centre", "general", "gift", "greengrocer", "hairdresser", "hardware", "hearing_aids", "hifi", "ice_cream", "interior_decoration", "jewelry", "kiosk", "lamps", "laundry", "mall", "massage", "mobile_phone", "motorcycle", "music", "musical_instrument", "newsagent", "optician", "outdoor", "perfume", "perfumery", "pet", "photo", "second_hand", "shoes", "sports", "stationery", "supermarket", "tailor", "tattoo", "ticket", "tobacco", "toys", "travel_agency", "video", "video_games", "watches", "weapons", "wholesale", "wine" },
					sport = Set { "american_football", "archery", "athletics", "australian_football", "badminton", "baseball", "basketball", "beachvolleyball", "billiards", "bmx", "boules", "bowls", "boxing", "canadian_football", "canoe", "chess", "climbing", "climbing_adventure", "cricket", "cricket_nets", "croquet", "curling", "cycling", "disc_golf", "diving", "dog_racing", "equestrian", "fatsal", "field_hockey", "free_flying", "gaelic_games", "golf", "gymnastics", "handball", "hockey", "horse_racing", "horseshoes", "ice_hockey", "ice_stock", "judo", "karting", "korfball", "long_jump", "model_aerodrome", "motocross", "motor", "multi", "netball", "orienteering", "paddle_tennis", "paintball", "paragliding", "pelota", "racquet", "rc_car", "rowing", "rugby", "rugby_league", "rugby_union", "running", "sailing", "scuba_diving", "shooting", "shooting_range", "skateboard", "skating", "skiing", "soccer", "surfing", "swimming", "table_soccer", "table_tennis", "team_handball", "tennis", "toboggan", "volleyball", "water_ski", "yoga" },
					tourism = Set { "alpine_hut", "aquarium", "artwork", "attraction", "bed_and_breakfast", "camp_site", "caravan_site", "chalet", "gallery", "guest_house", "hostel", "hotel", "information", "motel", "museum", "picnic_site", "theme_park", "viewpoint", "zoo" },
					waterway = Set { "dock" } }
poiClasses      = { townhall="town_hall", public_building="town_hall", courthouse="town_hall", community_centre="town_hall",
					golf="golf", golf_course="golf", miniature_golf="golf",
					fast_food="fast_food", food_court="fast_food",
					park="park", bbq="park",
					bus_stop="bus", bus_station="bus",
					subway_entrance="entrance", train_station_entrance="entrance",
					camp_site="campsite", caravan_site="campsite",
					laundry="laundry", dry_cleaning="laundry",
					supermarket="grocery", deli="grocery", delicatessen="grocery", department_store="grocery", greengrocer="grocery", marketplace="grocery",
					books="library", library="library",
					university="college", college="college",
					hotel="lodging", motel="lodging", bed_and_breakfast="lodging", guest_house="lodging", hostel="lodging", chalet="lodging", alpine_hut="lodging", dormitory="lodging",
					chocolate="ice_cream", confectionery="ice_cream",
					post_box="post",  post_office="post",  
					cafe="cafe",  
					school="school",  kindergarten="school", 
					alcohol="alcohol_shop",  beverages="alcohol_shop",  wine="alcohol_shop",  
					bar="bar", nightclub="bar",
					marina="harbor", dock="harbor",
					car="car", car_repair="car", taxi="car",
					accountant="office", adoption_agency="office", advertising_agency="office", architect="office", association="office", bail_bond_agent="office", charity="office", company="office", consulting="office", coworking="office", diplomatic="office", educational_institution="office", employment_agency="office", energy_supplier="office", engineer="office", estate_agent="office", financial="office", forestry="office", foundation="office", geodesist="office", government="office", graphic_design="office", guide="office", harbour_master="office", insurance="office", it="office", lawyer="office", logistics="office", moving_company="office", newspaper="office", ngo="office", notary="office", political_party="office", private_investigator="office", property_management="office", quango="office", religion="office", research="office", security="office", surveyor="office", tax="office", tax_advisor="office", telecommunication="office", union="office", visa="office", water_utility="office",
					hindu="religion",buddhist="religion",muslim="religion",
					hospital="hospital", nursing_home="hospital",  clinic="clinic",
					grave_yard="cemetery", cemetery="cemetery",
					attraction="attraction", viewpoint="attraction",
					biergarten="beer", pub="beer",
					music="music", musical_instrument="music",
					american_football="stadium", stadium="stadium", soccer="stadium",
					art="art_gallery", artwork="art_gallery", gallery="art_gallery", arts_centre="art_gallery",
					bag="clothing_store", clothes="clothing_store",
					swimming_area="swimming", swimming="swimming",
					castle="castle", ruins="castle" }
poiClassRanks   = { hospital=1, railway=2, bus=3, attraction=4, harbor=5, college=6, 
					school=7, stadium=8, zoo=9, town_hall=10, campsite=11, cemetery=12, 
					park=13, library=14, police=15, post=16, golf=17, shop=18, grocery=19, 
					fast_food=20, clothing_store=21, bar=22 }
poiKeys = { "amenity", "sport", "tourism", "office", "historic", "leisure", "landuse", "information" }


function way_function(way)
	local highway  = way:Find("highway")
	local waterway = way:Find("waterway")
	local building = way:Find("building")
	local natural  = way:Find("natural")
	local historic = way:Find("historic")
	local landuse  = way:Find("landuse")
	local leisure  = way:Find("leisure")
	local amenity  = way:Find("amenity")
	local aeroway  = way:Find("aeroway")
	local railway  = way:Find("railway")
	local sport    = way:Find("sport")
	local shop     = way:Find("shop")
	local tourism  = way:Find("tourism")
	local man_made = way:Find("man_made")
	local office  = way:Find("office")	
	local isClosed = way:IsClosed()
	-- local housenumber = way:Find("addr:housenumber")
	local write_name = false

	-- Miscellaneous preprocessing
	if way:Find("disused") == "yes" then return end
	if highway == "proposed" then return end
	if aerowayBuildings[aeroway] then building="yes"; aeroway="" end
	if landuse == "field" then landuse = "farmland" end
	if landuse == "meadow" and way:Find("meadow")=="agricultural" then landuse="farmland" end

	
	-- Highway = trunk layer
	if highway == "trunk" then
		local h = highway
		local layer = "highway_trunk"
		way:Layer(layer, false)
		way:Attribute("class", h)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end
	
	-- -- Highway = residential layer
	-- if highway == "residential" then
	-- 	local h = highway
	-- 	local layer = "highway_residential"
	-- 	way:Layer(layer, false)
	-- 	way:Attribute("class", h)
	-- 	SetNameAttributes(way)
	-- 	SetBrunnelAttributes(way)
	-- end

	-- Highway = primary layer
	if highway == "primary" then
		local h = highway
		local layer = "highway_primary"
		way:Layer(layer, false)
		way:Attribute("class", h)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end

	-- Highway = secondary layer
	if highway == "secondary" then
		local h = highway
		local layer = "highway_secondary"
		way:Layer(layer, false)
		way:Attribute("class", h)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end

	-- Highway = tertiary layer
	if highway == "tertiary" then
		local h = highway
		local layer = "highway_tertiary"
		way:Layer(layer, false)
		way:Attribute("class", h)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end

	-- Highway = service layer
	if highway == "service" then
		local h = highway
		local layer = "highway_service"
		way:Layer(layer, false)
		way:Attribute("class", h)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end

	-- Highway ~= minor layer. This includes highway=residential as well!
	if minorRoadValues[highway] then 
		local layer = "highway_minor"
		way:Layer(layer, false)
		way:Attribute("class", highway)
		SetNameAttributes(way)
		SetBrunnelAttributes(way) 
	end

	-- Highway ~= path layer
	if pathValues[highway] then
		local layer = "highway_path"
		way:Layer(layer, false)
		way:Attribute("class", highway)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end
	
	-- Highway ~= track layer
	if trackValues[highway] then
		local layer = "highway_track"
		way:Layer(layer, false)
		way:Attribute("class", highway)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	end

	

	-- -- Roads ('transportation' and 'transportation_name', plus 'transportation_name_detail')
	-- if highway~="" then
	-- 	local h = highway
	-- 	local layer = "transportation"
	-- 	if minorRoadValues[highway] then h = "minor"; layer="transportation_mid" end
	-- 	if trackValues[highway]     then h = "track"; layer="transportation_detail" end
	-- 	if pathValues[highway]      then h = "path" ; layer="transportation_detail" end
	-- 	if h=="service" then layer="transportation_detail" end
	-- 	way:Layer(layer, false)
	-- 	way:Attribute("class", h)
	-- 	SetBrunnelAttributes(way)

	-- 	-- Service
	-- 	local service = way:Find("service")
	-- 	if highway == "service" and service ~="" then way:Attribute("service", service) end

	-- 	-- Links (ramp)
	-- 	if linkValues[highway] then 
	-- 		splitHighway = split(highway, "_")
	-- 		highway = splitHighway[1]
	-- 		way:AttributeNumeric("ramp",1)
	-- 	end

	-- 	local oneway = way:Find("oneway")
	-- 	if oneway == "yes" or oneway == "1" then
	-- 		way:AttributeNumeric("oneway",1)
	-- 	end
	-- 	if oneway == "-1" then
	-- 		-- **** TODO
	-- 	end

	-- 	-- Write names
	-- 	if h == "minor" or h == "track" or h == "path" or h == "service" then
	-- 		way:Layer("transportation_name_detail", false)
	-- 	else
	-- 		way:Layer("transportation_name", false)
	-- 	end
	-- 	SetNameAttributes(way)
	-- 	way:Attribute("class",h)
	-- 	way:Attribute("network","road") -- **** needs fixing
	-- 	if h~=highway then way:Attribute("subclass",highway) end
	-- 	local ref = way:Find("ref")
	-- 	if ref~="" then
	-- 		way:Attribute("ref",ref)
	-- 		way:AttributeNumeric("ref_length",ref:len())
	-- 	end
	-- end
	
	-- -- Railways ('transportation' and 'transportation_name', plus 'transportation_name_detail')
	-- if railway~="" then
	-- 	way:Layer("transportation", false)
	-- 	way:Attribute("class", railway)

	-- 	way:Layer("transportation_name", false)
	-- 	SetNameAttributes(way)
	-- 	way:Attribute("class", "rail")
	-- end
	
	-- 'Aeroway'
	if aeroway~="" then
		way:Layer("aeroway", isClosed)
		way:Attribute("class",aeroway)
		way:Attribute("ref",way:Find("ref"))
		SetNameAttributes(way)
		write_name = true
	end
	

	-- Set 'waterway' and associated
	if waterway~="" then
		if     waterway == "riverbank" then way:Layer("water",   isClosed); way:Attribute("class", "river");
		                                    if way:Find("intermittent")=="yes" then way:AttributeNumeric("intermittent",1) end
		elseif waterway == "dock"      then way:Layer("water",   isClosed); way:Attribute("class", "lake"); 
		                                    way:LayerAsCentroid("water_name_detail"); SetNameAttributes(way); write_name = true
		elseif waterway == "boatyard"  then way:Layer("landuse", isClosed); way:Attribute("class", "industrial")
		elseif waterway == "dam"       then way:Layer("building",isClosed)
		elseif waterway == "fuel"      then way:Layer("landuse", isClosed); way:Attribute("class", "industrial")
		else
			way:Layer("waterway",false)
			way:Attribute("class", waterway)
			SetNameAttributes(way)
			SetBrunnelAttributes(way)
		end
	end

	-- Set 'building' and associated
	if building~="" then way:Layer("building", true) end

	-- Set 'housenumber'
	-- if housenumber~="" then
	-- 	way:LayerAsCentroid("housenumber", false)
	-- 	way:Attribute("housenumber", housenumber)
	-- end
	
	-- Set 'water'
	if natural=="water" or natural=="bay" or landuse=="reservoir" then
		if way:Find("covered")=="yes" then return end
		local class="lake"; if natural=="bay" then class="ocean" end
		way:Layer("water", true)
		way:Attribute("class",class)
		if way:Find("intermittent")=="yes" then way:Attribute("intermittent",1) end
		if way:Holds("name") then
			way:LayerAsCentroid("water_name_detail")
			SetNameAttributes(way)
			way:Attribute("class", class)
		end
		return -- in case we get any landuse processing
	end

	-- Set 'landcover' (from landuse, natural, leisure)
	local l = landuse
	if l=="" then l=natural end
	if l=="" then l=leisure end
	if landcoverKeys[l] then
		way:Layer("landcover", true)
		way:Attribute("class", landcoverKeys[l])
		if l=="wetland" then way:Attribute("subclass", way:Find("wetland"))
		else way:Attribute("subclass", l) end
		way:LayerAsCentroid("poi_detail")
		SetNameAttributes(way)
		way:Attribute("class", landcoverKeys[l])
		-- write_name = true

	-- Set 'landuse'
	else
		if l=="" then l=amenity end
		if l=="" then l=tourism end
		if landuseKeys[l] then
			way:Layer("landuse", true)
			way:Attribute("class", l)
			way:LayerAsCentroid("poi_detail")
			SetNameAttributes(way)
			way:Attribute("class", l)
			-- write_name = true
		end
	end

	-- Parks
	-- **** name?
	if     boundary=="national_park" then way:Layer("park",true); way:Attribute("class",boundary); SetNameAttributes(way)
	elseif leisure=="nature_reserve" then way:Layer("park",true); way:Attribute("class",leisure ); SetNameAttributes(way) end

	-- POIs ('poi' and 'poi_detail')
	local rank, class, subclass = GetPOIRank(way)
	if rank and WriteNamedPOI(way,class,subclass,rank) then write_name=false end

	-- Catch-all
	if (building~="" or write_name) and way:Holds("name") then
		way:Attribute("class", "building")
		way:LayerAsCentroid("poi_detail")
		SetNameAttributes(way)
		if write_name then rank=6 else rank=25 end
		way:AttributeNumeric("rank", rank)
	end
end

-- ==========================================================
-- Common functions

-- Write a way centroid with name to POI layer
function WriteNamedPOI(obj,class,subclass,rank)
	if obj:Holds("name") then
		local layer = "poi"
		if rank>4 then layer="poi_detail" end
		obj:LayerAsCentroid(layer)
		SetNameAttributes(obj)
		obj:AttributeNumeric("rank", rank)
		obj:Attribute("class", class)
		obj:Attribute("subclass", subclass)
		return true
	end
	return false
end

-- Set name, name_en, and name_de on any object
function SetNameAttributes(obj)
	obj:Attribute("name:en", obj:Find("name:en"))
	obj:Attribute("name:ne", obj:Find("name:ne"))
	obj:Attribute("name:latin", obj:Find("name"))
	-- **** do transliteration
end

function SetBrunnelAttributes(obj)
	if     obj:Find("bridge") == "yes" then obj:Attribute("brunnel", "bridge")
	elseif obj:Find("tunnel") == "yes" then obj:Attribute("brunnel", "tunnel")
	elseif obj:Find("ford")   == "yes" then obj:Attribute("brunnel", "ford")
	end
end

-- Calculate POIs (typically rank 1-4 go to 'poi' z12-14, rank 5+ to 'poi_detail' z14)
-- returns rank, class, subclass
function GetPOIRank(obj)
	local k,list,v,class,rank
	
	-- Can we find the tag?
	for k,list in pairs(poiTags) do
		if list[obj:Find(k)] then
			v = obj:Find(k)	-- k/v are the OSM tag pair
			class = poiClasses[v] or v
			rank  = poiClassRanks[class] or 25
			return rank, class, v
		end
	end

	-- Catch-all for shops
	local shop = obj:Find("shop")
	if shop~="" then return poiClassRanks['shop'], shop, shop end

	-- Nothing found
	return nil,nil,nil
end

-- ==========================================================
-- Lua utility functions

function split(inputstr, sep) -- https://stackoverflow.com/a/7615129/4288232
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

