// يحسب حالة المشروع (في الموعد / خطر تأخّر / متأخّر) من المرحلة الجارية.
export function computeStatus(stages, today = new Date()) {
  const now = stages.find((s) => s.state === "now");
  if (!now || !now.planned_end) {
    return { status: "on_track", label: "في الموعد", delayDays: 0 };
  }
  const end = new Date(now.planned_end);
  const delayDays = Math.round((today - end) / 86400000);

  if (delayDays > 0) {
    return { status: "delayed", label: "متأخّر", delayDays };
  }
  // خطر تأخّر: باقي ≤ 14 يوم والتقدّم أقل من 80%
  if (delayDays >= -14 && (now.progress ?? 0) < 80) {
    return { status: "at_risk", label: "خطر تأخّر", delayDays };
  }
  return { status: "on_track", label: "في الموعد", delayDays };
}
