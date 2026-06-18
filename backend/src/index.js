import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import projectsRouter from "./routes/projects.js";
import donationsRouter from "./routes/donations.js";
import notificationsRouter from "./routes/notifications.js";
import mediaRouter from "./routes/media.js";
import contentRouter from "./routes/content.js";
import crmRouter from "./routes/crm.js";
import feedbackRouter from "./routes/feedback.js";
import dashboardRouter from "./routes/dashboard.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.get("/api/health", (_req, res) => res.json({ ok: true, service: "aafed-api" }));

app.use("/api/projects", projectsRouter);
app.use("/api/donations", donationsRouter);
app.use("/api/notifications", notificationsRouter);
app.use("/api/media", mediaRouter);
app.use("/api/content", contentRouter);
app.use("/api/crm", crmRouter);
app.use("/api/feedback", feedbackRouter);
app.use("/api/dashboard", dashboardRouter);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "internal_error" });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`AAFED API يعمل على http://localhost:${PORT}`));
