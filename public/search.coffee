jQuery ->
	instantiateAutoComplete = (places) ->
		places = places.map (placeName) -> 
			r = {}
			r.value = placeName.toLowerCase().replace(/[^a-z]/ig,"")
			r.label = placeName
			r
		$( "#find" ).autocomplete({
			source: places,
		#	options: {width: 7em},
			select: (event,ui) ->
				console.log(ui.item)
				$(".post[data-dest=#{ui.item.value}]").fadeIn()
				$(".post[data-dest!=#{ui.item.value}]").fadeOut()
		}).attr("disabled",false);

	$.getJSON(
		"/api/latest/#{location.pathname.split("/").pop()}/200",
		(rideSharePosts) ->
			places = []
			for post in rideSharePosts
				$tmpl = $("<div class='post' id=#{post.cid}'><small><a href='#{post.link}'>#{post.cid}</a><br></small><b>#{post.title}</b></div>");
				$tmpl.addClass( if post.wo==1 then "Wanted" else "Offered" )
				$tmpl.append(if post.wo==1 then "Wanted" else "Offered")
				url = "http://maps.googleapis.com/maps/api/
				staticmap?sensor=false&maptype=roadmap
				&zoom=11&size=512x128&key=AIzaSyD9YYuZq29v40PmgVqGM77mE60u-Lui2K8
				&style=feature:road.local|element:geometry|visibility:off&style=feature:road.highway|element:labels|visibility:simplified&style=feature:landscape.man_made|visibility:off&style=feature:poi|visibility:off&style=feature:poi.school|visibility:on&style=feature:poi.park|visibility:on&style=feature:road.local|visibility:on|lightness:48&style=feature:poi.park|element:labels|visibility:off&style=feature:road.arterial|element:labels|visibility:off
				&center=".replace(/\s/g,"")
				place = post.dest
				url = url.replace("11", "2")  if place.match(/Canada/i)
				if place is "Mammoth"
					place += " Lakes"
					url = url.replace("11", "9")
				place = "San Luis Obisbo"  if place.match(/slo/i)
				url = url.replace("11", "9")  if place.match(/mt\W/i)
				url = url.replace("11", "6")  if place.match(/Mexico/i)
				# if place is "california"
					# url = url.replace('11','5')
				if (place + " ").match(/cali\W/i)?
					place = place.replace(RegExp(" cali", "i"), " California")
					url = url.replace("11", "5")
				url = url.replace("11", "7")  if place is "Montana"
				place = place.replace(RegExp(" Christmas ", "i"), "")  if place.match(/Christmas/i)
				if place is "Norcal"
					url = url.replace("11", "5")
					place = "Chico"
				url = url.replace("11", "7")  if place is "Florida"
				url = url.replace("11", "7")  if place.match(/(n(orth)?|s(outh)?)/i)  if place.match(/dakota/i)
				if place is "Tricities"
					place = "Tri cities Washington"
					url = url.replace("11", "9")
				place = "oakland"  if place is "East Bay"
				place = "Salt Lake City"  if place is "Slc"
				url = url.replace("11", "9")  if place is "Arizona" or place is "Az"
				place = "Bay Area"  if place is "Bay"
				if place is "East"
					place = "East Point, GA"
					url = url.replace("11", "15")
				place += " California"  if place.match(/orange/i)
				url = url.replace("11", "3")  if place is "America"
				if place is "East Coast"
					url = url.replace("11", "4")
					place = "East Coast USA"
				place = "Arcata "  if place.match(/Humboldt/i)
				url = url.replace("11", "7")  if place.match(/Carolina/i)
				unless place is ""
					place = place.replace(RegExp(" ", "g"), "%20")
					img = "<img src=" + url + place + " />"
					$tmpl.append(img).attr("data-dest",place.toLowerCase().replace(/[^a-z]/ig,""))
				places.push(post.dest) unless (post.dest in places)
				$("#cont").append($tmpl)
			instantiateAutoComplete(places)
	)
	$("#offeredRadio").click ()  ->
		$(".wanted").fadeOut()
		$(".offered").fadeIn()
	$("#wantedRadio").click ()  ->
		$(".wanted").fadeIn()
		$(".offered").fadeOut()

	$("#bothRadio").click ()  ->
		$(".wanted").fadeIn()
		$(".offered").fadeIn()

	document.getElementsByTagName("select")[0].onchange = () -> 
		newURL = window.location.href.match(/^ht.+\//);
		newCity = $(this).find(":selected").text();
		window.location.href = newURL+newCity.replace(/\s+/g, "").toLowerCase();

