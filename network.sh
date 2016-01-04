#!/bin/bash

# Network status


# User assigned array.  List the ssid's you wish to consider "safe"
# safeNetworksArray=("ssid_1" "ssid_2" "ssid_3")
safeNetworksArray=("PoohCorner" "712-100")

# fontawesome classes
iconGood="<i class='fa fa-check-circle green'></i>"
iconAlert="<i class='fa fa-times-circle red'></i>"
iconWifi="<i class='fa fa-wifi'></i>"
iconWorld="<i class='fa fa-globe'></i>"
iconRoute=" <i class='fa fa-sign-out blue'></i>"

# get some interfaces
wirelessDevice=$(networksetup -listallhardwareports | grep -Ei -A 1 '(Wi-Fi|Airport)' | grep en | sed -n 's/Device/&/p' | awk '{print $2}' | sort)
wiredDevice=$(networksetup -listallhardwareports | grep -Ei -A 1 '(Thunderbolt|Ethernet|iPhone)' | grep en | sed -n 's/Device/&/p' | awk '{print $2}' | sort)

# get default route
defaultRoute=$(route -n get default | grep -o "interface: .*" | awk '{print $2}')

array_contains() {
# for going through the contents of an array
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

displayWirelessInterface() {
    # get current SSID - and check it against the array
    currentNetwork=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk -F: '/ SSID: / {print $2}' | sed -e 's/SSID: //' | sed -e 's/ //')
    
    # no current network check to see if wifi card is off/inactive, or disconnected
    if [ -z "$currentNetwork" ]; then
        airportStatus=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk -F: '/AirPort: / {print $2}' | tr -d '[[:space:]]')
        if [ -z "$airportStatus" ]; then
            echo "<tr><td><span class='red'>$iconWifi</span></td><td>Wi-Fi</td><td><span class='red'>Not Connected</span></td></tr>"
        else
            echo "<tr><td><span class='red'>$iconWifi</span></td><td>Wi-Fi</td><td><span class='red'>$airportStatus</span></td></tr>"
        fi
    else
        array_contains safeNetworksArray "${currentNetwork}" && safeNetwork=1 || safeNetwork=0

        # display wireless device information
        wirelessIP=$(ipconfig getifaddr $1)

        if [ "$safeNetwork" != "1" ];then
#            echo "<tr><td><span class='red'>$iconWifi</span></td><td>Network SSID</td><td><span class='red'>$currentNetwork</span></td></tr>"
            echo "<tr><td><span class='red'>$iconWifi</span></td><td><span class='red'>$currentNetwork ($1)</span></td><td><span class='red'>$wirelessIP</span></td></tr>"
        else
 #           echo "<tr><td><span class='green'>$iconWifi</span></td><td>Network SSID</td><td><span class='green'>$currentNetwork</span></td></tr>"
            echo "<tr><td class=good><span class='green'>$iconWifi</span></td><td><span class='green'>$currentNetwork ($1)</span></td><td><span class='green'>$wirelessIP</span>"
            if [ "$defaultRoute" == "$1" ]; then
                echo " $iconRoute</td></tr>"
            else
                echo "</td></tr>"
            fi
        fi
    fi
    
}

displayWiredInterface() {
#    
    # display wired device information
    wiredIP=$(ipconfig getifaddr $1)
    
    if [ ! -z "${wiredIP}" ];then
        echo "<tr><td>$iconGood</td><td>Interface ($1)</td><td><span class='green'>$wiredIP</span>"
        if [ "$defaultRoute" == "$1" ]; then
            echo " $iconRoute</td></tr>"
        else
            echo "</td></tr>"
        fi
    else
        # display nothing
        #echo "<tr><td>$iconAlert</td><td>Interface ($1)</td><td><span class='red'>INACTIVE</span></td></tr>"
        echo ""
    fi

}

displayPublicInfo() {
# get public IP and PTR records and display them.  Omit the PTR if it matches the Public IP and provides no additional information
     publicIP=$(curl -s http://icanhazip.com)
     publicPTR=$(curl -s http://icanhazptr.com)

    if [ ! -z "${publicIP}" ];then
        echo "<tr><td><span class='green'>$iconWorld</span></td><td>Public IP</td><td><span class='green'>$publicIP</span></td></tr>"
    else
        #echo "<tr><td><span class='red'>$iconWorld</span></td><td>Public IP</td><td><span class='red'>Unavailable</span></td></tr>"
        echo ""
    fi
    
    if [ ! -z "${publicPTR}" ] && [ "${publicIP}" != "${publicPTR}" ];then
        echo "<tr><td><span class='green'>$iconWorld</span></td><td>Public PTR</td><td><span class='green'>$publicPTR</span></td></tr>"
    else
        #echo "<tr><td><span class='red'>$iconWorld</span></td><td>Public IP</td><td><span class='red'>Unavailable</span></td></tr>"
        echo ""
    fi    
}




mainDisplay() {
    echo "<h1>NETWORK</h1>
    <table>"

    for i in $wirelessDevice; do
        displayWirelessInterface $i
    done
    
    for i in $wiredDevice; do
        displayWiredInterface $i
    done
    
    displayPublicInfo
    
    echo "</table>"
}

# OK Lets make it happen!
mainDisplay