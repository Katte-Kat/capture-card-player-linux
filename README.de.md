# Capture Card Player for Linux

[English](README.md) | [Deutsch](README.de.md)

Eine kleine Linux-Anwendung, um über eine Capture-Karte mit möglichst geringer Bildverzögerung zu spielen. Beim Start lassen sich Videoeingang, Audioeingang und Audioausgang auswählen.

USB- und PCIe-Capture-Karten werden auf dieselbe Weise erkannt. Eine Karte wird unterstützt, wenn Linux sie als standardmäßiges V4L2-Gerät unter `/dev/video*` bereitstellt. Audio wird separat über PipeWire oder PulseAudio ausgewählt. Dadurch werden auch PCIe-Karten unterstützt, die Audio als eigenen Eingang bereitstellen.

## Funktionen

- Videoeingang bei jedem Start auswählen
- Beliebigen PipeWire- oder PulseAudio-Eingang auswählen
- Bestimmten Audioausgang oder den Systemstandard verwenden
- Unterstützung für USB- und PCIe-Capture-Karten
- Kennzeichnung als USB oder PCIe, wenn diese Information verfügbar ist
- Getrennte Video- und Audiowege für geringe Verzögerung
- Unterstützung für natives mpv und das Flathub-mpv-Paket
- Grafische Oberfläche über KDialog oder Zenity mit Terminal-Ausweichlösung
- Automatisch deutsche oder englische Oberfläche entsprechend der Systemlocale
- Installation im Benutzerkonto ohne Anwendungsdateien in Systemverzeichnisse zu schreiben

## Unterstützte Systeme

| System | Unterstützte Einrichtung |
| --- | --- |
| Arch Linux / CachyOS | Natives mpv oder Flatpak |
| Fedora | Natives mpv oder Flatpak |
| Bazzite | Flathub-mpv im Desktop-Modus |
| SteamOS | Flathub-mpv im Desktop-Modus |

Für die Capture-Karte wird weiterhin ein funktionierender Linux-Treiber benötigt. Elgato-Karten können funktionieren, wenn sie als normale V4L2-Geräte erscheinen. Karten, die ausschließlich über ein herstellerspezifisches OBS-Plugin verfügbar sind, werden nicht direkt unterstützt.

## Installation

Repository klonen und Installer ausführen:

```bash
git clone https://github.com/Katte-Kat/capture-card-player-linux.git
cd capture-card-player-linux
bash install.sh
```

Danach **Capture Card Player for Linux** aus dem Anwendungsmenü starten und bei Bedarf an die Taskleiste anheften.

Der Installer schreibt Anwendungsdateien ausschließlich nach:

- `~/.local/bin`
- `~/.local/share/applications`

Falls mpv fehlt, bietet der Installer unter Bazzite/SteamOS das Flathub-mpv-Paket und unter normalen Arch-/Fedora-Systemen ein passendes natives Paket an.

## Bedienung

Beim Start fragt die Anwendung nacheinander nach:

1. Videoeingang
2. Audioeingang oder **Kein Audio**
3. Audioausgang oder **Systemstandard**

**Systemstandard** verwendet den Ausgang, der beim Start der Wiedergabe aktiv ist. Falls der Audiostream nach einer Änderung des Systemausgangs nicht automatisch mitwandert, die Anwendung neu starten.

Das Video läuft getrennt mit:

```text
--profile=low-latency --untimed --no-audio
```

Dadurch erzeugt die Audiosynchronisation keinen sichtbaren Videopuffer. Mit `F` wird in mpv zwischen Vollbild und Fenster gewechselt. `Q` beendet den Player und den Audiostream.

## Sprache

Anwendung, Installer und Uninstaller verwenden automatisch Deutsch, wenn die aktive Locale mit `de` beginnt; ansonsten wird Englisch verwendet. Die Sprache kann bei Bedarf erzwungen werden:

```bash
CAPTURE_CARD_PLAYER_LANG=de capture-card-player
CAPTURE_CARD_PLAYER_LANG=en capture-card-player
```

## Bazzite und SteamOS

Die Anwendung im Desktop-Modus installieren und testen. Anschließend kann sie über **Spiel hinzufügen → Steam-fremdes Spiel hinzufügen** in Steam aufgenommen werden. Die Geräteauswahl funktioniert im Desktop-Modus am zuverlässigsten.

## Fehlerbehebung

- **Keine Videoquelle:** `ls -l /dev/video*` ausführen. OBS oder eine andere Anwendung darf die Karte nicht gleichzeitig geöffnet haben.
- **Mehrere Videoquellen mit demselben Namen:** Nacheinander testen. Capture-Karten stellen häufig mehr als einen V4L2-Knoten bereit.
- **Keine Audioquelle:** `pactl list short sources` ausführen. Eine PCIe-Karte kann Audio als eigenen ALSA-/PipeWire-Eingang bereitstellen.
- **Keine Audiowiedergabe:** Arch/CachyOS benötigt üblicherweise `libpulse`, Fedora üblicherweise `pulseaudio-utils`. Alternativ werden `wpctl` und `pw-loopback` von PipeWire unterstützt.
- **Flathub-mpv kann nicht auf die Karte zugreifen:** `flatpak override --user --device=all io.mpv.Mpv` ausführen und erneut versuchen.
- **Die Karte erscheint nur über ein OBS-Plugin:** Die Anwendung benötigt ein standardmäßiges V4L2-Gerät unter `/dev/video*`.

## Deinstallation

Im geklonten Projektverzeichnis ausführen:

```bash
bash uninstall.sh
```

Ein vorhandenes Backup des Desktop-Eintrags bleibt absichtlich erhalten.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).

*Mit Unterstützung von KI erstellt.*
