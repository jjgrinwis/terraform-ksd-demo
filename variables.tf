variable "security_configuration" {
  description = "Akamai Security configuration to add hostname to"
  type        = string
}

variable "hostnames" {
  # first entry in list will also be property name
  # entry 0 will also be used to create edgehostname, every element in list shouls be unique
  description = "One or more hostnames for a single property"
  type        = list(string)
  validation {
    condition     = length(var.hostnames) > 0
    error_message = "At least one hostname should be provided, it can't be empty."
  }
}

variable "security_policy" {
  description = "The security policy to add this hostname to"
  type        = string
}
