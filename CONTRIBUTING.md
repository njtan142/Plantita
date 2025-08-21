# Contributing to Plantita

Thank you for your interest in contributing to Plantita! This document outlines the process for contributing to this project.

## 🏗️ Development Setup

### Prerequisites

- Node.js 18.0.0 or higher
- pnpm 8.0.0 or higher
- Git

### Installation

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/plantita.git
   cd plantita
   ```

3. Install dependencies:
   ```bash
   pnpm install
   ```

4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🚀 Development Workflow

### Available Scripts

```bash
# Install dependencies
pnpm install

# Start development servers
pnpm dev

# Build all packages
pnpm build

# Run tests
pnpm test

# Run linting
pnpm lint

# Format code
pnpm format

# Type checking
pnpm typecheck
```

### Project Structure

```
plantita/
├── system-backend/          # Node.js backend
├── admin-dashboard/         # Next.js admin dashboard
├── user-app/                # Flutter user app
├── uploader-app/            # Flutter uploader app
├── shared/                  # Shared utilities and types
├── docker/                  # Docker configurations
└── docs/                    # Documentation
```

## 📝 Making Changes

### 1. Understand the Architecture

- **system-backend**: Node.js backend with TypeScript
- **admin-dashboard**: Next.js application for admin functions
- **user-app**: Flutter app for viewing media
- **uploader-app**: Flutter app for uploading media
- **shared**: Common types and utilities

### 2. Follow Code Standards

- Use TypeScript for all new code
- Follow ESLint configuration
- Use Prettier for code formatting
- Write tests for new features
- Update documentation as needed

### 3. Commit Guidelines

This project uses [Conventional Commits](https://conventionalcommits.org/):

```bash
# Examples
git commit -m "feat: add user authentication"
git commit -m "fix: resolve memory leak in image upload"
git commit -m "docs: update API documentation"
git commit -m "test: add unit tests for user service"
```

### 4. Changesets

For any changes that affect package versions, create a changeset:

```bash
pnpm changeset
```

Follow the prompts to describe your changes and select affected packages.

## 🧪 Testing

### Running Tests

```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run tests with coverage
pnpm test:coverage
```

### Writing Tests

- Write unit tests for utilities and services
- Write integration tests for API endpoints
- Write E2E tests for critical user flows
- Aim for 80% code coverage minimum

## 📚 Documentation

### Updating Documentation

1. Update relevant README files
2. Update API documentation in `docs/api/`
3. Update architecture documentation if needed
4. Update this contributing guide if processes change

### Documentation Standards

- Use clear, concise language
- Include code examples where helpful
- Keep documentation up-to-date with code changes
- Use proper markdown formatting

## 🔄 Pull Request Process

### 1. Before Submitting

- [ ] All tests pass
- [ ] Code is properly formatted
- [ ] Linting passes
- [ ] Documentation is updated
- [ ] Changeset is created (if needed)

### 2. Pull Request Description

Include:
- Description of changes
- Motivation for changes
- Screenshots (if UI changes)
- Testing instructions
- Breaking changes (if any)

### 3. Review Process

1. Automated checks (CI) must pass
2. At least one maintainer review required
3. Address review feedback
4. Merge when approved

## 🔒 Security

- Report security issues via email to [security@plantita.com](mailto:security@plantita.com)
- Do not report security issues in public issues
- Follow responsible disclosure practices

## 📋 Code of Conduct

- Be respectful and inclusive
- Use welcoming language
- Be collaborative
- Focus on what is best for the community
- Show empathy towards other community members

## 🤝 Getting Help

- Check existing issues and documentation first
- Use [GitHub Discussions](https://github.com/plantita/plantita/discussions) for questions
- Join our community Slack/Discord (if available)

## 📄 License

By contributing to Plantita, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to Plantita! 🎉