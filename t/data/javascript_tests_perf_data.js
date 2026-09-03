// javascript based tests
// use diag() to print debug messages ( only shown when tests are run in verbose mode )
// use console.error() to show errors

function test_parse_perf_data_I() {
    var inp  = "a used=2;:2;:10;1;4 b used=3;:2;:10;1;4c used=4;:2;:10;1;4 [additional information goes here=0] d used=5;:2;:10;1;4 [alternative_command] ";
    var perf = parse_perf_data(inp);

    var exp  = [
        {"key":"a used","perf":"2;:2;:10;1;4;;;;","val":2,"unit":"","warn_min":"","warn_max":2,"crit_min":"","crit_max":10,"min":1,"max":4},
        {"key":"b used","perf":"3;:2;:10;1;4;;;;","val":3,"unit":"","warn_min":"","warn_max":2,"crit_min":"","crit_max":10,"min":1,"max":4},
        {"key":"c used","perf":"4;:2;:10;1;4;;;;","val":4,"unit":"","warn_min":"","warn_max":2,"crit_min":"","crit_max":10,"min":1,"max":4},
        {"key":"d used","perf":"5;:2;:10;1;4;;;;","val":5,"unit":"","warn_min":"","warn_max":2,"crit_min":"","crit_max":10,"min":1,"max":4},
    ];

    if(obj_diff(exp, perf)) {
        console.error("got unexpected performance data:");
        console.error(JSON.stringify(perf));
        console.error(JSON.stringify(exp));
        return(0);
    }

    return(1);
}

function test_parse_perf_data_II() {
    var inp  = "'/ used'=493441925120B;763038852710;858418709299;0;953798565888 '/ used %'=51.7%;80;90;0;100 ";
    var perf = parse_perf_data(inp);

    var exp  = [
        {"key":"/ used","perf":"493441925120B;763038852710;858418709299;0;953798565888;;;;","val":493441925120,"unit":"B","warn_min":"","warn_max":763038852710,"crit_min":"","crit_max":858418709299,"min":0,"max":953798565888},
        {"key":"/ used %","perf":"51.7%;80;90;0;100;;;;","val":51.7,"unit":"%","warn_min":"","warn_max":80,"crit_min":"","crit_max":90,"min":0,"max":100},
    ];

    if(obj_diff(exp, perf)) {
        console.error("got unexpected performance data:");
        console.error(JSON.stringify(perf));
        console.error(JSON.stringify(exp));
        return(0);
    }

    return(1);
}
