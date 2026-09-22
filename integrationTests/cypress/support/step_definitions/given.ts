import {Given} from "@badeball/cypress-cucumber-preprocessor";

Given(/^the warp menu is open$/, function () {
    cy.visit(Cypress.config().baseUrl + Cypress.expose('casPath'));
    cy.get("#warp-menu-shadow-host").shadow().find("#warp-toggle").click({force: true});
});