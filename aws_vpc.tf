# vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "sbcntr-vpc"
  }
}

# subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"

  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"

  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c"
  }
}

resource "aws_subnet" "egress_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"

  cidr_block              = "10.0.248.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1a"
  }
}

resource "aws_subnet" "egress_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"

  cidr_block              = "10.0.249.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1c"
  }
}

resource "aws_subnet" "application_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"

  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1a"
  }
}

resource "aws_subnet" "application_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"

  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1c"
  }
}

resource "aws_subnet" "db_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"

  cidr_block              = "10.0.16.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1a"
  }
}

resource "aws_subnet" "db_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"

  cidr_block              = "10.0.17.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1c"
  }
}

resource "aws_subnet" "public_management_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"

  cidr_block              = "10.0.240.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1a"
  }
}

resource "aws_subnet" "public_management_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"

  cidr_block              = "10.0.241.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1c"
  }
}

# internet gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sbcntr-igw"
  }
}

# internet gateway attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway_attachment
resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

# route table
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "ingress" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sbcntr-route-ingress"
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sbcntr-route-app"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sbcntr-route-db"
  }
}

# route
# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "ingress" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.ingress.id
  gateway_id             = aws_internet_gateway.main.id
}

# route table association
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route_table_association" "application_1a" {
  subnet_id      = aws_subnet.application_1a.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "application_1c" {
  subnet_id      = aws_subnet.application_1c.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "db_1c" {
  subnet_id      = aws_subnet.db_1c.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "public_management_1a" {
  subnet_id      = aws_subnet.public_management_1a.id
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route_table_association" "public_management_1c" {
  subnet_id      = aws_subnet.public_management_1c.id
  route_table_id = aws_route_table.ingress.id
}

# secruty group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ingress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "from 0.0.0.0/0:80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ## Internet LB -> Front Container
  ingress {
    description     = "HTTP for Ingress"
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.front_container.id]
    to_port         = 80
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-ingress"
  }
}

resource "aws_security_group" "management" {
  name        = "management"
  description = "Security Group of management server"
  vpc_id      = aws_vpc.main.id

  ## Management server -> DB
  ingress {
    description     = "MySQL protocol from management server"
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.database.id]
    to_port         = 3306
  }

  ### Management Server -> VPC endpoint
  ingress {
    description     = "HTTPS for management server"
    from_port       = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpce.id]
    to_port         = 443
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-management"
  }
}

resource "aws_security_group" "front_container" {
  name        = "front-container"
  description = "Security Group of front container app"
  vpc_id      = aws_vpc.main.id

  ## Front Container -> Internal LB
  ingress {
    description     = "HTTP for front container"
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal.id]
    to_port         = 80
  }

  ### Front container -> VPC endpoint
  ingress {
    description     = "HTTPS for Front Container App"
    from_port       = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpce.id]
    to_port         = 443
  }
  ## Front container -> DB
  ingress {
    description     = "MySQL protocol from frontend App"
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.database.id]
    to_port         = 3306
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-front-container"
  }
}

resource "aws_security_group" "internal" {
  name        = "internal"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.main.id

  ## Internal LB -> Back Container
  ingress {
    description     = "HTTP for internal lb"
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.container.id]
    to_port         = 80
  }

  ## Internal LB -> Management Server
  ingress {
    description     = "HTTP for management container"
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.management.id]
    to_port         = 80
  }

  ## Internal LB -> Management Server
  ingress {
    description     = "Test port is used for management server"
    from_port       = 10080
    protocol        = "tcp"
    security_groups = [aws_security_group.management.id]
    to_port         = 10080
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-internal"
  }
}

resource "aws_security_group" "container" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = aws_vpc.main.id

  ## Back container -> DB
  ingress {
    description     = "MySQL protocol from backend App"
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.database.id]
    to_port         = 3306
  }

  ### Back container -> VPC endpoint
  ingress {
    description     = "HTTPS for Container App"
    from_port       = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpce.id]
    to_port         = 443
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-container"
  }
}

resource "aws_security_group" "database" {
  name        = "database"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-db"
  }
}

resource "aws_security_group" "vpce" {
  name        = "vpce"
  description = "Security Group of VPC Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-vpce"
  }
}

# vpc endpoint
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "api" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.ecr.api"

  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [
    aws_subnet.egress_1a.id,
    aws_subnet.egress_1c.id,
  ]

  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  # INFO: aws_iam_policy is configured as full access in default setting
  # https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html

  tags = {
    Name = "sbcntr-vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [
    aws_subnet.egress_1a.id,
    aws_subnet.egress_1c.id,
  ]

  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  # INFO: aws_iam_policy is configured as full access in default setting
  # https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html

  tags = {
    Name = "sbcntr-vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"

  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.app.id]

  # INFO: aws_iam_policy is configured as full access in default setting
  # https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html

  tags = {
    Name = "sbcntr-vpce-s3"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.logs"

  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [
    aws_subnet.egress_1a.id,
    aws_subnet.egress_1c.id,
  ]

  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  # INFO: aws_iam_policy is configured as full access in default setting
  # https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html

  tags = {
    Name = "sbcntr-vpce-logs"
  }
}