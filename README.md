# Attendance Service

The Attendance Service is a Spring Boot-based application designed to manage employee attendance and leave requests. 
It provides a set of RESTful APIs for both admin and user (employee/admin) access, 
utilizing PostgreSQL as the database, NGINX as the API gateway, Eureka for service discovery, and Docker for deployment.

## Features
- Record and manage employee check-ins and check-outs.
- Calculate working hours for individual attendance records and total hours for employees.
- Submit, approve, reject, and delete leave requests with status tracking.
- Retrieve attendance counts and leave balances for specific months.
- Fetch all attendance and leave records for employees.

## Technologies
- **Language**: Java
- **Framework**: Spring Boot
- **Database**: PostgreSQL
- **API Gateway**: NGINX
- **Service Discovery**: Eureka
- **Deployment**: Docker

## API Endpoints

### Admin Access Endpoints
These endpoints are restricted to admin users only.

- **PUT `/attendance/leaves/{leaveId}/status`**
    - **Description**: Update the status (e.g., APPROVED, REJECTED) of a leave request.
    - **Request Parameters**:
        - `leaveId` (path variable): ID of the leave request.
        - `status` (query param): New status (e.g., "APPROVED").
        - `employeeId` (header): ID of the admin performing the action.
    - **Response**:
        - `200 OK` with updated leave details.
        - `400 Bad Request` for invalid input.
        - `403 Forbidden` if not an admin.
        - `404 Not Found` if leave ID is invalid.

### User Access Endpoints
These endpoints are accessible to both employees and admins.

- **POST `/attendance/{employeeId}`**
    - **Description**: Record both check-in and check-out for an employee.
    - **Request Body**: `AttendanceRequest` (date, checkInTime, checkOutTime).
    - **Response**:
        - `200 OK` with saved attendance record.
        - `400 Bad Request` for invalid input.

- **POST `/attendance/check-in/{employeeId}`**
    - **Description**: Record check-in for an employee.
    - **Request Body**: `CheckInRequest` (date, checkInTime).
    - **Response**:
        - `200 OK` with saved attendance record.
        - `400 Bad Request` for invalid input.

- **PUT `/attendance/check-out/{recordId}`**
    - **Description**: Record check-out for an existing attendance record.
    - **Request Body**: `CheckOutRequest` (checkOutTime).
    - **Response**:
        - `200 OK` with updated attendance record.
        - `400 Bad Request` if check-out time is invalid.
        - `404 Not Found` if record ID is invalid.

- **GET `/attendance/{employeeId}`**
    - **Description**: Retrieve all attendance records for an employee.
    - **Response**:
        - `200 OK` with list of attendance records.
        - `404 Not Found` if no records exist.

- **GET `/attendance/hours/{recordId}`**
    - **Description**: Calculate working hours for a specific attendance record.
    - **Response**:
        - `200 OK` with working hours.
        - `400 Bad Request` if record is incomplete.
        - `404 Not Found` if record ID is invalid.

- **GET `/attendance/employee/{employeeId}/hours`**
    - **Description**: Calculate total working hours for an employee over a date range.
    - **Request Parameters**:
        - `startDate` (query param): Start date of the range.
        - `endDate` (query param): End date of the range.
    - **Response**:
        - `200 OK` with total working hours.
        - `400 Bad Request` for invalid date range.

- **POST `/attendance/leaves/request`**
    - **Description**: Apply for a leave request.
    - **Request Body**: `LeaveRequest` (startDate, endDate, reason, leaveType).
    - **Request Header**: `employeeId` (required).
    - **Response**:
        - `200 OK` with saved leave request.
        - `400 Bad Request` for invalid input.

- **GET `/attendance/employee/{employeeId}/attendance-count`**
    - **Description**: Get the number of attended days for an employee in a specific month.
    - **Request Parameter**: `month` (query param, format: "yyyy-MM").
    - **Response**:
        - `200 OK` with attendance count.
        - `400 Bad Request` for invalid month format.

- **GET `/attendance/employee/{employeeId}/leave-balance`**
    - **Description**: Check the leave balance for an employee in a specific month.
    - **Request Parameter**: `month` (query param, format: "yyyy-MM").
    - **Response**:
        - `200 OK` with leave balance.
        - `400 Bad Request` for invalid month format.

- **DELETE `/attendance/leaves/{leaveId}`**
    - **Description**: Delete a pending leave request.
    - **Response**:
        - `204 No Content` on success.
        - `400 Bad Request` if leave is not pending or invalid.

