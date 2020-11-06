var link = document.createElement("link");
link.rel = "stylesheet";
link.href = "/popup/popup.css"
var x = document.getElementsByTagName("script")[0];
x.parentNode.insertBefore(link, x);


var body = document.getElementsByTagName("body")[0];

var outer = document.createElement("div");
outer.className = "outer";
var inner = document.createElement("div");
inner.className = "inner";
outer.appendChild(inner);

console.log(body);
console.log(outer);

body.appendChild(outer);


