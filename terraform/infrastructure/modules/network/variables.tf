variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
  default     = [
    "10.20.48.0/20",
    "10.20.112.0/20",
    "10.20.176.0/20"
  ]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
  default     = [
    "10.20.0.0/20",
    "10.20.16.0/20",
    "10.20.32.0/20",
    "10.20.64.0/20",
    "10.20.80.0/20",
    "10.20.96.0/20",
    "10.20.128.0/20",
    "10.20.144.0/20",
    "10.20.160.0/20"
  ]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnet_names" {
  type      = map(object({
    public  = string
    private = list(string)
  }))
  description = "Mapping of AZs to subnet names"
  default = {
    "us-east-1a" = {
      public  = "sn-web-A"
      private = ["sn-reserved-A", "sn-db-A", "sn-app-A"]
    }
    "us-east-1b" = {
      public  = "sn-web-B"
      private = ["sn-reserved-B", "sn-db-B", "sn-app-B"]
    }
    "us-east-1c" = {
      public  = "sn-web-C"
      private = ["sn-reserved-C", "sn-db-C", "sn-app-C"]
    }
  }
}