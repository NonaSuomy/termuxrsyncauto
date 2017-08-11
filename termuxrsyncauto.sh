#!/data/data/com.termux/files/usr/bin/sh

# Configuration

myssid="YOURSSID"
servuser="useraccount"
servcon="nasIP"
servpath="/mnt/datastore001/Storage/user/mobile/"
filelst="rsyncfile.lst"
basedir="/"
perms="u=rwX,g=rX,o=rX"
rsyncopt="-rltDv --size-only --times"

# Configuration end

batstat=$(/data/data/com.termux/files/usr/libexec/termux-api BatteryStatus | jq .plugged)
wifistat=$(/data/data/com.termux/files/usr/libexec/termux-api WifiConnectionInfo | jq .supplicant_state)         
wifissid=$(/data/data/com.termux/files/usr/libexec/termux-api WifiConnectionInfo | jq .ssid)             

case "$batstat" in
  *AC*)
    echo "Plugged in!"
    case "$wifistat" in
      *"COMPLETED"*)
        echo "WiFi Connected"
        case "$wifissid" in
          *"$myssid"*)
            echo "Connected to $wifissid WiFi"
            export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib 
            /data/data/com.termux/files/usr/bin/rsync \
            $rsyncopt \
            --chmod=$perms \
            --files-from=$filelst \
            -e "/data/data/com.termux/files/usr/bin/ssh -i /data/data/com.termux/files/home/.ssh/id_rsa -l $servuser" \
            $basedir $servuser@$servcon:$servpath
          ;;
          *)
            echo "Not connected to your WiFi."
          ;;
        esac
        ;;
      *)
        echo "WiFi Not Connected."
      ;;
    esac
    ;;
  *)
    echo "Unplugged!"
  ;;
esac
