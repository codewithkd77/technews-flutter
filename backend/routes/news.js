const express = require("express");
const router = express.Router();
const path = require("path");
const News = require(path.join(__dirname, "../models/News"));



router.get("/", async (req, res) => {
  try {
    const news = await News.find().sort({ createdAt: -1 });
    res.json(news);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add News
router.post("/", async (req, res) => {
  try {
    const { title, description, imageUrl } = req.body;
    const news = new News({ title, description, imageUrl });
    await news.save();
    res.status(201).json(news);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete News
router.delete("/:id", async (req, res) => {
  try {
    await News.findByIdAndDelete(req.params.id);
    res.json({ message: "News deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
