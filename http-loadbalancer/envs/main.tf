# Module uses public module registry
# to create network/subnet
module "network_subnet" {
  source = "../network/network_subnet"
  # VPC Subnet
  project_id  = var.project_id
  vpc         = var.vpc
  vpc_subnets = var.vpc_subnets

}

# Firewall rules
module "firewall_rule" {
  source = "../network/firewall_rule"
  # Inputs
  firewall_rules = var.firewall_rules

  depends_on = [module.network_subnet]
}

#VM_Instance
module "vminstance" {
  source = "../compute/compute_instance"
  name = var.vm_name
  machinetype  = var.machinetype
  zone  = var.zone
}

# Instance template
module "instancetemplate" {
  source = "../compute/instance_template"

  #Inputs
  instance_templates = var.instance_templates

  startup_script = file("${path.module}/../compute/instance_template/apache_startup.sh")

  depends_on = [module.network_subnet]
}

# Instance group manager
module "region_instance_group_mgr" {
  source = "../compute/region_instancegroupmgr"

  # Inputs
  group_mgr_names    = var.group_mgr_names
  group_mgr_regions  = var.group_mgr_regions
  instance_templates = module.instancetemplate.templates
  named_port         = var.named_port
  named_port_number  = var.named_port_number

}

# Instance group mgr autoscaler
module "autoscaler" {
  source = "../compute/auto_scaler"

  # Inputs
  instance_group_mgrs     = module.region_instance_group_mgr.instance_group_mgrs
  autoscaler_min_replicas = var.autoscaler_min_replicas
  autoscaler_max_replicas = var.autoscaler_max_replicas
  autoscaler_cooldown     = var.autoscaler_cooldown
  autoscaler_target_util  = var.autoscaler_target_util

}

# Health check - Use by Load Balancer
module "healthcheck" {
  source = "../networkservices/health_check"

  #Inputs
  healthcheck_name    = var.healthcheck_name
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold
  port                = var.port
  proxy_header        = var.proxy_header

}

# Backend service for Http Load Balancer
module "backend_service" {
  source = "../networkservices/load_balancer/backend_service"

  # Inputs
  backend_name         = var.backend_name
  backend_portname     = var.backend_portname
  backend_project      = var.project_id
  backend_protocol     = var.backend_protocol
  backend_healthchecks = module.healthcheck.id
  instance_group_mrgs  = module.region_instance_group_mgr.instance_group_mgrs
  backends             = var.backends

}

# URL map for http load balancer
module "url_map" {
  source = "../networkservices/load_balancer/url_map"

  # Inputs
  urlmap_name           = var.urlmap_name
  urlmap_project        = var.project_id
  urlmap_defaultservice = module.backend_service.id
}

# Http Proxy for http load balancer
module "http_proxy" {
  source = "../networkservices/load_balancer/target_proxy"

  # Inputs
  proxy_name    = var.proxy_name
  proxy_project = var.project_id
  url_map_id    = module.url_map.id
}

# Forwarding rules for http load balancer
module "fowarding_rule" {
  source = "../networkservices/load_balancer/forwarding_rule"

  # Inputs
  forwardingrule_project = var.project_id
  forwardingrule_target  = module.http_proxy.id
  forwarding_rules       = var.forwarding_rules
}


