
data "aws_ami" "vgd_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]
  # name_regex  = "^ami-\\S{17}"

  filter {
    name   = "name"
    values = ["CIS Ubuntu Linux 18.04 LTS Benchmark*"]
  }

  #  filter {
  #    name   = "root-device-type"
  #    values = ["ebs"]
  #  }

  #  filter {
  #    name   = "virtualization-type"
  #    values = ["hvm"]
  #  }
}

#resource "aws_launch_configuration" "as_conf" {
#  image_id      = data.aws_ami.vgd_ami.id
#  security_groups  = [aws_security_group.vgd-node-sg.id]
#  key_name = aws_key_pair.deployer.key_name
#  lifecycle {
#    create_before_destroy = true
#  }
#  provisioner "local-exec" {
#        command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i istio.yml"
# }
#}
resource "aws_launch_template" "vgd_launch_template" {
  name = "vgd-launch-template"

  #block_device_mappings {
  #  device_name = "/dev/sda1"

  #   ebs {
  #     volume_size = 20
  #   }
  # }

  #capacity_reservation_specification {
  #  capacity_reservation_preference = "open"
  #}

  #cpu_options {
  #  core_count       = 4
  #  threads_per_core = 2
  #}

  #credit_specification {
  # cpu_credits = "standard"
  #}

  disable_api_termination = true

  ebs_optimized = true

  #elastic_gpu_specifications {
  #  type = "test"
  #}

  #elastic_inference_accelerator {
  #  type = "eia1.medium"
  #}

  iam_instance_profile {
    name = aws_iam_instance_profile.test_profile.name
  }

  image_id = data.aws_ami.vgd_ami.id

  instance_initiated_shutdown_behavior = "stop"

  #instance_market_options {
  #  market_type = "spot"
  #}

  instance_type = "t3.micro"

  #kernel_id = "test"

  key_name = aws_key_pair.deployer.key_name

  #license_specification {
  #  license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  #}

  #metadata_options {
  #  http_endpoint               = "enabled"
  #  http_tokens                 = "required"
  #  http_put_response_hop_limit = 1
  #}

  #monitoring {
  #  enabled = false
  #}

  #network_interfaces {
  #    associate_public_ip_address = true
  #   security_groups = [aws_security_group.vgd-node-sg.id]
  #}

  #placement {
  #  availability_zone = var.aws_region
  #}

  #ram_disk_id = "test"

  # vpc_security_group_ids = [aws_security_group.vgd-node-sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "vgd-test"
    }
  }

  #  user_data = filebase64("${path.module}/example.sh")
  user_data = base64encode(file("user-data.sh"))
}
resource "aws_autoscaling_group" "vgd_app_scaling" {

  name = "vgd-app-asg"
  launch_template {
    id      = aws_launch_template.vgd_launch_template.id
    version = aws_launch_template.vgd_launch_template.latest_version
  }
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = aws_subnet.subnet[*].id

  lifecycle {
    create_before_destroy = true
  }
}
