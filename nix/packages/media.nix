# Media packages: video, audio, players
{ pkgs, wrapWithNixGL }:

with pkgs; [
  (wrapWithNixGL wf-recorder)
  (wrapWithNixGL mpvpaper)

  ffmpeg
  x264
  playerctl

  # Audio
  pipewire
  wireplumber
]
