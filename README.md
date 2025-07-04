

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

An example application built with dart_frog

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis


# Dart Frog, JWT, and Neon DB: Secure & Scalable Backend API

[![Dart Frog](https://img.shields.io/badge/Dart_Frog-1.x-blue?logo=dart)](https://dartfrog.vgv.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue?logo=postgresql)](https://www.postgresql.org/)
[![Neon DB](https://img.shields.io/badge/Neon_DB-Serverless-green?logo=postgresql)](https://neon.tech/)
[![JWT](https://img.shields.io/badge/JWT-Authentication-lightgrey?logo=json-web-tokens)](https://jwt.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Overview

This project demonstrates how to build a robust, secure, and scalable backend API using **Dart Frog**, a minimalist Dart backend framework, for handling API requests. It integrates **JSON Web Tokens (JWT)** for stateless authentication and leverages **Neon DB**, a serverless PostgreSQL database, for flexible and scalable data storage.

A key feature of this project is its **custom command-line interface (CLI)**, which simplifies environment variable management and automates database tasks like migrations and seeding.

## ✨ Features

* **Dart Frog API**: Fast and lightweight API development.
* **JWT Authentication**: Secure user registration, login, and protected routes using stateless JWTs.
* **Neon DB Integration**: Connects to a scalable serverless PostgreSQL database.
* **Custom CLI (`app_cli.sh`)**:
    * Streamlined environment variable injection from a single connection string.
    * Automated database migrations (`migrate` command).
    * Automated database seeding (`seed` command).
* **Structured Project Layout**: Clear separation of concerns (routes, models, repositories, utilities).
* **Secure Password Hashing**: Uses `bcrypt` for robust password storage.
* **Centralized Logging**: Integrated `logger` for better debugging and monitoring.

## 🛠️ Technologies Used

* **Dart**: Programming Language (v3.x)
* **Dart Frog**: Web Framework (v1.x)
* **PostgreSQL**: Relational Database
* **Neon DB**: Serverless PostgreSQL Provider
* **`postgres.dart`**: Dart PostgreSQL client library
* **`dart_jsonwebtoken`**: Dart JWT library
* **`bcrypt`**: Dart password hashing library
* **`dart_frog_auth`**: Dart Frog authentication package
* **`logger`**: Dart logging utility
* **`uuid`**: Dart UUID generation library
* **Shell Scripting**: For custom CLI commands (`app_cli.sh`)

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your system:

* **Dart SDK**: [Install Dart](https://dart.dev/get-dart) (v3.0 or higher recommended).
* **Dart Frog CLI**:
    ```bash
    dart pub global activate dart_frog_cli
    ```
* **Git**: For cloning the repository.
* **A Neon DB Account**: [Sign up for Neon](https://neon.tech/). You'll need your project's connection string.
* **(Optional) pgAdmin**: A GUI tool for managing PostgreSQL databases, useful for verifying your Neon DB connection.
