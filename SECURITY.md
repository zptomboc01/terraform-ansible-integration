# Security Scanning Documentation

This project now includes comprehensive security scanning for both Terraform and Ansible configurations.

## Security Tools Implemented

### 1. Checkov
- **Purpose**: Infrastructure-as-Code security scanner
- **What it checks**: 
  - AWS resource misconfigurations
  - Security group rules
  - Encryption settings
  - IAM policies
  - Network security
- **Configuration**: `.checkov.yml`
- **Output**: SARIF format uploaded to GitHub Security tab

### 2. TFLint
- **Purpose**: Terraform linter for best practices and errors
- **What it checks**:
  - Terraform syntax errors
  - AWS provider-specific issues
  - Deprecated features
  - Naming conventions
  - Module structure
- **Configuration**: `.tflint.hcl`
- **Plugins**: terraform, aws

### 3. Ansible Lint
- **Purpose**: Best practices checker for Ansible playbooks
- **What it checks**:
  - Playbook syntax
  - Best practices violations
  - Security anti-patterns
  - Task optimization
- **Output**: SARIF format uploaded to GitHub Security tab

## Workflow Integration

### Validation Phase (Early)
1. Terraform format check (`terraform fmt -check`)
2. Terraform validate with JSON output
3. Security scans run in parallel:
   - Checkov infrastructure scan
   - TFLint code quality check
   - Ansible Lint playbook validation

### Security Gates
- **Pull Requests**: All scans run, results posted as PR comments
- **Main Branch**: Critical security issues block deployment
- **SARIF Upload**: Results appear in GitHub Security tab

## Security Scan Results

Results are available in multiple formats:
- **CLI Output**: In workflow logs
- **PR Comments**: Summary with pass/fail status
- **GitHub Security**: Detailed findings with remediation advice
- **Job Summary**: High-level status overview

## Configuration Files

- `.checkov.yml` - Checkov scanner configuration
- `.tflint.hcl` - TFLint rules and plugins
- Workflow automatically installs and configures tools

## Customization

### Adding Skip Rules
To skip specific security checks, add to `.checkov.yml`:
```yaml
skip-check:
  - CKV_AWS_79  # Skip specific check
```

### TFLint Rules
Modify `.tflint.hcl` to enable/disable rules:
```hcl
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
```

## Best Practices

1. **Fix Issues Early**: Address security findings in development
2. **Review SARIF Reports**: Check GitHub Security tab regularly
3. **Understand Exceptions**: Document any skipped security checks
4. **Keep Tools Updated**: Update scanner versions periodically
5. **Monitor Trends**: Track security posture over time

## Common Issues and Solutions

### Checkov Failures
- Review AWS resource configurations
- Check encryption settings
- Validate security group rules

### TFLint Issues
- Fix Terraform syntax errors
- Update deprecated resource attributes
- Follow naming conventions

### Ansible Lint Problems
- Use qualified collection names (FQCN)
- Add `become` where needed for privilege escalation
- Follow task naming conventions