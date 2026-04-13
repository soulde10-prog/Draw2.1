
const express = require("express");
const app = express();
app.use(express.json());

let projects = [];

app.post("/projects", (req, res) => {
  const id = Date.now().toString();
  const p = { id, ...req.body };
  projects.push(p);
  res.json(p);
});

app.get("/projects/:id", (req, res) => {
  res.json(projects.find(p => p.id === req.params.id));
});

app.listen(3001);
