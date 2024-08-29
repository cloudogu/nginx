const {
    Given
} = require("cypress-cucumber-preprocessor/steps");


Given(/^the warp menu is open$/, function () {
    cy.visit(Cypress.config().baseUrl + Cypress.env('casPath'));
    cy.get("#warp-menu-shadow-host").shadow().find("#warp-toggle").click({force: true});
});