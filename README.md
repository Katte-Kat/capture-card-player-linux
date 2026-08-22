# Capture Card Player for Linux

Eine kleine, portable Linux-App zum Spielen über eine Capture-Karte mit möglichst geringer Bildverzögerung. Beim Start lassen sich Videoeingang, Audioeingang und Audioausgang selbst auswählen. Die Videoliste kennzeichnet Geräte nach Möglichkeit als USB oder PCIe.

Vorgesehene Zielsysteme: KDE/GNOME unter CachyOS/Arch, Fedora, Bazzite und SteamOS im Desktop-Modus. **USB- und PCIe-Capture-Karten werden gleichwertig durchsucht.** Sie funktionieren, wenn sie von Linux als V4L2-Videogerät (`/dev/video*`) erkannt werden. Elgato-Modelle sind daher grundsätzlich möglich; die konkrete Karte braucht aber einen funktionierenden Linux-Treiber. Audio wird separat aus sämtlichen PipeWire-/PulseAudio-Eingängen gewählt, da es bei PCIe-Karten als eigener Audioknoten auftauchen kann.

## Installation

1. Archiv entpacken.
2. Im entpackten Ordner `bash install.sh` ausführen.
3. Danach **Capture Card Player for Linux** aus dem App-Menü starten und auf Wunsch an die Taskleiste anheften.

Der Installer schreibt nur nach `~/.local/bin` und `~/.local/share/applications`. Falls kein mpv vorhanden ist, bietet er auf Bazzite/SteamOS die Installation des Flathub-mpv und auf normalen Arch-/Fedora-Systemen eine passende native Installation an.

## Bedienung

Beim Start erscheinen nacheinander:

1. Videoeingang
2. Audioeingang oder „Kein Audio“
3. Audioausgang oder „Systemstandard“

„Systemstandard“ gibt den Ton über den beim Start aktuellen Standardausgang wieder. Wenn du den Ausgang während des Spielens umschaltest und der Stream nicht mitwandert, Capture Card Player for Linux kurz neu starten.

Das Bild läuft getrennt vom Ton mit `--profile=low-latency --untimed`, damit die Audiosynchronisation nicht wieder einen sichtbaren Bildpuffer erzeugt. `F` schaltet in mpv zwischen Vollbild und Fenster um, `Q` beendet die App und damit auch den Audiostream.

## Bazzite und SteamOS

Im Desktop-Modus installieren und testen. Für den Gaming-Modus kann die App danach in Steam über **Spiel hinzufügen → Steam-fremdes Spiel hinzufügen** aufgenommen werden. Die Geräteauswahl funktioniert am zuverlässigsten im Desktop-Modus.

## Fehlerbehebung

- **Videoquelle fehlt:** Mit `ls -l /dev/video*` prüfen. OBS darf die Karte nicht gleichzeitig geöffnet haben.
- **Mehrere gleichnamige Videoquellen:** Nacheinander testen. Capture-Karten stellen häufig mehr als einen V4L2-Knoten bereit.
- **Audioquelle fehlt:** Mit `pactl list short sources` prüfen. Bei PCIe-Karten kann Audio auch als separater ALSA/PipeWire-Eingang erscheinen.
- **Kein Ton:** Für Arch/CachyOS wird typischerweise `libpulse`, für Fedora `pulseaudio-utils` benötigt. Alternativ funktionieren `wpctl` und `pw-loopback` aus PipeWire.
- **Flathub-mpv sieht die Karte nicht:** `flatpak override --user --device=all io.mpv.Mpv` ausführen und erneut testen.

## Deinstallation

Im entpackten Ordner:

```bash
bash uninstall.sh
```

Eine eventuell zuvor angelegte Sicherung der Desktop-Datei wird absichtlich nicht gelöscht.


## Lizenz

MIT – siehe [LICENSE](LICENSE).
