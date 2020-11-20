resource "aws_iam_role" "vgd-cluster-iam" {
  name = "terraform-eks-vgd-cluster-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "vgd-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.vgd-cluster-iam.name
}
resource "aws_iam_role_policy_attachment" "vgd-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.vgd-cluster-iam.name
}

resource "aws_security_group" "vgd-cluster-sg" {
  name        = "terraform-eks-vgd-cluster-sg"
  description = "Security group for communication with worker nodes"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-vgd-sg"
  }
}

#resource "aws_security_group_rule" "vgd-cluster-ingress-workstation-https" {
#  cidr_blocks       = cidrsubnets(data.aws_vpc.selected.cidr_block, 4, 1)
#  description       = "Allow workstation to communicate with the cluster API Server"
#  from_port         = 443
#  protocol          = "tcp"
#  security_group_id = aws_security_group.vgd-cluster-sg.id
#  to_port           = 443
#  type              = "ingress"
#}

resource "aws_eks_cluster" "vgd-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.vgd-cluster-iam.arn

  vpc_config {
    security_group_ids = [aws_security_group.vgd-cluster-sg.id]
    subnet_ids         = aws_subnet.subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.vgd-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.vgd-cluster-AmazonEKSServicePolicy
  ]
}
output "id" {
  value       = aws_eks_cluster.vgd-cluster.id
  description = "The name of the cluster."
}
