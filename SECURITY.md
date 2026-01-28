# Security Policy

## Supported Versions

We release patches for security vulnerabilities. The following versions are currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1   | :x:                |

## Reporting a Vulnerability

The RACE team takes security seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report a Security Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisory**: Use the [GitHub Security Advisory](https://github.com/wearetechnative/race/security/advisories/new) feature (preferred method)
2. **Email**: Contact the maintainers at Technative
3. **Private Issue**: If you cannot use the above methods, create a private issue and mark it as security-related

### What to Include

When reporting a vulnerability, please include:

- Type of issue (e.g., command injection, privilege escalation, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your vulnerability report within 3 business days
- **Updates**: We will keep you informed about our progress towards a fix
- **Timeline**: We aim to release a fix within 90 days of the initial report
- **Credit**: We will credit you in the security advisory (unless you prefer to remain anonymous)

## Security Best Practices

When using RACE, we recommend the following security practices:

### 1. AWS Credentials

- Always use AWS IAM roles with least privilege principle
- Never commit AWS credentials to version control
- Use AWS SSO or temporary credentials when possible
- Set `AWS_PROFILE` environment variable appropriately

### 2. Backend Files

- Store `.tfbackend` files securely
- Use encrypted storage for sensitive backend configurations
- Review backend configurations before committing
- Use `.gitignore` to prevent accidental commits of sensitive files

### 3. Variable Files

- Never commit sensitive data in `.tfvars` files
- Use encrypted backends for state files
- Consider using tools like `git-secrets` or `detect-secrets`
- Use environment variables or secret management systems for sensitive values

### 4. State Files

- Always use encrypted S3 buckets for Terraform state
- Enable versioning on state bucket
- Restrict access to state files using IAM policies
- Enable DynamoDB state locking

### 5. Nix Integration

- Review `flake.lock` file regularly
- Use pinned versions for critical dependencies
- Audit Nix expressions before execution

### 6. Script Execution

- Review scripts before execution, especially when using `race nixrun`
- Use the Nix project confirmation feature
- Be cautious when running scripts from untrusted sources
- Understand what each command does before executing

## Built-in Security Features

RACE includes several security features:

### 1. Destroy Protection

The `tfdestroy` script prevents accidental destruction of critical resources:
- Backend infrastructure
- DynamoDB tables
- KMS keys

### 2. Nix Project Detection

When `.nix` files are detected, RACE asks for confirmation before executing potentially destructive commands.

### 3. Interactive Confirmation

Critical operations require interactive confirmation to prevent accidental execution.

## Known Security Considerations

### Command Injection

RACE scripts accept user input and execute shell commands. While we've implemented safeguards, users should:
- Only use RACE in trusted environments
- Review scripts before execution
- Not accept untrusted input to RACE commands

### File System Access

RACE reads and writes files in your project directory:
- Ensure proper file permissions on your project
- Use RACE in directories you trust
- Review changes before committing

### AWS Access

RACE requires AWS credentials to function:
- Use least privilege IAM roles
- Monitor CloudTrail logs for RACE actions
- Implement proper access controls

## Security Updates

Security updates will be released as patch versions (e.g., 0.1.x). We recommend:
- Always using the latest version
- Subscribing to GitHub releases
- Checking the CHANGELOG for security-related updates

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release patches as quickly as possible

## Scope

This security policy applies to:
- All RACE scripts and tools
- Integration with Terraform/OpenTofu
- Integration with AWS services
- Integration with Nix

Out of scope:
- Terraform/OpenTofu vulnerabilities (report to HashiCorp/OpenTofu project)
- AWS service vulnerabilities (report to AWS)
- Third-party dependencies (report to respective projects)

## Contact

For security concerns or questions about this policy, please contact the maintainers through the methods listed above.

---

**Note**: This security policy is subject to change. Please check back regularly for updates.
