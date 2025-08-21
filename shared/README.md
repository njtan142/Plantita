# @plantita/shared

Shared types, utilities, and constants for Plantita monorepo applications.

## Installation

This package is part of the Plantita monorepo and should be installed via pnpm workspaces:

```bash
pnpm install
```

## Usage

```typescript
import { User, generateId, ApiResponse } from '@plantita/shared';

// Generate a unique ID
const id = generateId();

// Type definitions
const user: User = {
  id: 'user-123',
  username: 'johndoe',
  email: 'john@example.com',
  createdAt: new Date(),
  updatedAt: new Date()
};

// API response type
const response: ApiResponse<User> = {
  success: true,
  data: user
};
```

## API Reference

### Types

- `ID` - String type for unique identifiers
- `BaseEntity` - Base interface for entities with id and timestamps
- `User` - User entity interface
- `Media` - Media entity interface
- `Post` - Post entity interface
- `ApiResponse<T>` - Generic API response wrapper
- `PaginatedResponse<T>` - Paginated API response

### Utilities

- `generateId()` - Generate a unique identifier
- `formatDate(date)` - Format date to ISO string
- `sleep(ms)` - Promise-based sleep utility
- `isValidEmail(email)` - Email validation
- `isValidUsername(username)` - Username validation

### Constants

- `MAX_FILE_SIZE` - Maximum file upload size (10MB)
- `ALLOWED_MIME_TYPES` - Array of allowed MIME types
- `API_ENDPOINTS` - API endpoint constants

### Error Classes

- `ApiError` - API error with status code
- `ValidationError` - Validation error with field info
- `AuthenticationError` - Authentication failure
- `AuthorizationError` - Authorization failure

## Development

```bash
# Build the package
pnpm build

# Run in watch mode
pnpm build:dev

# Run tests
pnpm test

# Type checking
pnpm typecheck
```

## License

MIT