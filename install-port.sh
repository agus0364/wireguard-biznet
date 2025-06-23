#!/bin/bash

# Interface publik (ganti jika bukan eth0)
WAN_IF="eth0"

# IP WireGuard klien
CLIENT_IP="10.66.66.2"

# Daftar port yang akan di-forward
PORTS=(80 8088 5000 5001 123 137 138 139 445 161 3702 5357 3260 3261 3262 3263 3264 3265 6690)

# Aktifkan IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Flush aturan lama (opsional, hati-hati jika ada aturan lain)
# iptables -F
# iptables -t nat -F

# NAT untuk klien agar bisa akses internet
iptables -t nat -A POSTROUTING -s $CLIENT_IP -o $WAN_IF -j MASQUERADE

# Forward port dari IP publik ke klien
for PORT in "${PORTS[@]}"; do
  iptables -t nat -A PREROUTING -i $WAN_IF -p tcp --dport $PORT -j DNAT --to-destination $CLIENT_IP:$PORT
  iptables -t nat -A PREROUTING -i $WAN_IF -p udp --dport $PORT -j DNAT --to-destination $CLIENT_IP:$PORT
  iptables -A FORWARD -p tcp -d $CLIENT_IP --dport $PORT -j ACCEPT
  iptables -A FORWARD -p udp -d $CLIENT_IP --dport $PORT -j ACCEPT
done
