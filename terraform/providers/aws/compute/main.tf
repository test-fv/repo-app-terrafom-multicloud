resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                  = var.subnet_id
  vpc_security_group_ids     = [var.security_group_id]
  iam_instance_profile       = var.instance_profile_name

  key_name = aws_key_pair.key.key_name

  user_data = templatefile("${path.module}/user-data.sh", {
    registry_url = var.registry_url
    aws_region   = var.aws_region
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vm"
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }
}

resource "aws_eip" "vm_ip" {
  instance = aws_instance.vm.id
  domain   = "vpc"

  depends_on = [aws_instance.vm]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eip"
  })
}