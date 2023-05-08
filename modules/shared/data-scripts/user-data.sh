#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo mkdir /home/ubuntu/boundary/ && cd /home/ubuntu/boundary/
sudo mkdir /home/ubuntu/boundary/auth_storage
sudo mkdir /boundary
sudo mkdir /boundary/auth_storage

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - ;\
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" ;\
sudo apt-get update && sudo apt-get install boundary-worker-hcp -y

boundary-worker version

sudo cat << EOF > /home/ubuntu/boundary/egress-worker.hcl
disable_mlock = true
hcp_boundary_cluster_id = "${boundary_cluster_id}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
  #auth_storage_path="/boundary/auth_storage"
  #initial_upstreams = "${initial_upstreams}"
  controller_generated_activation_token = "${worker_activation_token}"
  #controller_generated_activation_token = "neslat_........."
  # controller_generated_activation_token = "env://ACT_TOKEN"
  # controller_generated_activation_token = "file:///tmp/worker_act_token"
  auth_storage_path = "home/ubuntu/boundary/worker1"
  tags {
    type = ["egress", "downstream"]
  }
}
EOF

TYPE=worker
NAME=boundary

#sudo cat << EOF > /etc/systemd/system/${NAME}-${TYPE}.service
sudo cat << EOF > /etc/systemd/system/boundary-worker.service
[Unit]
Description=boundary worker

[Service]
ExecStart=/usr/bin/boundary-worker server -config /home/ubuntu/boundary/egress-worker.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
sudo adduser --system --group boundary || true
sudo chown boundary:boundary /home/ubuntu/boundary/egress-worker.hcl
sudo chown boundary:boundary /usr/bin/${NAME}-${TYPE}
sudo chown boundary:boundary /home/ubuntu/boundary/auth_storage

sudo chmod 664 /etc/systemd/system/${NAME}-${TYPE}.service
sudo systemctl daemon-reload
sudo systemctl enable ${NAME}-${TYPE}
sudo systemctl start ${NAME}-${TYPE}

sudo chmod 664 /etc/systemd/system/boundary-worker.service
sudo systemctl daemon-reload
sudo systemctl enable boundary-worker
sudo systemctl start boundary-worker
