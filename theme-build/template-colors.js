const cm = require('@cloudogu/ces-theme-tailwind/config/colormapping.cjs');
const fs = require("fs");
const path = require("path");
const _ = require('lodash');

function createColors() {
    let colors = "";
    for (const variablesKey in cm.variables) {
        colors += `${variablesKey}: ${cm.variables[variablesKey]};\n\t`
    }

    return colors
}

function addColorsToDefaultCss() {
    const args = process.argv.slice(2);
    if (args.length !== 2) {
        console.error("wrong arguments. Must be 2");
        return
    }

    const src = args[0];
    const dst = args[1];

    const srcData = fs.readFileSync(src);

    // template
    const compiledTemplate = _.template(srcData)
    const dstData = compiledTemplate({colors: createColors()})


    // make sure that the destination-dir exists
    const dstDir = path.dirname(dst);
    fs.mkdirSync(dstDir, {recursive: true});

    console.log("creating default-css at", dst);
    fs.writeFileSync(dst, dstData);
}

addColorsToDefaultCss();