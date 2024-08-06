const addWhitelabelClassToRoot = function () {
    document.documentElement.classList.add("ces-whitelabel")
}

const addDefaultStyles = function () {
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = "/styles/default.css"
    document.head.appendChild(link);
}

const addWhitelabelingStyles = function(){
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = "/whitelabeling/main.css"
    document.head.appendChild(link);
}

addWhitelabelClassToRoot();
addDefaultStyles();
addWhitelabelingStyles();
