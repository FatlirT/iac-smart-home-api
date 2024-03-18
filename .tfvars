vpc_cidr_range = "10.0.1.0/24"
availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
public_subnets = ["10.0.1.0/28", "10.0.1.16/28", "10.0.1.32/28"]
private_subnets = ["10.0.1.48/28", "10.0.1.64/28", "10.0.1.80/28"]
app_info = {
  name = "ce-smart-home"
  microservices = {
    web = {
      lights = {
      }
      heating = {
      }
      status = {
      }
    }
    internal = {
      auth = {
      }
    }
    
  }
}
