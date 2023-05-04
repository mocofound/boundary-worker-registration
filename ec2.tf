data "hcp_packer_image" "nomad-multi-region" {
  #bucket_name     = "nomad-multi-region-focal"
  bucket_name    = "nomad-multi-region"
  channel        = "latest"
  cloud_provider = "aws"
  region         = var.region
  #region         = "us-east-2"
}

locals {
  ami_id = var.use_hcp_packer == true ? "${data.hcp_packer_image.nomad-multi-region.cloud_image_id}" : "${data.aws_ami.nomad-mr.image_id}"
  #ami_id = "${data.aws_ami.nomad-mr.image_id}"
}

data "aws_ami" "nomad-mr" {
  #executable_users = ["self"]
  most_recent      = true
  #name_regex       = "^hashistack-\\d{3}"
  owners           = ["self","099720109477"]

  filter {
    name   = "name"
    values = ["nomad-mr-*"]
  }
}

resource "random_id" "server" {
  byte_length = 4
  keepers = {
    ami_id = local.ami_id
    #"ami_id" = "${data.aws_ami.nomad-mr.image_id}"
  }
}

resource "random_id" "random" {
  byte_length = 4
  keepers = {
    "ami_id" = "${data.aws_ami.nomad-mr.image_id}"
  }
}

resource "aws_instance" "worker" {
  count = var.server_count
  #ami                    = "${data.aws_ami.nomad-mr.image_id}"
  ami           = random_id.server.keepers.ami_id
  instance_type = var.server_instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  #subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.boundary_sg.id]

  #TODO
  associate_public_ip_address = true
  tags = merge(
    {
      "Name" = "${var.prefix}-server-${count.index}"
    },
    {
      "boundary" = "ssh"
    }
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
    tags                  = {}
  }

  user_data = templatefile("${path.module}/modules/shared/data-scripts/user-data.sh", {
    server_count              = var.server_count
    region                    = var.region
    cloud_env                 = "aws"
    worker_activation_token   = boundary_worker.worker_1.controller_generated_activation_token
    NAME = "boundary"
    TYPE = "worker"
  })
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
  depends_on = [
    #aws_kms_key.vault
    boundary_worker.worker_1
  ]
}


# resource "aws_kms_key" "vault" {
#   description             = "Vault unseal key"
#   deletion_window_in_days = 10

#   tags = {
#     Name = "vault-kms-unseal-${var.prefix}"
#   }
# }

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.prefix}-profile"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "${var.prefix}-auto-discover-cluster-pol"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }
}

resource "aws_security_group" "boundary_sg" {
  name_prefix = var.prefix
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

    ingress {
    from_port = 9202
    to_port   = 9202
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}