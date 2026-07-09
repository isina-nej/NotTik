# 2. Pigeon Native Bridge

Date: 2026-07-09

## Status
Accepted

## Context
With Room (Kotlin) as the single source of truth, the Flutter UI needs a way to query history, search, and update settings. Writing raw `MethodChannel` code for all these complex queries and data models is error-prone and tedious.

## Decision
We will use `pigeon` to define our data transfer objects (DTOs) and API interfaces in Dart, and generate the corresponding Kotlin and Dart code. 
Flutter will call `Api.getNotifications(...)` and receive typed Dart objects constructed safely from the native Room query results.

## Consequences
- **Positive:** Type safety across the boundary. Less boilerplate.
- **Negative:** Adds a code-generation step to the build process. DTOs must be kept lightweight to avoid stalling the platform channel with massive data serialization.
