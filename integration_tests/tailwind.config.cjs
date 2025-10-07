/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./specs/**/*.{ts,tsx,js,jsx,html}'],
  theme: {
    extend: {},
  },
  corePlugins: {
    preflight: false,
  },
};
