/* output "security_policy" {
  value = resource.akamai_appsec_security_policy.security_policy
} */

output "template" {
  value = local.template
}

output "policy_id" {
  value = data.akamai_appsec_security_policy.specific_security_policy
}
