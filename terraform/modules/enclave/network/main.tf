resource "aws_subnet" "observe" {
  count                   = "${length(keys(var.availability_zones))}"
  availability_zone       = "${element(keys(var.availability_zones), count.index)}"
  cidr_block              = "${lookup(var.availability_zones, element(keys(var.availability_zones), count.index))}"
  map_public_ip_on_launch = false
  vpc_id                  = "${var.target_vpc}"

  tags {
    Name          = "${var.product}-${var.environment}-subnet-${element(keys(var.availability_zones), count.index)}"
    Environment   = "${var.environment}"
    Product       = "${var.product}"
    ManagedBy     = "terraform"
  }
}

resource "aws_route_table" "observe" {
  vpc_id = "${var.target_vpc}"

  tags {
    Name          = "${var.product}-${var.environment}-rt-${element(keys(var.availability_zones), count.index)}"
    Environment   = "${var.environment}"
    Product       = "${var.product}"
    ManagedBy     = "terraform"
  }
}

# A default route via the internet gateway.
resource "aws_route" "default" {
  route_table_id         = "${aws_route_table.observe.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.internet_gateway_id}"
}

resource "aws_route" "vpc_peers" {
  count = "${length(keys(var.vpc_peers))}"
  
  route_table_id            = "${aws_route_table.observe.id}"
  destination_cidr_block    = "${element(keys(var.vpc_peers), count.index)}"
  vpc_peering_connection_id = "${lookup(var.vpc_peers, element(keys(var.vpc_peers), count.index))}"
}

# Associate route table with observe subnets
resource "aws_route_table_association" "observe" {
  count = "${length(keys(var.availability_zones))}"

  subnet_id      = "${element(aws_subnet.observe.*.id, count.index)}"
  route_table_id = "${aws_route_table.observe.id}"
}

resource "aws_security_group" "ssh_from_gds" {
  vpc_id      = "${var.target_vpc}"
  name        = "SSH from GDS"
  description = "Allow SSH access from GDS"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.cidr_admin_whitelist}"]
  }

  tags {
    Name = "SSH from GDS"
  }
}

