variable "subnets" {
  type = list(object({
    az = number
    pub_ip = bool
    f = string
  }))
  default = [
    {
      # Bastion
      az = 0
      pub_ip = true
      f = "public"
    },
    {
      # App - AZ 1
      az = 0
      pub_ip = false
      f = "app"
    },
    {
      # NAT
      az = 1
      pub_ip = true
      f = "nat"
    },
    {
      # DBs
      az = 1
      pub_ip = false
      f = "db"
    },
    {
      # App - AZ 2
      az = 1
      pub_ip = false
      f = "app"
    },
    {
      # LB - AZ 1
      az = 0
      pub_ip = true
      f = "lb"
    },
    {
      # LB - AZ 2
      az = 1
      pub_ip = true
      f = "lb"
    },
  ]
}
