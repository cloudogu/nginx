const addWarpMenu = function(){
    var s = document.createElement("script");
    s.type = "text/javascript";
    s.src = "/warp/warp.js";
    var x = document.getElementsByTagName("script")[0];
    x.parentNode.insertBefore(s, x);
}

addWarpMenu();