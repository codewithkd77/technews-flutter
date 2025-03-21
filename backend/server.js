const express = require("express");
const cors = require("cors");
require("dotenv").config();
const connectDB = require("./config/db");

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to Database
connectDB();

// Middleware
app.use(express.json());
app.use(cors());

// Routes
const newsRoutes = require("./routes/news");
app.use("/api/news", newsRoutes);

app.get("/", (req, res) => {
  res.send("Welcome to the Tech News API");
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
