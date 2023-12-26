
if [ ! -e /root/.done ]; then
  if kill -9 `lsof -t +D /old_root`; then
    sleep 1
  fi
  if umount -R /old_root; then
    swapoff -a
    touch /root/.done
    echo "Old root system detached"
  fi
fi

if ! pgrep -f /lib/systemd/systemd-udevd > /dev/null; then
  /lib/systemd/systemd-udevd -d
fi
MACHINE=$(host $(hostname -i) 68.178.203.95 | grep -o -P "(?<=domain name pointer ).+" | sed -e 's/\.$//')
echo
echo "Install CoreOS:"
echo "/root/coreos-installer install /dev/sda -i /root/<config>.ign --append-karg=\"rd.neednet=1\" --append-karg=\"ip=$(hostname -i):169.254.0.1:169.254.0.1:255.255.255.255:${MACHINE:-<host>.okd.nadybot.org}:enp1s0:none:68.178.203.95:68.178.207.31\""
