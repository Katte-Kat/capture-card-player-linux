# Capture Card Player for Linux

[English](README.md) | [Deutsch](README.de.md)

Eine kleine Linux-Anwendung, um über eine Capture-Karte mit möglichst geringer Bildverzögerung zu spielen. Beim Start lassen sich Videoeingang, Audioeingang und Audioausgang auswählen.

USB- und PCIe-Capture-Karten werden auf dieselbe Weise erkannt. Eine Karte wird unterstützt, wenn Linux sie als standardmäßiges V4L2-Gerät unter `/dev/video*` bereitstellt. Audio wird separat über PipeWire oder PulseAudio ausgewählt. Dadurch werden auch PCIe-Karten unterstützt, die Audio als eigenen Eingang bereitstellen.

## Funktionen

- Ausgewählte Geräte speichern und beim nächsten Start erneut verwenden
- Zwischen gespeicherten Einstellungen und einer neuen Geräteauswahl wählen
- Capture-Auflösung und Bildrate auswählen, statt den Gerätestandard zu verwenden
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

## Aktualisierung

Repository aktualisieren und die Anwendungsdateien erneut installieren mit:

```bash
cd ~/capture-card-player-linux
git pull --ff-only
bash install.sh
```

Den laufenden Player vor der Aktualisierung schließen und die Anwendung anschließend erneut über das Anwendungsmenü starten.

## Bedienung

Beim ersten Start fragt die Anwendung nacheinander nach:

1. Videoeingang
2. Videoauflösung
3. Bildrate
4. Audioeingang oder **Kein Audio**
5. Audioausgang oder **Systemstandard**

Der ausgewählte Videomodus und die Geräte werden unter `~/.config/capture-card-player/settings` gespeichert (oder unterhalb von `$XDG_CONFIG_HOME`, falls gesetzt). Bei späteren Starts fragt das erste Menü, ob die gespeicherten Einstellungen verwendet oder alles neu ausgewählt werden soll. Ist ein gespeichertes Gerät oder ein Videomodus nicht mehr verfügbar, wechselt die Anwendung automatisch zurück zur Auswahl.

**Systemstandard** verwendet den Ausgang, der beim Start der Wiedergabe aktiv ist. Falls der Audiostream nach einer Änderung des Systemausgangs nicht automatisch mitwandert, die Anwendung neu starten.

Das Video läuft getrennt mit:

```text
--demuxer-lavf-o=video_size=1920x1080,framerate=60,input_format=yuyv422
--profile=low-latency --untimed --no-audio
```

Die erste Option wird aus dem ausgewählten Modus erzeugt und verhindert beispielsweise, dass eine Capture-Karte auf 3840x2160 mit nur 18 FPS zurückfällt. Die übrigen Optionen verhindern einen sichtbaren Videopuffer durch die Audiosynchronisation. Mit `F` wird in mpv zwischen Vollbild und Fenster gewechselt. `Q` beendet den Player und den Audiostream.

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
- **Das Bild ruckelt nach einem Neustart:** Alles neu auswählen und 1920x1080 mit 60 FPS statt eines langsamen 4K-Modus wählen.
- **Keine Audioquelle:** `pactl list short sources` ausführen. Eine PCIe-Karte kann Audio als eigenen ALSA-/PipeWire-Eingang bereitstellen.
- **Das Audio der Capture-Karte fehlt in der Liste (z. B. Elgato HD60 S):** Der Treiber veröffentlicht eine PipeWire-eigene Quelle, die ein klassischer PulseAudio-Server (Standard bei Linux Mint) vor `pactl` verbirgt. `wireplumber` und `pipewire` installieren, damit `wpctl` und `pw-loopback` vorhanden sind — der Player fragt dann PipeWire direkt ab und der Eingang erscheint. Alternativ den Host auf `pipewire-pulse` umstellen.
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
