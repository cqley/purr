(() => {
  const r = document.documentElement;
  try { const t = localStorage.getItem("theme"); if (t) r.dataset.theme = t; } catch {}
  const dark = () => getComputedStyle(r).colorScheme.includes("dark");
  const init = () => {
    const b = document.createElement("button");
    b.id = "theme";
    b.type = "button";
    b.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>';
    b.title = dark() ? "light mode" : "dark mode";
    b.onclick = () => {
      r.dataset.theme = dark() ? "light" : "dark";
      try { localStorage.setItem("theme", r.dataset.theme); } catch {}
      b.title = dark() ? "light mode" : "dark mode";
    };
    document.body.append(b);
  };
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
