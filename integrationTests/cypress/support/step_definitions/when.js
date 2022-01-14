const {
    When
} = require("cypress-cucumber-preprocessor/steps");

When(/^the user requests the static custom HTML page$/, function () {
    cy.request(Cypress.env('CustomHTMLPath'));
});