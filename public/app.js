const SEARCH_RESULT_LIMIT = 12;
const CHART_LOAD_TIMEOUT_MS = 20000;

function initializeSearch() {
  const select = document.querySelector("#symbol");
  if (!select || typeof TomSelect === "undefined") return;
  new TomSelect(select, {
    create: false,
    maxOptions: SEARCH_RESULT_LIMIT,
    selectOnTab: true,
    closeAfterSelect: true,
    placeholder: "Search company or ticker…",
    onChange: submitStock,
  });
}

function submitStock(value) {
  if (value) document.querySelector("#stock-form").requestSubmit();
}

function setChartStatus(message) {
  document.querySelector("#chart-status").textContent = message;
}

function observeChart(container, timeout) {
  const observer = new MutationObserver(() => {
    const frame = container.querySelector("iframe");
    if (!frame) return;
    initializeChartFrame(frame, timeout);
    observer.disconnect();
  });
  observer.observe(container, { childList: true, subtree: true });
}

function initializeChartFrame(frame, timeout) {
  frame.title = "Interactive stock price chart by TradingView";
  frame.addEventListener("load", () => {
    clearTimeout(timeout);
    setChartStatus("Use the chart toolbar for indicators, drawing tools, and more. If data is unavailable, open the stock on TradingView.");
  });
}

function appendChartScript(container, timeout) {
  const script = document.createElement("script");
  script.src = container.dataset.chartSrc;
  script.async = true;
  script.textContent = document.querySelector("#chart-options").textContent;
  script.addEventListener("error", () => {
    clearTimeout(timeout);
    showChartDelay();
  });
  container.querySelector(".tradingview-widget-container").append(script);
}

function initializeChart() {
  const container = document.querySelector(".chart-frame");
  if (!container) return;
  const timeout = setTimeout(showChartDelay, CHART_LOAD_TIMEOUT_MS);
  observeChart(container, timeout);
  appendChartScript(container, timeout);
}

function showChartDelay() {
  setChartStatus("The chart is taking longer to load. Check your connection, reload this page, or use Open on TradingView above.");
}

initializeSearch();
initializeChart();
