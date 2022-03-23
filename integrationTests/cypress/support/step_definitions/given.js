const {
    Given
} = require("cypress-cucumber-preprocessor/steps");


Given(/^the warp menu is open$/, function () {
    cy.visit(Cypress.config().baseUrl + Cypress.env('casPath'));
    cy.get('*[class^=" warp-menu-column-toggle"]').children('*[id^="warp-menu-warpbtn"]').click();
});