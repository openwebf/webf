/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#007bff',
      },
      spacing: {
        '70': '17.5rem',
      },
      maxWidth: {
        '70p': '70%',
      }
    },
  },
  plugins: [],
}