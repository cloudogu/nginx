const fs = require('fs');
const _ = require("lodash");
const path = require("path");


const pages = require("./error-pages.json")

function createErrorPages() {
    const args = process.argv.slice(2);
    if (args.length !== 2) {
        console.error("wrong arguments. Must be 2");
        return
    }

    const version = process.env.VERSION?? "v0";

    const template = args[0];
    const dstDir = args[1];

    const templateData = fs.readFileSync(template);
    const compiledTemplate = _.template(templateData)

    // make sure that the destination-dir exists
    fs.mkdirSync(dstDir, {recursive: true});

    // template pages
    for (const page of pages) {
        const renderedPage = compiledTemplate({version: version, ...page})

        const pageFile = `${dstDir}/${page.name}`;
        console.log("creating page", pageFile);
        fs.writeFileSync(pageFile, renderedPage);
    }
}
createErrorPages();



