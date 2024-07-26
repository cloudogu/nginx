const addWhitelabelClassToRoot = function () {
    document.documentElement.classList.add("ces-whitelabel")
}

const addDefaultStyles = function () {
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = "/styles/default.css"
    var element = document.getElementsByTagName("link")[0];
    element.parentNode.insertBefore(link, element);
}

const addWhitelabelingStyles = function(){
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = "/whitelabeling/main.css"
    var element = document.getElementsByTagName("link")[1];
    element.parentNode.insertBefore(link, element);
}

addWhitelabelClassToRoot();
addDefaultStyles();
addWhitelabelingStyles();
