# ChatPlay 🎮💬

ChatPlay is a feature-rich, real-time social platform that combines instant messaging with interactive gaming. Built using Java Servlets, JSP, and MySQL, it offers a seamless experience for users to connect, chat, and challenge each other to games.

## 🚀 Features

- **Real-Time Messaging**: Instant one-on-one chat with friends.
- **Friend System**: Send, accept, or decline friend requests and manage your friends list.
- **Gaming Hub**:
    - **Tic-Tac-Toe**: Classic board game with real-time turn tracking.
    - **Rock Paper Scissors**: Fast-paced interactive game.
    - **Game Invites**: Challenge friends directly from the chat or dashboard.
- **User Profiles**: Custom profiles with bios and profile pictures.
- **Admin Dashboard**: Comprehensive management tools for monitoring reports, managing users (ban/unban), and viewing platform statistics.
- **Safety & Reporting**: User reporting system to maintain a healthy community.
- **Responsive UI**: A modern, clean interface designed for both desktop and mobile.

## 🛠️ Tech Stack

- **Backend**: Java 11, Jakarta EE 10 (Servlets)
- **Frontend**: JSP (JavaServer Pages), Vanilla CSS, JavaScript
- **Database**: MySQL 8.0
- **Build Tool**: Maven
- **Server**: Compatible with Apache Tomcat 10+

## ⚙️ Prerequisites

- **Java JDK 11** or higher.
- **Apache Tomcat 10.1** (Jakarta EE 10 compatible).
- **MySQL Server 8.0**.
- **Maven** for dependency management.

## 🏗️ Getting Started

### 1. Database Setup
1. Open your MySQL client.
2. Run the commands provided in `src/main/webapp/schema.sql`. This will create the `chatdb` database and all necessary tables (`users`, `friends`, `messages`, `game_invites`, `games`, `reports`).

### 2. Configuration
Update the database credentials in `src/main/java/com/chatapp/DBConnection.java`:
```java
con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/chatdb",
    "YOUR_USERNAME",
    "YOUR_PASSWORD"
);
```

### 3. Build & Deploy
1. Clone the repository.
2. Navigate to the project root and build the project using Maven:
   ```bash
   mvn clean install
   ```
3. Deploy the generated `.war` file (found in the `target/` directory) to your Tomcat server.

## 📂 Project Structure

- `src/main/java/com/chatapp/`: Contains Java Servlets for handling backend logic (Authentication, Messaging, Games, Admin).
- `src/main/webapp/`: Contains JSP files for the frontend, CSS styles, and client-side JavaScript.
- `src/main/webapp/schema.sql`: Database schema definition.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
