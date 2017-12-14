#!/bin/bash

frontlogos=$( locate logo_front.png )
bannerlogos=$( locate logo_banner.png )
flaglogos=$( locate dhis2.png )
rm /tmp/logo*.png > /dev/null
    sleep 2
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Replacing/Customising logos on all local instances **"
    if [ -f /home/hisp/custom/front.png ]; then
        cp /home/hisp/custom/front.png /tmp/logo_front.png
    else
        wget -q -P /tmp http://www.hisp.org/logos/dhis2/logo_front.png
    fi
    if [ -f /home/hisp/custom/banner.png ]; then
        cp /home/hisp/custom/banner.png /tmp/logo_banner.png
    else
        wget -q -P /tmp http://www.hisp.org/logos/dhis2/logo_banner.png
    fi
    for i in $frontlogos; do
        cp /tmp/logo_front.png $i
    done
    for i in $bannerlogos; do
        cp /tmp/logo_banner.png $i
    done
    if [ -f /home/hisp/custom/flag.png ]; then
        for i in $flaglogos; do
            cp /home/hisp/custom/flag.png $i
        done
    fi
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > ** Completed DHIS2 logo replacement **"
	echo "$timeinfo > ---------------------------------------------------------------------"
