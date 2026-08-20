// javascript based tests
// use diag() to print debug messages ( only shown when tests are run in verbose mode )
// use console.error() to show errors

function test_parse_perf_data() {
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
