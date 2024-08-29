import {When} from "@badeball/cypress-cucumber-preprocessor";

When(/^the user opens the always existing cas ui$/, function () {
    cy.visit(Cypress.config().baseUrl + Cypress.env('casPath'));
});

When(/^the user requests the static custom HTML page$/, function () {
    cy.request(Cypress.env('customHTMLPath'));
});