- **GET `/attendance/leaves/employee/{employeeId}`**
    - **Description**: Fetch all leave requests for a specific employee.
    - **Request Parameters**:
        - `startDate` (optional, query param): Start date of the range.
        - `endDate` (optional, query param): End date of the range.
    - **Response**:
        - `200 OK` with list of leave requests.
        - `204 No Content` if no leave requests found.
        - `400 Bad Request` if employee not found or invalid date range.

## Prerequisites
- **Java 17** or higher.
- **Maven 3.6+**.
- **PostgreSQL 15+**.
- **Docker** and **Docker Compose** for containerized deployment.
- **NGINX** for API gateway.
- **Eureka Server** for service discovery.

## How to Run the Service

### Local Setup
Follow these steps to run the Attendance Service locally on your machine.

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Attendance_service

2. **Set Up PostgreSQL**
- Install PostgreSQL if not already installed.
- Create a database named attendance_db using below command:

   `CREATE DATABASE attendance_db;`

- Update the database configuration in src/main/resources/application.properties or application-dev.properties:
  
 `spring.datasource.url=jdbc:postgresql://localhost:5432/attendance_db
  spring.datasource.username=your_username
  spring.datasource.password=your_password
  spring.jpa.hibernate.ddl-auto=update
  spring.jpa.show-sql=true `

3. **Configure Eureka (Optional for Local Setup)**
   - If running locally without Eureka, ensure application.properties has:
   `eureka.client.enabled=false`
   If using Eureka, ensure an Eureka Server is running and update:

    `eureka.client.serviceUrl.defaultZone=http://localhost:8761/eureka/`

4. **Build the Project**
   - Compile and package the application using Maven:
    `mvn clean install`

5. **Run the Application**
   - Start the application with the dev profile:
    `mvn spring-boot:run -Dspring.profiles.active=dev`
   
- The service will be available at http://localhost:8080.

- Test the Endpoints
Use a tool like Postman or cURL to test the API endpoints (e.g., POST /attendance/1).
Example request:

`curl -X POST http://localhost:8080/attendance/1 \
-H "Content-Type: application/json" \
-d '{"date": "2025-05-15", "checkInTime": "09:00:00", "checkOutTime": "17:00:00"}'`

6. **Docker Deployment**

   - Follow these steps to deploy the Attendance Service using Docker, along with NGINX and Eureka.

       - Build the Docker Image
         - Ensure you have a Dockerfile in the project root. Example Dockerfile:
           dockerfile
           `FROM openjdk:17-jdk-slim
           WORKDIR /app
           COPY target/Attendance_service-0.0.1-SNAPSHOT.jar app.jar
           ENTRYPOINT ["java", "-jar", "app.jar"]`

         - Build the Docker image:

            `docker build -t attendance-service:latest .`
         - 
7. **Set Up Docker Compose**
   - Create a docker-compose.yml file to orchestrate the services (PostgreSQL, Eureka, NGINX, and Attendance Service):
    ```version: '3.8'
    services:
    postgres:
    image: postgres:15
    environment:
    POSTGRES_DB: attendance_db
    POSTGRES_USER: your_username
    POSTGRES_PASSWORD: your_password
    ports:
         - "5432:5432"
         volumes:
         - postgres_data:/var/lib/postgresql/data
    
    eureka:
    image: springcloud/eureka
    ports:
    - "8761:8761"
    environment:
      - EUREKA_SERVER_ADDRESS=http://eureka:8761/eureka/
    
    attendance-service:
    image: attendance-service:latest
    depends_on:
    - postgres
      - eureka
      environment:
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/attendance_db
      - SPRING_DATASOURCE_USERNAME=your_username
      - SPRING_DATASOURCE_PASSWORD=your_password
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka:8761/eureka/
      ports:
      - "8080:8080"
    
    nginx:
    image: nginx:latest
    ports:
    - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      depends_on:
      - attendance-service
    
    volumes:
    postgres_data:```
      

- Create an nginx.conf file for the API gateway:
      `events {}
      http {
        upstream attendance_service {
        server attendance-service:8080;
      }
      server {
        listen 80;
        location / {
            proxy_pass http://attendance_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            }
        }
      }`

8. **Run Docker Compose**
   - Start all services:

    `docker-compose up -d`

    - Verify the services are running:
   
     `docker-compose ps`

    - Access the Service
   
    The Attendance Service will be available through NGINX at http://localhost/attendance/....
    Test the endpoints using a tool like Postman or cURL.
    Stop the Services

    - To stop and remove the containers:

     `docker-compose down`