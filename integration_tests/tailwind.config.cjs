/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './specs/**/*.{ts,tsx,js,jsx,html}',
    '../use_cases/src/**/*.{ts,tsx,js,jsx}',
  ],
  theme: {
    extend: {},
  },
  corePlugins: {
    preflight: false,
  },
};
