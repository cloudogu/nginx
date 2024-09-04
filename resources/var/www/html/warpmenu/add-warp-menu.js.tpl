const addWarpMenu = function(){
    const warpScript = document.createElement("script");
    warpScript.type = "text/javascript";
    // Update this version whenever warp menu is updated
    warpScript.src = "/warp/warp.js?nginx={{ .Env.Get "VERSION"}}";

    const urlScript = document.createElement("script");
    // This variable is used inside the warp menu script
    // Update this version whenever warp menu is updated

    const firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(warpScript, firstScriptTag);
}

const cesWarpMenuWarpCssUrl = "/warp/warp.css?nginx={{ .Env.Get "VERSION"}}";
addWarpMenu();