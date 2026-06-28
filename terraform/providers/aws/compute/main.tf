resource "aws_instance" "vm" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name

  user_data = file("${path.module}/user-data.sh")

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vm"
    }
  )

  root_block_device {

    volume_size = 30
    volume_type = "gp3"
    encrypted   = true

  }

}

resource "aws_eip" "vm_ip" {

  instance = aws_instance.vm.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eip"
    }
  )

}