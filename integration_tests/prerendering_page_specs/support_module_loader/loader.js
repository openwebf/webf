function loadJS(path) {
  const script = document.createElement('script');
  script.src = path;
  document.body.appendChild(script);
}
