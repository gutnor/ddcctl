#!/bin/bash
###########
## Synchronize external display brightness with MacBook Display.
##      Useful to benefit from "auto-adjust brightness setting" on the external display.
##      Can be used in that fashion with a cron job
##      eg: * * * * * /Users/bob/syncbrightness.sh >> /Users/bob/syncbrightness.log 2>&1
##
## Tested on a Benq BL2420U (note: didn't like the built-in eyecare feature, too bright IMO )
##
## Depends on brightness command line [https://github.com/nriley/brightness]
##      Install using 'brew install brightness'
###########

# Benq BL2420U causes the Mac to crash when querying the current brightness.
# Workaround, save the set brightness in the following temporary file.
BENQ_CURRENT=/var/tmp/benqcurrentbrightness
# Offset between the Mac and External Display brightness.
BENQ_OFFSET=-5

PATH=".:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

set -e -o pipefail

cd $(dirname "$0")

log() {
    timestamp=`date "+%F %T"`
    echo "[$timestamp]: $1"
}

mbpBrightness=`brightness -l 2> /dev/null | grep "display 0: brightness" | cut -c 23-27`

if [ "$mbpBrightness" = "1.000" ]; then
    targetBrightness=100
else
    targetBrightness=`echo "$mbpBrightness" | cut -c 3-4`
fi

targetBrightness=$[$targetBrightness + $BENQ_OFFSET]

if [ -f $BENQ_CURRENT ]; then
    currentBrightness=`cat $BENQ_CURRENT`
else
    currentBrightness="not set"
fi

if [ "$targetBrightness" == "$currentBrightness" ]; then
    log "           (mbp=$mbpBrightness, offset=$BENQ_OFFSET, benq=$targetBrightness)"
else
    log "Sync to $targetBrightness (mbp=$mbpBrightness, offset=$BENQ_OFFSET, benq=$targetBrightness)"
    ddcctl -d 2 -b $targetBrightness > /dev/null 2>&1
    echo $targetBrightness > $BENQ_CURRENT
fi