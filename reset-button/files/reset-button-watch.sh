#!/bin/sh
#
# Basic reset button handler for VP-series hardware.
# Reboots and resets config if button is pressed.
#

check_supported_series() {
  SYSTEM_VENDOR="$(dmidecode -s system-manufacturer)"
  SYSTEM_MODEL="$(dmidecode -s system-product-name)"
  BIOS_VERSION="$(dmidecode -s bios-version)"
  case "$SYSTEM_VENDOR" in
  "Protectli")
    case "$SYSTEM_MODEL" in
    "V1210" | "V1211" | "V1410" | "V1610")
      logger -t "$LOGTAG" "V1xxx series does not support factory reset via reset button"
      exit 1
      ;;
    "VP2420")
      if [[ "$BIOS_VERSION" == *coreboot* ]]; then
        logger -t "$LOGTAG" "Factory reset on $SYSTEM_VENDOR $SYSTEM_MODEL is currently not supported with coreboot"
        exit 1
      fi
      ;;
    "VP2430" | "VP2440" | "VP4630" | "VP4650" | "VP4651" | "VP4670" | "VP6650" | "VP6670")
      PORT=0xa00    # I/O port address
      MASK=0x04     # Bit 2: 0 = pressed, 1 = not pressed
      ;;
    *)
      logger -t "$LOGTAG" "Board model $SYSTEM_MODEL is currently not supported"
      exit 1
      ;;
    esac
    ;;
  *)
    logger -t "$LOGTAG" "This script is meant to run on Protectli hardware, not on $SYSTEM_VENDOR's"
    exit 1
    ;;
  esac
}

INTERVAL=1      # polling interval (seconds)
LOGTAG="reset-button-watch"
check_supported_series
logger -t "$LOGTAG" "started"

COUNTER=0

while :; do
    byte=$(dd if=/dev/port bs=1 skip=$((PORT)) count=1 2>/dev/null \
           | hexdump -v -e '1/1 "%u"')

    [ -z "$byte" ] && { logger -t "$LOGTAG" "read error - exiting"; exit 1; }

    if [ $((byte & MASK)) -eq 0 ]; then
        # Button is pressed - increment counter
        COUNTER=$((COUNTER + 1))

        if [ "$COUNTER" -eq 10 ]; then
            # Button has been pressed for 10s in a row, perform factory reset
            logger -t "$LOGTAG" "button held 10 s - factory reset initiated"
            firstboot -y
            reboot
            exit 0
        fi
    else
        COUNTER=0
    fi

    sleep "$INTERVAL"
done
