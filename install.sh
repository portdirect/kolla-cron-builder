#!/bin/sh
set -x

docker build . -t port/kolla-cron-builder

cat > /etc/systemd/system/build-kolla-master.service <<EOF
[Unit]
Description=Builds Kolla Master
[Service]
Type=simple
User=harbor
ExecStart=/usr/local/bin/build-kolla-master
EOF

cat > /etc/systemd/system/build-kolla-master.timer <<EOF
[Unit]
Description=Builds Kolla Master Day
[Timer]
OnBootSec=15min
OnUnitActiveSec=1d
[Install]
WantedBy=timers.target
EOF

cat > /usr/local/bin/build-kolla-master <<EOF
#!/bin/bash
for BASE in centos ubuntu; do
  for TYPE in source binary; do
    docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock:rw \
      -v /home/harbor/.docker/config.json:/root/.docker/config.json:ro \
      -e BASE=\${BASE} \
      -e TYPE=\${TYPE} \
      -e NAMESPACE=kolla \
      -e TAG=master \
      port/kolla-cron-builder
  done
done
EOF
chmod +x /usr/local/bin/build-kolla-master

systemctl daemon-reload
systemctl enable build-kolla-master.timer
systemctl start build-kolla-master.timer
