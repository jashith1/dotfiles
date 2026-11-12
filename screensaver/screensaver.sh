#!/usr/bin/env bash
# ASCII screensaver for Hyprland, built on terminaltexteffects (tte) + kitty.
#
#   screensaver.sh         open a fullscreen screensaver on every monitor
#                          (this is what hypridle should call)
#   screensaver.sh --run   the screensaver itself; runs inside each kitty window
#
# Any key press or mouse movement dismisses the screensaver on every monitor.
#
# There is deliberately no hypridle `on-resume` hook: opening a window resets
# hypridle's idle timer, so such a hook would close the screensaver instantly.

# ── Settings ─────────────────────────────────────────────────────────────────
CLASS=screensaver                 # kitty window class
ART="${SCREENSAVER_ART:-${XDG_CONFIG_HOME:-$HOME/.config}/screensaver/art.txt}"
FRAME_RATE=${SCREENSAVER_FRAME_RATE:-60}
HOLD=${SCREENSAVER_HOLD:-2}          # seconds to show the finished art before the next effect
EFFECT_ARGS=(--random-effect)     # e.g. SCREENSAVER_EFFECT=decrypt to pin one effect
GRACE=1                           # seconds to ignore the mouse after launch
MOVE_THRESHOLD=3                  # pixels of cursor travel that count as movement
FIT_MARGIN=95                     # art fills this % of the screen when scaled

[[ -n ${SCREENSAVER_EFFECT:-} ]] && EFFECT_ARGS=("$SCREENSAVER_EFFECT")

SELF=$(readlink -f "${BASH_SOURCE[0]}")
# Matches only the kitty processes we start, not anything that mentions the class.
PROCESS_PATTERN="(^|/)kitty --class $CLASS "

# kitty options for the screensaver window.
KITTY_OPTS=(
  --start-as=fullscreen
  -o background=#000000
  -o background_opacity=1          # fully opaque, ignoring kitty.conf
  -o window_padding_width=0
  -o placement_strategy=center     # split leftover pixels evenly, keeps art centered
  -o confirm_os_window_close=0
  -o allow_remote_control=yes      # needed by fit_font to resize the font
)

# ── Helpers ──────────────────────────────────────────────────────────────────

# Timestamped trace to $SCREENSAVER_DEBUG (no-op when unset).
debug() { [[ -n ${SCREENSAVER_DEBUG:-} ]] && echo "$EPOCHREALTIME $*" >> "$SCREENSAVER_DEBUG"; return 0; }

# Show or hide the mouse pointer (Hyprland's Lua config, with legacy fallback).
set_pointer_hidden() { # $1: true | false
  hyprctl eval "hl.config({ cursor = { invisible = $1 } })" &>/dev/null ||
    hyprctl keyword cursor:invisible "$1" &>/dev/null
}

# Block until the terminal grid stops changing (fullscreen / font reflow done),
# instead of sleeping a fixed time. Gives up after ~2s.
wait_for_stable_size() {
  local previous='' current stable=0 attempt
  for ((attempt = 0; attempt < 40 && stable < 3; attempt++)); do
    current="$(tput lines)x$(tput cols)"
    if [[ $current == "$previous" ]]; then ((stable++)); else stable=0; fi
    previous=$current
    sleep 0.05
  done
}

# Scale kitty's font so the art fills the terminal. Cell size is proportional to
# font size, so multiply by how many times the art fits, limited by the tighter axis.
fit_font() {
  command -v kitten &>/dev/null || return 0
  local art_w art_h cols rows by_width by_height scale
  wait_for_stable_size
  art_w=$(wc -L < "$ART")
  art_h=$(wc -l < "$ART")
  ((art_w > 0 && art_h > 0)) || return 0

  cols=$(tput cols)
  rows=$(tput lines)
  by_width=$((cols * 1000 / art_w))
  by_height=$((rows * 1000 / art_h))
  scale=$((by_width < by_height ? by_width : by_height))
  scale=$((scale * FIT_MARGIN / 100))

  printf -v scale '%d.%03d' $((scale / 1000)) $((scale % 1000))
  debug "fit: grid ${cols}x${rows} art=${art_w}x${art_h} scale=$scale"
  kitten @ set-font-size "*$scale" &>/dev/null
  wait_for_stable_size
  debug "fit: done, grid $(tput cols)x$(tput lines)"
}

# Loop random effects until killed. Each pass clears the screen first so no
# remnants of the previous effect survive, and keeps the text cursor hidden.
animate() {
  while :; do
    printf '\033[?25l\033[2J\033[H'
    debug "animate: tte starting"
    # A named effect is a subcommand, so it must come after all options.
    tte --frame-rate "$FRAME_RATE" --no-restore-cursor --no-eol \
      --canvas-width 0 --canvas-height "$(tput lines)" \
      --anchor-canvas c --anchor-text c "${EFFECT_ARGS[@]}" < "$ART"
    sleep "$HOLD"
  done
}

# ── Launcher ─────────────────────────────────────────────────────────────────

launch() {
  pgrep -f -- "$PROCESS_PATTERN" &>/dev/null && exit 0 # already running
  command -v tte &>/dev/null || { echo "screensaver: tte not found" >&2; exit 1; }

  # Hyprland uses the Lua config, so start windows with hl.exec_cmd and a
  # [monitor X] rule to place one on each display.
  # Hyprland starts the windows, so they don't inherit our environment:
  # forward SCREENSAVER_* overrides explicitly.
  local name env_opts=()
  for name in SCREENSAVER_ART SCREENSAVER_EFFECT SCREENSAVER_DEBUG SCREENSAVER_FRAME_RATE SCREENSAVER_HOLD; do
    [[ -n ${!name:-} ]] && env_opts+=(-o "env=$name=${!name}")
  done

  local monitor
  for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl eval "hl.exec_cmd(\"[monitor $monitor] kitty --class $CLASS ${KITTY_OPTS[*]} ${env_opts[*]} -e bash $SELF --run\")" &>/dev/null
  done
}

# ── Screensaver (runs inside each window) ────────────────────────────────────

run() {
  local animation_pid=''

  cleanup() {
    trap - EXIT INT TERM HUP
    if [[ -n $animation_pid ]]; then
      pkill -P "$animation_pid" 2>/dev/null # tte
      kill "$animation_pid" 2>/dev/null     # the loop
    fi
    set_pointer_hidden false
    pkill -f -- "$PROCESS_PATTERN" 2>/dev/null # dismiss windows on other monitors
    exit 0
  }
  trap cleanup EXIT INT TERM HUP

  debug "run: start"
  set_pointer_hidden true
  printf '\033[?25l' # hide the terminal's text cursor
  debug "run: pointer hidden"

  fit_font

  debug "run: starting animation"
  animate &
  animation_pid=$!

  # Grace period: ignore mouse noise from the window opening (a key still exits),
  # then remember where the pointer is. The animation is already playing.
  read -rsn1 -t "$GRACE" && exit 0
  local start_x start_y x y
  IFS=', ' read -r start_x start_y < <(hyprctl cursorpos)

  # Watch for input. `read` times out after 0.1s (non-zero) unless a key arrives.
  while :; do
    read -rsn1 -t 0.1 && exit 0
    IFS=', ' read -r x y < <(hyprctl cursorpos)
    [[ -n $x && -n $y ]] || continue
    if ((x - start_x > MOVE_THRESHOLD || start_x - x > MOVE_THRESHOLD ||
         y - start_y > MOVE_THRESHOLD || start_y - y > MOVE_THRESHOLD)); then
      exit 0
    fi
  done
}

case "${1:-}" in
  --run) run ;;
  *) launch ;;
esac
