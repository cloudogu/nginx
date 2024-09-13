# CES-Theme-Integration

Im Nginx-Dogu wird das [CES-Theme-Tailwind][ces-theme-tailwind] an eingebunden um die allgemeine CES-Styles im Nginx-Dogu bereitzustellen.

## Templating
Im Ordner [theme-build](../../theme-build) ist eine NodeJS-projekt definiert, das das [CES-Theme-Tailwind][ces-theme-tailwind] inkludiert. <!-- markdown-link-check-disable-line -->

### Default-Styles
Die Default-Styles werden vom nginx als `default.css` in jede HTML-Seite eingebunden.
Diese Styles sind in der Datei [default.css.tpl](../../resources/var/www/html/styles/default.css.tpl) definiert. <!-- markdown-link-check-disable-line -->
Dabei werden die Farb-Variablen als CSS-Custom-Properties aus dem [CES-Theme-Tailwind][ces-theme-tailwind] inkludiert.

Mit `yarn template-default-css` wird aus der Template-Datei die `default.css` mit allen Farb-Variablen generiert. 


### Error-Pages
Die Error-Pages im Nginx-Dogu sind alle gleich aufgebaut und unterscheiden sich nur durch einzelne Texte und Bilder.
Aus diesem Grund gibt es auch nur ein Template für die Error-Pages: [error-page.html.tpl](../../resources/var/www/html/errors/error-page.html.tpl). <!-- markdown-link-check-disable-line -->

Aus diesem Template werden mit `yarn template-error-pages` die error-pages generiert.

Die Konfiguration der einzelnen Error-Pages ist in der Datei [error-pages.json](../../theme-build/error-pages.json) zu finden. <!-- markdown-link-check-disable-line -->




[ces-theme-tailwind]: https://github.com/cloudogu/ces-theme-tailwind/