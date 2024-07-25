const addWhitelabelClassToRoot = function () {
    document.documentElement.classList.add("ces-whitelabel")
}

const addDefaultStyles = function () {
    var s = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = "/styles/default.css"
    var x = document.getElementsByTagName("link")[0];
    x.parentNode.insertBefore(s, x);
}

const addWhitelabelingStyles = function(){
    var s = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = "/whitelabeling/main.css"
    var x = document.getElementsByTagName("style")[0];
    x.parentNode.insertBefore(s, x);
}

addWhitelabelClassToRoot();
addDefaultStyles();
addWhitelabelingStyles();
