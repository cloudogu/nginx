import { defineConfig } from "cypress";
// @ts-ignore
import createBundler from "@bahmutov/cypress-esbuild-preprocessor";
import { addCucumberPreprocessorPlugin } from "@badeball/cypress-cucumber-preprocessor";
import createEsbuildPlugin from "@badeball/cypress-cucumber-preprocessor/esbuild";

async function setupNodeEvents(on, config) {
    // This is required for the preprocessor to be able to generate JSON reports after each run, and more,
    await addCucumberPreprocessorPlugin(on, config);

    on(
        "file:preprocessor",
        createBundler({
            plugins: [createEsbuildPlugin(config)],
        })
    );

    return config;
}

module.exports = defineConfig({
    e2e: {
        pageLoadTimeout: 60000,

        retries: {
            runMode: 3,
            openMode: 3,
        },

        baseUrl: "https://192.168.56.10",

        env: {
            casPath: "/cas",
            nameOfCustomPageLinkInWarpMenu: "Privacy Policies",
            customHTMLPath: "/static/privacy_policies.html",
            AdminGroup: "CesAdministrators",
        },

        videoCompression: false,
        specPattern: ["cypress/e2e/**/*.feature"],

        setupNodeEvents,
    }

});
