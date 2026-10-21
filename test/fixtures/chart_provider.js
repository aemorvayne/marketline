const frame = document.createElement("iframe");
frame.srcdoc = "<p>Chart provider test double</p>";
document.currentScript.parentElement.querySelector(".tradingview-widget-container__widget").append(frame);
