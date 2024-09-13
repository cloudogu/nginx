# CES-Theme-Integration

The [CES-Theme-Tailwind][ces-theme-tailwind] is integrated in the Nginx-Dogu to provide the general CES styles in the Nginx-Dogu.

## Templating
A NodeJS project is defined in the [theme-build](../../theme-build) folder, which includes the [CES-Theme-Tailwind][ces-theme-tailwind]. <!-- markdown-link-check-disable-line -->

### Default styles
The default styles are integrated into every HTML page by nginx as `default.css`.
These styles are defined in the file [default.css.tpl](../../resources/var/www/html/styles/default.css.tpl). <!-- markdown-link-check-disable-line -->
The color variables are included as CSS custom properties from the [CES-Theme-Tailwind][ces-theme-tailwind].

With `yarn template-default-css` the `default.css` with all color variables is generated from the template file.

### Error pages
The error pages in the Nginx-Dogu all have the same structure and only differ in individual texts and images.
For this reason, there is only one template for the error pages: [error-page.html.tpl](../../resources/var/www/html/errors/error-page.html.tpl). <!-- markdown-link-check-disable-line -->

The error pages are generated from this template with `yarn template-error-pages`.

The configuration of the individual error pages can be found in the file [error-pages.json](../../theme-build/error-pages.json). <!-- markdown-link-check-disable-line -->




[ces-theme-tailwind]: https://github.com/cloudogu/ces-theme-tailwind/