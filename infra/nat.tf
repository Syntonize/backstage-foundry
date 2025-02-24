resource "aws_nat_gateway" "this" {

  subnet_id     = data.aws_subnets.public.ids[0]
  allocation_id = aws_eip.nat_eip.id
}

resource "aws_eip" "nat_eip" {}

data "aws_route_table" "this" {
  subnet_id = data.aws_subnets.private.ids[0]
}
resource "aws_route" "nat" {
  route_table_id            = data.aws_route_table.this.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.this.id
}
