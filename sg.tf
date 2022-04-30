resource "aws_security_group" "vault" {
  name = "${var.name_prefix}-${random_pet.env.id}"
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    Name = "${var.name_prefix}-${random_pet.env.id}"
  )
}

resource "aws_security_group_rule" "vault_internal_api" {
  description       = "Allow Vault nodes to reach other on port 8200 for API"
  security_group_id = aws_security_group.vault.id
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "vault_internal_raft" {
  description       = "Allow Vault nodes to communicate on port 8201 for replication traffic, request forwarding, and Raft gossip"
  security_group_id = aws_security_group.vault.id
  type              = "ingress"
  from_port         = 8201
  to_port           = 8201
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "alb_inbound" {
  count                    = var.lb_sg_id != "null" ? 1 : 0
  description              = "Allow load balancer to reach Vault nodes on port 8200"
  security_group_id        = aws_security_group.vault.id
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  source_security_group_id = var.alb_sg_id
}

resource "aws_security_group_rule" "vault_ssh_inbound" {
  count             = var.ingress_ssh_cidrs != null ? 1 : 0
  description       = "Allow specified CIDRs SSH access to Vault nodes"
  security_group_id = aws_security_group.vault.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ingress_ssh_cidrs
}

resource "aws_security_group_rule" "vault_outbound" {
  description       = "Allow Vault nodes to send outbound traffic"
  security_group_id = aws_security_group.vault.id
  type              = "egress"
  from_port         = var.instance_egress_from_port
  to_port           = var.instance_egress_to_port
  protocol          = var.instance_egress_protocol
  cidr_blocks       = var.instance_egress_cidr_blocks
}
