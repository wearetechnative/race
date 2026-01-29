# Race - Remote AWS Code Control Executor - Terraform Tools for CatStack

**Tools for CatStack** (https://github.com/wearetechnative/catstack)

<img src="images/racelogo.png" style="width:200px" />


RACE (Remote AWS Code Control Executor) is a collection of Infrastructure as Code (IaC) utilities that make life easier for Cloud Engineers. RACE is designed to work with [CatStack](https://github.com/wearetechnative/catstack) and provides an integrated CLI for managing backends, variables, and Nix workflows. Currently focused on Terraform, with future support planned for OpenTofu and other IaC tools.

**Version:** 0.1.5

## Features

- **Backend Management**: Easily switch between multiple IaC backends (Terraform/OpenTofu)
- **Automatic tfvars selection**: Automatically matches the correct `.tfvars` files to your backend
- **Nix Integration**: Intelligent matching of backends with Nix flake targets
- **Safety Protection**: Prevents accidental destruction of critical resources (backend, DynamoDB, KMS)
- **Interactive CLI**: User-friendly menus for backend selection
- **Multi-environment support**: Work seamlessly with nonprod, prod, and other environments
- **Extensible**: Designed with future support for OpenTofu and other IaC tools in mind

## Installation

### Via Nix Flakes

```bash
nix profile install github:wearetechnative/race
```

### Manual installation

1. Clone the repository:
```bash
git clone https://github.com/wearetechnative/race.git
cd race
```

2. Make the scripts executable and add to your PATH:
```bash
chmod +x race
sudo ln -s $(pwd)/race /usr/local/bin/race
```

## Usage

RACE provides a unified command-line interface for all IaC utilities:

```bash
race [command]
```

### Available commands

- `race usage` - Show help information
- `race version` - Show race version
- `race init` - Configure backend (currently Terraform, OpenTofu support planned)
- `race plan` - Run plan command with automatic tfvars selection
- `race apply` - Run apply command with automatic tfvars selection
- `race nixrun` - Run nix run for the selected backend
- `race elastinixkey` - Generate SSH keypair

### Workflow

#### 1. Configure backend

```bash
race init
```

This script searches for all `*.tfbackend` files in your project and lets you interactively choose a backend. The selection is saved in `.terraform/tfbackend.state`.

#### 2. Plan/Apply

```bash
race plan
race apply
```

These commands:
- Read the active backend from `.terraform/tfbackend.state`
- Automatically match the corresponding `.tfvars` file (e.g., `nonprod.tfbackend` → `nonprod.tfvars`)
- Execute the IaC tool (currently Terraform) with the correct variables

#### 3. Nix integration

For projects using Nix flakes:

```bash
race nixrun
```

This script:
- Reads the active backend from `.terraform/tfbackend.state`
- Searches for matching targets in `flake.nix`
- Executes `nix run .#<target>` for the correct environment

## Project Structure

RACE expects a specific project structure that works with CatStack:

```
project/
├── *.tfbackend          # Backend configurations (nonprod.tfbackend, prod.tfbackend)
├── *.tfvars             # Variable files (nonprod.tfvars, prod.tfvars)
├── flake.nix            # (Optional) Nix flake for declarative workflows
├── stack/               # IaC stack directories (Terraform/OpenTofu)
│   └── domain/          # Domain-specific IaC code
└── .terraform/
    └── tfbackend.state  # Current active backend (managed by race)
```

## Examples

### Example 1: Switching between environments

```bash
# Configure nonprod backend
race init
# Select: 0: nonprod.tfbackend

# Plan changes for nonprod
race plan

# Switch to prod
race init
# Select: 1: prod.tfbackend

# Plan changes for prod
race plan -out prod.tfplan
```

### Example 2: Nix workflow

```bash
# Configure backend
race init
# Select: nonprod

# Run nix run (automatically matches nonprod_apply in flake.nix)
race nixrun
```

## Requirements

- Bash 4.0+
- Terraform (or OpenTofu - planned support)
- AWS CLI (with configured `AWS_PROFILE`)
- (Optional) Nix with flakes support
- (Optional) gum - for better interactive prompts

## Safety Measures

RACE includes built-in safety measures:

1. **Nix projects**: When `.nix` files are detected, race asks for confirmation before executing IaC commands
2. **Destroy protection**: The `tfdestroy` script prevents destruction of resources with names:
   - backend
   - dynamodb
   - kms

## Documentation

For detailed documentation on individual components:

- [Backend Switcher and Tools](./docs/terraform-backend-tools.md)
- [Setup TF Plugin Cache](./docs/setup_tf_plugin_cache.md)

## Future Roadmap

- **OpenTofu Support**: Native support for OpenTofu as an alternative to Terraform
- **Additional IaC Tools**: Expand support to other Infrastructure as Code tools
- **Enhanced Nix Integration**: Extended Nix flake patterns and workflows

## Development

RACE is built with:
- Bash for the core scripts
- Python for documentation generation
- Nix for reproducible builds and distribution

### Changelog

See [CHANGELOG.md](./CHANGELOG.md) for a complete overview of changes.

## License

RACE is available under the MIT license. See [LICENSE](./LICENSE) for more information.

## Authors

Developed by Wouter, Pim, et al. at [Technative](https://technative.nl)

© Technative 2024

## Links

- [GitHub Repository](https://github.com/wearetechnative/race)
- [CatStack](https://github.com/wearetechnative/catstack)
- [Technative](https://technative.eu)
