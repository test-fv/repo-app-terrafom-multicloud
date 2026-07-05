resource "aws_instance" "vm" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name

  user_data = templatefile(
    "${path.module}/user-data.sh",
    {
      aws_region          = var.aws_region
      runtime_bucket_name = var.runtime_bucket_name
      registry_url        = var.registry_url
    }
  )

  user_data_replace_on_change = true

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