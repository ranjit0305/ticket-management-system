#  Ticket Management System

A full-stack **Ticket Management System** built using **Flutter, FastAPI, PostgreSQL, Redis, and Docker**.

The application provides secure authentication, role-based authorization, ticket management, ticket assignment, caching, and a mobile application interface.

---

#  Features

## Authentication & Authorization

- User registration
- User login
- JWT-based authentication
- Role-based access control
- Protected API endpoints
- Admin-only operations
- User-specific ticket permissions

##  Ticket Management

- Create tickets
- View tickets
- Update tickets
- Assign tickets to users
- Delete tickets
- Ticket priority management
- Ticket status management
- Permission-based ticket editing

##  Admin Features

- View all tickets
- Assign tickets to users
- Delete tickets
- Manage ticket assignments
- Access admin-protected endpoints

## User Features

- Login securely
- Create tickets
- View accessible tickets
- Update tickets assigned to them
- Track ticket status and priority

##  Redis Caching

- Redis-based ticket caching
- User-specific ticket cache
- Cache invalidation after ticket modifications
- Improved API response performance

## PostgreSQL Database

- PostgreSQL relational database
- SQLAlchemy ORM
- Persistent database storage
- Docker volume for database persistence

##  Docker

- Containerized backend
- PostgreSQL container
- Redis container
- Docker Compose orchestration
- Docker service-to-service networking
  
##  Flutter Application

- Android mobile application
- Login interface
- Ticket management interface
- API integration with FastAPI backend
- JWT authentication
- Android Emulator support

## API Testing

- REST API testing using Postman
- FastAPI Swagger documentation
- Authentication testing
- Ticket CRUD testing
- Ticket assignment testing
- Permission testing

---

# 🏗️ System Architecture

```text
                    ┌──────────────────────┐
                    │     Flutter App      │
                    │    Android Client    │
                    └──────────┬───────────┘
                               │
                               │ HTTP / REST API
                               ▼
                    ┌──────────────────────┐
                    │       FastAPI        │
                    │       Backend        │
                    └──────────┬───────────┘
                               │
                  ┌────────────┴────────────┐
                  │                         │
                  ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │    PostgreSQL    │      │      Redis       │
        │     Database     │      │      Cache       │
        └──────────────────┘      └──────────────────┘
