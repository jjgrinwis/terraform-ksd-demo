# our first steps to add hosts to an active security policy
terraform {
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = "1.9.1"
    }
  }
}

# using the betajam account to update existing security configuration
provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "betajam"
}

# let's first lookup our existing security configuration 
data "akamai_appsec_configuration" "security_configuration" {
  name = var.security_configuration
}

# now add our new hostname to this security configuration
# we can only do this if hostnames are active on staging or production they won't exists otherwise and can't be added
# so make sure you as depends_on[] to make sure hostnames are active 
resource "akamai_appsec_selected_hostnames" "selected_hostnames" {
  config_id = data.akamai_appsec_configuration.security_configuration.config_id
  hostnames = var.hostnames
  mode      = "APPEND"
}

# lookup our security policy which should be available. 
# not creating a new one as multiple hostnames will make use of the same policy
data "akamai_appsec_security_policy" "specific_security_policy" {
  config_id            = data.akamai_appsec_configuration.security_configuration.config_id
  security_policy_name = var.security_policy
}

# We only need to create this if our policy doesn't exisist
# this is fine for demo but don't create a policy as a policy might be shared by different hostnames
/* resource "akamai_appsec_security_policy" "security_policy" {
  # only create this resource if it's not already active
  count = data.akamai_appsec_security_policy.specific_security_policy.security_policy_id != null ? 0 : 1

  config_id              = data.akamai_appsec_configuration.security_configuration.config_id
  default_settings       = true
  security_policy_name   = var.security_policy
  security_policy_prefix = "msp1"
}
 */

# when you have created a policy and added the hostnames to a security configuration we need to create a match target
# the match target is coming from a json file, let's make that one dynamic with our hostnames and policy_id
locals {
  template = templatefile("${path.module}/match_targets/template.tftpl", { hostnames = jsonencode(resource.akamai_appsec_selected_hostnames.selected_hostnames.hostnames), policy_id = data.akamai_appsec_security_policy.specific_security_policy.security_policy_id })
}

# just feed our created template into the match_target which is a separate resource
# this will add a new match_target to the list of match_targets for this policy.
# when destroying it match target will be removed from security configuration match targets.
resource "akamai_appsec_match_target" "match_target" {
  config_id    = data.akamai_appsec_configuration.security_configuration.config_id
  match_target = local.template
}
