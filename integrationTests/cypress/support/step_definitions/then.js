const {
    Then
} = require("cypress-cucumber-preprocessor/steps");

Then("a static HTML custom page gets displayed", function () {
    cy.visit(Cypress.env('CustomHTMLPath'));
});