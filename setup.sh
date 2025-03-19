#!/bin/bash

# Project Name
PROJECT_NAME="simple-rest-api"

# Create project directory
mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Initialize a Node.js project
npm init -y

# Install dependencies
npm install express mongoose body-parser dotenv cors

# Create required directories
mkdir -p config models routes

# Create server.js
cat <<EOF > server.js
const express = require("express");
const mongoose = require("./config/database");
const userRoutes = require("./routes/userRoutes");
require("dotenv").config();

const app = express();
app.use(express.json());

app.use("/api/users", userRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(\`Server running on port \${PORT}\`);
});
EOF

# Create database config file
cat <<EOF > config/database.js
const mongoose = require("mongoose");
require("dotenv").config();

mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log("MongoDB connected"))
.catch(err => console.log(err));

module.exports = mongoose;
EOF

# Create User model
cat <<EOF > models/User.js
const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true }
});

module.exports = mongoose.model("User", UserSchema);
EOF

# Create user routes
cat <<EOF > routes/userRoutes.js
const express = require("express");
const router = express.Router();
const User = require("../models/User");

// GET API: Fetch all users
router.get("/", async (req, res) => {
    try {
        const users = await User.find();
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// POST API: Add a new user
router.post("/", async (req, res) => {
    try {
        const { name, email } = req.body;
        const newUser = new User({ name, email });
        await newUser.save();
        res.status(201).json(newUser);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

module.exports = router;
EOF

# Create .env file
cat <<EOF > .env
PORT=5000
MONGO_URI=mongodb://mongodb:27017/demoapi
EOF

# Create Dockerfile
cat <<EOF > Dockerfile
# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy application files
COPY . .

# Expose port
EXPOSE 5000

# Start the application
CMD ["node", "server.js"]
EOF

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongodb_container
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

  app:
    build: .
    container_name: node_app
    ports:
      - "5000:5000"
    depends_on:
      - mongodb
    env_file:
      - .env

volumes:
  mongo_data:
EOF

# Build and start the Docker containers
docker-compose up --build -d

# Confirm running containers
docker ps

echo "🚀 Node.js REST API with MongoDB in Docker is ready and running!"
