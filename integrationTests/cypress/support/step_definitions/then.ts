import {Then} from "@badeball/cypress-cucumber-preprocessor";

Then(/^the user opens the warp menu$/, function () {
    cy.get("#warp-menu-shadow-host").shadow().find("#warp-toggle").click({force: true});
});

Then(/^the user checks link corresponding to the custom page$/, function () {
    cy.get("#warp-menu-shadow-host").shadow().find(`a[href="${Cypress.env('customHTMLPath')}"]`)
        .should('have.attr', 'target', '_blank')
        .contains(Cypress.env('nameOfCustomPageLinkInWarpMenu'));
});

Then("a static HTML custom page gets displayed", function () {
    cy.visit(Cypress.config().baseUrl + Cypress.env('customHTMLPath'));
});

Then(/^the warp menu category 'Support' contains a link to docs and no link to platform or the about page$/, function () {
    cy.get("#warp-menu-shadow-host").shadow().find('[id^=warpc][id$=support]').parent().children('ul').children().should('have.length', 1)
    cy.get("#warp-menu-shadow-host").shadow().find('[id^=warpc][id$=support]').parent().children('ul').children('li').contains("Cloudogu EcoSystem documentation")
});