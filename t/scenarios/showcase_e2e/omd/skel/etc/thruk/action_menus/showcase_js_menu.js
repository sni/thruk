function showcase_js_menu(d) {
  return({
    "icon": "../themes/{{theme}}/images/dropdown.png",
    "title": "JavaScript Menu (demo)",
    "menu": [
      {
        "icon": "fa-folder",
        "label": "Services of " + d.host,
        "menu": showcase_js_menu_services
      },
      "-",
      {
        "icon": "uil-crosshair",
        "label": "Status Page",
        "action": "status.cgi?host=" + encodeURIComponent(d.host)
      }
    ]
  });
}

function showcase_js_menu_services(d) {
  // add a 2 seconds delay to make the asynchronous loading obvious
  return(new Promise(function(resolve) {
    setTimeout(function() {
      jQuery.get("../r/sites/" + d.backend + "/hosts/" + encodeURIComponent(d.host) + "/services?columns=description")
        .then(function(data) {
          var result = [];
          jQuery(data).each(function(i, r) {
            result.push({
              label: r.description,
              action: "extinfo.cgi?type=2&host=" + encodeURIComponent(d.host) + "&service=" + encodeURIComponent(r.description)
            });
          });
          resolve(result);
        });
    }, 2000);
  }));
}
