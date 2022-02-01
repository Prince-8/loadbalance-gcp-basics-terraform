variable "zone" {
  type = string
        default="us-east1"
     }


variable "machinetype" {
  type=string
       default="f1-micro"
    }

variable "project_id" {
        default="http-loadbalancer-1"
     }

variable "name" {
    type = string
    description = "(optional) describe your variable"
}

