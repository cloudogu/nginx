# Release Notes

Im Folgenden finden Sie die Release Notes für das Nginx-Dogu.

Technische Details zu einem Release finden Sie im zugehörigen [Changelog](https://docs.cloudogu.com/de/docs/dogus/nginx/CHANGELOG/).

## [Unreleased]
### Changed
- Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v1.29.4-4] - 2026-02-13
### Security
- Sicherheitslücke [CVE-2025-68121](https://avd.aquasec.com/nvd/2025/cve-2025-68121/) behoben

## [v1.29.4-3] - 2026-01-29

### Security
- Sicherheitslücke geschlossen [cve-2025-15467](https://avd.aquasec.com/nvd/2025/cve-2025-15467/)

## [v1.29.4-2] - 2026-01-19
- Fügt Mutual-TLS-Zertifikatsunterstützung hinzu

## [v1.29.4-1] - 2025-12-16
- Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v1.28.0-3] - 2025-11-25
- Nginx unterstützt TLS v1.3
- Für TLS v1.2 und v1.3 werden nur Ciphers benutzt die mit den BSI-Richtlinien kompatibel sind

## [v1.28.0-2] - 2025-06-17
- Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v1.28.0-1] - 2025-06-10
- Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v1.26.3-3] - 2025-05-26
- Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v1.26.3-2] - 2025-03-20
### Added
- Die Größen der Proxy-Buffer können jetzt über die Dogu-Konfiguration angepasst werden, wenn Requests wegen zu großen Headern fehlschlagen

## [v1.26.3-1] - 2025-02-25
- Sicherheitsupdate: Behebung einer Schwachstelle in der SSL-Sitzungswiederverwendung (CVE-2025-23419).
- Update auf eine Patch-Version

## [v1.26.2-4] - 2025-02-12
- Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v1.26.2-3] - 2025-01-28
- Der Font-Stack des Warp-Menüs wurde an das ces-theme-tailwind angepasst
- Besserer Support für Screenreader beim Auflösen von Unter-Menüpunkten als Link

## Release 1.26.2-2
- Es wird nun eine aktualisierte Liste der zugrunde liegenden Lizenzen im Warp-Menüpunkt "Über Cloudogu" angezeigt.

## Release 1.26.2-1
- nginx wurde um eine fehlerbereinigte Version aktualisiert.

## Release 1.26.1-11
- Die Dogu-Start-Seite erhält eine animierte Grafik.

## Release 1.26.1-10
- Die Cloudogu-eigenen Quellen werden von der MIT-Lizenz auf die AGPL-3.0-only relizensiert.

## Release 1.26.1-9

* Verbesserung der Barrierefreiheit der Fehlerseiten durch Hinzufügen des neuen Designs
* Die Fehlerseiten jetzt über das Whitelabeling-Dogu whitelabelbar

## Release 1.26.1-7

* Verbesserung der Barrierefreiheit des Warp-Menüs durch Hinzufügen des neuen Designs
* Das Warp-Menü ist jetzt über das Whitelabeling-Dogu whitelabelbar
