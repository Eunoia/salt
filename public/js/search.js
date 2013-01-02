// Generated by CoffeeScript 1.4.0
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  jQuery(function() {
    var instantiateAutoComplete;
    instantiateAutoComplete = function(places) {
      places = places.map(function(placeName) {
        var r;
        r = {};
        r.value = placeName.toLowerCase().replace(/[^a-z]/ig, "");
        r.label = placeName;
        return r;
      });
      return $("#find").autocomplete({
        source: places,
        select: function(event, ui) {
          console.log(ui.item);
          $(".post[data-dest=" + ui.item.value + "]").fadeIn();
          return $(".post[data-dest!=" + ui.item.value + "]").fadeOut();
        }
      }).attr("disabled", false);
    };
    $.getJSON('/api/latest/#{location.pathname.split("/").pop()}/200', function(rideSharePosts) {
      var $tmpl, img, place, places, post, url, _i, _len, _ref;
      places = [];
      for (_i = 0, _len = rideSharePosts.length; _i < _len; _i++) {
        post = rideSharePosts[_i];
        $tmpl = $("<div class='post' id=" + post.cid + "'><small><a href='" + post.link + "'>" + post.cid + "</a><br></small><b>" + post.title + "</b></div>");
        $tmpl.addClass(post.wo === 1 ? "Wanted" : "Offered");
        $tmpl.append(post.wo === 1 ? "Wanted" : "Offered");
        url = "http://maps.googleapis.com/maps/api/				staticmap?sensor=false&maptype=roadmap				&zoom=11&size=512x128&key=AIzaSyD9YYuZq29v40PmgVqGM77mE60u-Lui2K8				&style=feature:road.local|element:geometry|visibility:off&style=feature:road.highway|element:labels|visibility:simplified&style=feature:landscape.man_made|visibility:off&style=feature:poi|visibility:off&style=feature:poi.school|visibility:on&style=feature:poi.park|visibility:on&style=feature:road.local|visibility:on|lightness:48&style=feature:poi.park|element:labels|visibility:off&style=feature:road.arterial|element:labels|visibility:off				&center=".replace(/\s/g, "");
        place = post.dest;
        if (place.match(/Canada/i)) {
          url = url.replace("11", "2");
        }
        if (place === "Mammoth") {
          place += " Lakes";
          url = url.replace("11", "9");
        }
        if (place.match(/slo/i)) {
          place = "San Luis Obisbo";
        }
        if (place.match(/mt\W/i)) {
          url = url.replace("11", "9");
        }
        if (place.match(/Mexico/i)) {
          url = url.replace("11", "6");
        }
        if ((place + " ").match(/cali\W/i) != null) {
          place = place.replace(RegExp(" cali", "i"), " California");
          url = url.replace("11", "5");
        }
        if (place === "Montana") {
          url = url.replace("11", "7");
        }
        if (place.match(/Christmas/i)) {
          place = place.replace(RegExp(" Christmas ", "i"), "");
        }
        if (place === "Norcal") {
          url = url.replace("11", "5");
          place = "Chico";
        }
        if (place === "Florida") {
          url = url.replace("11", "7");
        }
        if (place.match(/dakota/i) ? place.match(/(n(orth)?|s(outh)?)/i) : void 0) {
          url = url.replace("11", "7");
        }
        if (place === "Tricities") {
          place = "Tri cities Washington";
          url = url.replace("11", "9");
        }
        if (place === "East Bay") {
          place = "oakland";
        }
        if (place === "Slc") {
          place = "Salt Lake City";
        }
        if (place === "Arizona" || place === "Az") {
          url = url.replace("11", "9");
        }
        if (place === "Bay") {
          place = "Bay Area";
        }
        if (place === "East") {
          place = "East Point, GA";
          url = url.replace("11", "15");
        }
        if (place.match(/orange/i)) {
          place += " California";
        }
        if (place === "America") {
          url = url.replace("11", "3");
        }
        if (place === "East Coast") {
          url = url.replace("11", "4");
          place = "East Coast USA";
        }
        if (place.match(/Humboldt/i)) {
          place = "Arcata ";
        }
        if (place.match(/Carolina/i)) {
          url = url.replace("11", "7");
        }
        if (place !== "") {
          place = place.replace(RegExp(" ", "g"), "%20");
          img = "<img src=" + url + place + " />";
          $tmpl.append(img).attr("data-dest", place.toLowerCase().replace(/[^a-z]/ig, ""));
        }
        if (!(_ref = post.dest, __indexOf.call(places, _ref) >= 0)) {
          places.push(post.dest);
        }
        $("#cont").append($tmpl);
      }
      return instantiateAutoComplete(places);
    });
    $("#offeredRadio").click(function() {
      $(".wanted").fadeOut();
      return $(".offered").fadeIn();
    });
    $("#wantedRadio").click(function() {
      $(".wanted").fadeIn();
      return $(".offered").fadeOut();
    });
    $("#bothRadio").click(function() {
      $(".wanted").fadeIn();
      return $(".offered").fadeIn();
    });
    return document.getElementsByTagName("select")[0].onchange = function() {
      var newCity, newURL;
      newURL = window.location.href.match(/^ht.+\//);
      newCity = $(this).find(":selected").text();
      return window.location.href = newURL + newCity.replace(/\s+/g, "").toLowerCase();
    };
  });

}).call(this);
