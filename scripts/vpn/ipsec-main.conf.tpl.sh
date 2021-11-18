config setup
  keep-alive=300

conn main
  authby=secret
  pfs=no
  auto=start
  keyingtries=%forever
  rekey=yes
  encapsulation=yes
  rekeymargin=1h
  ikelifetime=8h
  keylife=1h
  type=transport
  left=%defaultroute
  leftprotoport=udp/l2tp
  right=$VPN_SERVER_IP
  rightprotoport=udp/l2tp
  ikev2=never
  overlapip=yes
  phase2alg=aes_gcm-null,aes128-sha1,aes256-sha1,aes256-sha2_512,aes128-sha2,aes256-sha2
  phase2=esp
  sha2-truncbug=no
