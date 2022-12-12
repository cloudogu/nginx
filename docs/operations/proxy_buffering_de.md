# Request Buffering

Wenn das Buffering aktiviert ist, erhält nginx die Antwort auf eine Seitenabfrage so schnell wie möglich und speichert diese
in den Buffer des Nginx-Dogus, um diese dann von dort aus Stück für Stück weiter zu geben. Das verbessert die Performance für
Nutzer mit langsamen Internetverbindungen.
Das Buffering kann für einzelne Dogus aktiviert/deaktiviert werden. Dafür muss ein Registry-key im folgenden Format gesetzt werden:
```
/config/nginx/buffering/<doguname> = on|off
```
Ist kein Wert gesetzt, ist das Buffering immer aktiviert.
