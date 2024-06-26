variable "environment" {
  description = "must be one of: ecaas-ci, ecaas-integration, ecaas-staging, ecaas-production"
  type        = string
  validation {
    condition     = contains(["ecaas-ci", "ecaas-integration", "ecaas-staging", "ecaas-production"], var.environment)
    error_message = "Environment must be one of: ecaas-ci, ecaas-integration, ecaas-staging, ecaas-production"
  }
}
