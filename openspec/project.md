# Project Context

## Purpose
RACE (Remote AWS Code Control Executor) is a collection of Infrastructure as Code (IaC) utilities that make life easier for Cloud Engineers. RACE is designed to work with [CatStack](https://github.com/wearetechnative/catstack) and provides an integrated CLI for managing backends, variables, and Nix workflows. Currently focused on Terraform, with future support planned for OpenTofu and other IaC tools.

**Current Version:** 0.1.5

**Main Goals:**
- Simplify backend management across multiple environments (nonprod, prod, etc.)
- Automate tfvars selection based on backend configuration
- Provide intelligent Nix integration for declarative workflows
- Prevent accidental destruction of critical infrastructure resources
- Offer user-friendly CLI experience for IaC operations

## Tech Stack
- **Bash 4.0+** - Core scripting language for CLI tools
- **Python** - Documentation generation (terraform-docs-stack.py)
- **Nix with flakes** - Reproducible builds and distribution
- **Terraform** - Primary IaC tool (OpenTofu support planned)
- **AWS CLI** - Cloud provider integration
- **gum** (optional) - Enhanced interactive prompts

## Project Conventions

### Code Style
- Bash scripts follow standard shell scripting conventions
- Scripts should be POSIX-compliant where possible
- Use meaningful variable names and comments for clarity
- Interactive prompts via gum when available, fallback to basic read prompts
- All scripts should include error handling and safety checks

### Architecture Patterns
- **Modular CLI design**: Single `race` entry point dispatching to specialized scripts
- **State management**: Backend configuration stored in `.terraform/tfbackend.state`
- **Convention over configuration**: Automatic matching of `.tfbackend` and `.tfvars` files
- **Safety-first approach**: Built-in protections against destructive operations
- **Nix-aware**: Detection and integration with Nix-based workflows

### Project Structure
```
project/
├── race                    # Main CLI entry point
├── _racelib.sh            # Shared library functions
├── tfbackend.sh           # Backend configuration management
├── tfplan.sh              # Plan with auto tfvars selection
├── tfapply.sh             # Apply with auto tfvars selection
├── tfdestroy.sh           # Destroy with safety protections
├── tfimport.sh            # Import resources
├── nixrun.sh              # Nix integration
├── elastinix_ssh_keypair.sh  # SSH key generation
├── flake.nix              # Nix flake definition
├── package.nix            # Nix package definition
└── docs/                  # Documentation
```

### Testing Strategy
- Manual testing of CLI workflows
- Verification of backend switching across environments
- Validation of safety protections (destroy guards)
- Testing with both gum and fallback prompts

### Git Workflow
- Main branch: `main`
- Conventional commits preferred
- Document changes in CHANGELOG.md
- Update VERSION-race file for releases

## Domain Context

### Infrastructure as Code (IaC) Focus
RACE is specifically designed for managing Terraform (and future OpenTofu) workflows in AWS environments. Key concepts:

- **Backend configurations** (`.tfbackend` files): Define where Terraform state is stored (S3 bucket, DynamoDB table, etc.)
- **Variable files** (`.tfvars`): Environment-specific variable values
- **Stack structure**: `stack/domain/` directories containing IaC code
- **CatStack integration**: Built to complement the CatStack framework

### Safety Protections
RACE includes critical safety measures:
1. **Nix project detection**: Prompts for confirmation before executing IaC commands when `.nix` files detected
2. **Destroy protection**: Prevents destruction of resources with names:
   - backend
   - dynamodb
   - kms

### Expected Project Structure
Projects using RACE should follow this structure:
```
project/
├── *.tfbackend          # Backend configurations (nonprod.tfbackend, prod.tfbackend)
├── *.tfvars             # Variable files (nonprod.tfvars, prod.tfvars)
├── flake.nix            # (Optional) Nix flake for declarative workflows
├── stack/               # IaC stack directories
│   └── domain/          # Domain-specific IaC code
└── .terraform/
    └── tfbackend.state  # Current active backend (managed by race)
```

## Important Constraints

### Technical Constraints
- Requires Bash 4.0 or higher
- AWS CLI must be configured with appropriate `AWS_PROFILE`
- Terraform (or OpenTofu in future) must be available in PATH
- Nix features require Nix with flakes support enabled
- File naming convention: backends and tfvars must share the same prefix (e.g., `nonprod.tfbackend` matches `nonprod.tfvars`)

### Safety Constraints
- Never bypass destroy protection for critical resources (backend, dynamodb, kms)
- Always confirm operations when Nix projects are detected
- Backend state file should not be manually edited
- Operations should respect AWS_PROFILE environment variable

### Compatibility Constraints
- Currently Terraform-specific (OpenTofu support is planned)
- Designed for CatStack project structure
- Linux/Unix environments (bash scripts)

## External Dependencies

### Required Dependencies
- **Terraform**: Primary IaC tool for infrastructure management
- **AWS CLI**: Authentication and AWS service interaction
- **Bash 4.0+**: Shell interpreter for all scripts

### Optional Dependencies
- **Nix with flakes**: For reproducible builds and `race nixrun` functionality
- **gum**: Enhanced terminal UI for interactive prompts (graceful fallback if not available)

### External Services
- **AWS S3**: Backend state storage
- **AWS DynamoDB**: State locking
- **AWS KMS**: State encryption (optional)

### Related Projects
- **CatStack** (https://github.com/wearetechnative/catstack): Companion framework that RACE is designed to support
- **OpenTofu**: Planned future support as Terraform alternative

## Distribution
- **Nix Flakes**: `nix profile install github:wearetechnative/race`
- **GitHub Repository**: https://github.com/wearetechnative/race
- **Manual installation**: Clone repository and symlink `race` binary to PATH

## Authors & License
- Developed by Wouter, Pim, et al. at [Technative](https://technative.nl)
- License: MIT
- Copyright: Technative 2024
