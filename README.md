# Plantita Monorepo

A comprehensive social media application built with modern web technologies and Flutter.

## 📋 Overview

Plantita is a social media platform that allows users to capture, upload, and view media content. The project is structured as a monorepo containing multiple applications and shared libraries.

## 🏗️ Architecture

This monorepo contains the following packages:

- **`system-backend`** - Node.js backend handling all core logic and database operations
- **`admin-dashboard`** - Next.js application for administrative functions
- **`user-app`** - Flutter application for viewing media
- **`uploader-app`** - Flutter application for capturing and uploading media
- **`shared`** - Shared types, utilities, and constants between applications
- **`docker`** - Docker configurations for containerization

## 🚀 Quick Start

### Prerequisites

- Node.js 18.0.0 or higher
- pnpm 8.0.0 or higher
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/plantita.git
cd plantita

# Install dependencies
pnpm install

# Build all packages
pnpm build
```

### Development

```bash
# Start all applications in development mode
pnpm dev

# Start specific applications
pnpm dev:backend      # System backend
pnpm dev:admin        # Admin dashboard
pnpm dev:user-app     # User app
pnpm dev:uploader-app # Uploader app
```

### Testing

```bash
# Run tests for all packages
pnpm test

# Run tests in watch mode
pnpm test:watch

# Generate coverage reports
pnpm test:coverage
```

### Building

```bash
# Build all packages
pnpm build

# Build specific package
cd packages/shared && pnpm build
```

## 📁 Project Structure

```
plantita/
├── system-backend/          # Node.js backend
├── admin-dashboard/         # Next.js admin dashboard
├── user-app/                # Flutter user app
├── uploader-app/            # Flutter uploader app
├── shared/                  # Shared utilities and types
├── docker/                  # Docker configurations
├── docs/                    # Documentation
│   ├── api/                 # API documentation
│   ├── guides/              # Development guides
│   └── architecture/        # Architecture documentation
├── .github/                 # GitHub Actions workflows
└── .changeset/              # Changeset configuration
```

## 🛠️ Technology Stack

### Backend
- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT
- **Validation**: Zod

### Frontend (Admin Dashboard)
- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **UI Components**: shadcn/ui
- **State Management**: Zustand

### Mobile Apps (Flutter)
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider/Riverpod
- **Networking**: Dio

### Development Tools
- **Package Manager**: pnpm
- **Build Tool**: tsup (for shared packages)
- **Testing**: Jest + Vitest
- **Linting**: ESLint
- **Formatting**: Prettier
- **Git Hooks**: Husky + lint-staged
- **Version Management**: Changesets
- **CI/CD**: GitHub Actions

## 📦 Package Management

This monorepo uses pnpm workspaces for efficient package management. All packages are defined in `pnpm-workspace.yaml`.

### Adding Dependencies

```bash
# Add to root (all packages)
pnpm add -D typescript

# Add to specific package
pnpm add -D typescript --filter shared
```

### Publishing Packages

This project uses Changesets for version management and automated publishing:

```bash
# Create a new changeset
pnpm changeset

# Version packages (creates PR)
pnpm version

# Publish packages
pnpm release
```

## 🧪 Testing Strategy

- **Unit Tests**: Jest for backend and utilities
- **Integration Tests**: Supertest for API endpoints
- **E2E Tests**: Playwright for frontend applications
- **Mobile Tests**: Flutter integration tests

## 🚢 Deployment

### Docker

```bash
# Build Docker images
docker build -f docker/Dockerfile -t plantita/monorepo .

# Run with Docker Compose
docker-compose -f docker/docker-compose.yml up
```

### CI/CD

- **CI**: Automated testing on every push/PR
- **Release**: Automated publishing via Changesets
- **Docker**: Automated image building and deployment

## 📚 Documentation

- **API Documentation**: Available in `docs/api/`
- **Development Guides**: Available in `docs/guides/`
- **Architecture**: Available in `docs/architecture/`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Create a changeset for your changes
6. Submit a pull request

### Development Workflow

1. **Setup**: Run `pnpm install` to install dependencies
2. **Development**: Use `pnpm dev` to start development servers
3. **Testing**: Run `pnpm test` to execute test suites
4. **Building**: Use `pnpm build` to build all packages
5. **Changesets**: Use `pnpm changeset` to document changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development Team**: Plantita Team
- **Contact**: your-email@example.com

## 🔄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and updates.