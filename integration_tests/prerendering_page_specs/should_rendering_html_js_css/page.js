const prerendering_content = document.getElementById('prerendering_content');
const content = document.getElementById('content');
prerendering_content.textContent = 'prerendering window width: ' + window.innerWidth;
window.addEventListener('DOMContentLoaded', () => {
  content.textContent = 'rendered window width: ' + window.innerWidth;
});

