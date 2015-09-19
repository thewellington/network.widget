#!/bin/bash

# Network status


# User assigned array.  List the ssid's you wish to consider "safe"
# desiredNetwork=("ssid_1" "ssid_2" "ssid_3")
safeNetworksArray=("PoohCorner" "712-100")

# fontawesome classes
iconGood="<i class='fa fa-check-circle green'></i>"
iconAlert="<i class='fa fa-times-circle red'></i>"
iconWifi="<i class='fa fa-wifi'></i>"
iconWorld="<i class='fa fa-globe'></i>"
iconRoute=" <i class='fa fa-sign-out blue'></i>"

# get some interfaces
wirelessDevice=$(networksetup -listallhardwareports | grep -Ei -A 1 '(Wi-Fi|Airport)' | grep en | sed -n 's/Device/&/p' | awk '{print $2}' | sort)
wiredDevice=$(networksetup -listallhardwareports | grep -Ei -A 1 '(Thunderbolt|Ethernet)' | grep en | sed -n 's/Device/&/p' | awk '{print $2}' | sort)


# get default route
defaultRoute=$(route -n get default | grep -o "interface: .*" | awk '{print $2}')

wiredIcon=""
wirelessIcon=""

if [ "$defaultRoute" == "$wiredDevice" ]; then wiredIcon=$iconRoute; fi
if [ "$defaultRoute" == "$wirelessDevice" ]; then wirelessIcon=$iconRoute; fi

#----------FUNCTIONS---------

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
#
    #wifiOrAirport=$(/usr/sbin/networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)')
    #wirelessDevice=$(/usr/sbin/networksetup -listallhardwareports | awk "/$wifiOrAirport/,/Device/" | awk 'NR==2' | cut -d " " -f 2)

    # get wireless device list
    wirelessIP=$(ipconfig getifaddr $1)

    # get current SSID
    currentNetwork=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk -F: '/ SSID: / {print $2}' | sed -e 's/SSID: //' | sed -e 's/ //')
    
    # display wireless device information
    array_contains safeNetworksArray "${currentNetwork}" && safeNetwork=1 || safeNetwork=0
    if [ "$safeNetwork" != "1" ];then
        echo "<tr><td><span class='red'>$iconWifi</span> Network SSID</td><td><span class='red'>$currentNetwork</span></td></tr>"
        echo "<tr><td><span class='red'>$iconWifi</span> Wireless IP ($1)</td><td><span class='red'>$wirelessIP${wirelessIcon}</span></td></tr>"
    else
        echo "<tr><td><span class='green'>$iconWifi</span> Network SSID</td><td><span class='green'>$currentNetwork</span></td></tr>"
        echo "<tr><td class=good><span class='green'>$iconWifi</span> Wireless IP ($1)</td><td><span class='green'>$wirelessIP${wirelessIcon}</span></td></tr>"
    fi
}


displayWiredInterface() {
#    
    wiredIP=$(ipconfig getifaddr $1)
    if [ ! -z "${wiredIP}" ];then
        icon=""

        if [ "$defaultRoute" == "$1" ]; then icon=$iconRoute; fi
        echo "<tr><td>$iconGood Ethernet IP ($1)</td><td><span class='green'>$wiredIP${wiredIcon}</span> $icon</td></tr>"
    else
        echo "<tr><td>$iconAlert Ethernet IP ($1)</td><td><span class='red'>INACTIVE</span></td></tr>"
    fi

}


displayPublicIP() {
    # get public IP
    publicIP=$(curl -s http://icanhazip.com)
    if [ ! -z "${publicIP}" ];then
        echo "<tr><td><span class='green'>$iconWorld</span> Public IP</td><td><span class='green'>$publicIP</span></td></tr>"
    else
        echo "<tr><td><span class='red'>$iconWorld</span> Public IP</td><td><span class='red'>Unavailable</span></td></tr>"
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

    displayPublicIP


    echo "</table>"
}


# OK Lets make it happen!
mainDisplay