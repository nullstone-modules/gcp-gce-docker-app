[Unit]
Description=${container_name} (docker app via gcp-gce-server)
After=network-online.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/app/${container_name}/docker-app-up.sh
ExecStop=/usr/bin/docker rm -f ${container_name}

[Install]
WantedBy=multi-user.target
