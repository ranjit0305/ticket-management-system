# Ticket Management System

A full-stack ticket-management application built with Flutter, FastAPI, PostgreSQL, Redis, and Docker. It allows teams to create, assign, track, and manage support tickets securely.

## Architecture

```text
Flutter mobile app
        |
        | REST API + JWT
        v
FastAPI backend ------> PostgreSQL (persistent data)
        |
        └-------------> Redis (ticket-list cache)
```

## Features

- JWT-based login and protected API endpoints
- Role-based access: `admin` and `user`
- Ticket creation, viewing, updating, assignment, and deletion
- Ticket priority and status tracking
- Admin user management
- User profile fields: full name, email, and department
- PostgreSQL persistence through SQLAlchemy
- Redis caching of ticket lists, with invalidation after ticket changes
- Flutter client for Android, iOS, web, desktop, and mobile targets

## Roles and permissions

| Capability | Admin | User |
| --- | :---: | :---: |
| View tickets | All tickets | Assigned tickets only |
| Create tickets | Yes | Yes |
| Update tickets | Yes | Assigned tickets only |
| Assign tickets | Yes | No |
| Delete tickets | Yes | No |
| Create and view users | Yes | No |

## Project structure

```text
ticket_management_system/
├── backend/ticket_management_backend/
│   ├── main.py            # FastAPI routes
│   ├── models.py          # SQLAlchemy User and Ticket models
│   ├── schemas.py         # Request and response validation
│   ├── dependencies.py    # JWT and role checks
│   ├── database.py        # PostgreSQL configuration
│   ├── redis_client.py    # Redis configuration
│   └── docker-compose.yml # Backend, PostgreSQL, Redis services
├── frontend/ticket_management_app/
│   └── lib/
│       ├── main.dart      # App entry point and login restore
│       ├── services/      # HTTP API client
│       ├── models/        # Flutter data models
│       └── widgets/       # App screens
└── postman/               # API-testing configuration
```

## Run the backend locally

### Prerequisites

- Docker Desktop

From the backend directory, start all backend services:

```bash
cd backend/ticket_management_backend
docker compose up --build
```

This starts:

- FastAPI at `http://localhost:8000`
- PostgreSQL at port `5432`
- Redis at port `6379`

FastAPI documentation is available at `http://localhost:8000/docs`.

## Run the Flutter app

### Prerequisites

- Flutter SDK
- An Android emulator, device, or another Flutter target

```bash
cd frontend/ticket_management_app
flutter pub get
flutter run
```

The API base URL is configured in `lib/services/ticket_service.dart`. For a local Android emulator, use `http://10.0.2.2:8000`; for a physical device, use the local network address of the machine running the backend.

## API overview

| Method | Endpoint | Purpose | Access |
| --- | --- | --- | --- |
| `POST` | `/register` | Register a user | Public |
| `POST` | `/login` | Log in and receive a JWT | Public |
| `GET` | `/tickets` | Get accessible tickets | Authenticated |
| `POST` | `/tickets` | Create a ticket | Authenticated |
| `PUT` | `/tickets/{ticket_id}` | Update a ticket | Admin or assigned user |
| `DELETE` | `/tickets/{ticket_id}` | Delete a ticket | Admin |
| `PUT` | `/tickets/{ticket_id}/assign/{user_id}` | Assign a ticket | Admin |
| `GET` | `/users` | List users | Admin |
| `POST` | `/users` | Create a user | Admin |

## Data model

### User

- `id`
- `username`
- `password` — stored as a bcrypt hash
- `role`
- `full_name`
- `email`
- `department`

### Ticket

- `id`
- `title`
- `description`
- `priority`
- `status`
- `created_by`
- `assigned_to`

## Authentication and caching

The backend creates a JWT after a successful login. The Flutter app stores the token locally and sends it as a Bearer token for protected requests.

Ticket lists are cached in Redis for 60 seconds. Creating, updating, assigning, or deleting a ticket clears relevant cached ticket lists so the app receives fresh data.
