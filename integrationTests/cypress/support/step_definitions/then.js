const {
    Then
} = require("cypress-cucumber-preprocessor/steps");

Then(/^the user opens the warp menu$/, function () {
   cy.get('*[class^=" warp-menu-column-toggle"]').children('*[id^="warp-menu-warpbtn"]').click();
});

Then(/^the user checks link corresponding to the custom page$/, function () {
    cy.get('*[class^=" warp-menu-shift-container"]')
        .children('*[class^=" warp-menu-category-list"]')
        .contains(Cypress.env('nameOfCustomPageLinkInWarpMenu'))
        .should('have.attr', 'target', '_blank');
});

Then("a static HTML custom page gets displayed", function () {
    cy.visit(Cypress.config().baseUrl + Cypress.env('customHTMLPath'));
});