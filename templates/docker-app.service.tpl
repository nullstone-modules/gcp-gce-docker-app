[Unit]
Description=${container_name} (docker app via gcp-gce-server)
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
# Pull retries need headroom; default ~90s is too short when NAT is slow.
TimeoutStartSec=300
Restart=on-failure
RestartSec=15
ExecStart=${app_dir}/docker-app-up.sh
ExecStop=/usr/bin/docker rm -f ${container_name}

[Install]
WantedBy=multi-user.target
