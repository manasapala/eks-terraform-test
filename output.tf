output "cluster_id" {
  description = "EKS cluster ID."
  value       = aws_eks_cluster.vgd-cluster.id
}
output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = aws_security_group.vgd-cluster-sg.id
}
output "region" {
  description = "AWS region"
  value       = var.region
}
