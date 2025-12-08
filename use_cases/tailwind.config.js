/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'media',
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      keyframes: {
        'pulse-scale': {
          '0%': { transform: 'scale(1)', opacity: '1' },
          '50%': { transform: 'scale(1.1)', opacity: '.7' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
      },
      animation: {
        'spin-slow': 'spin 2s linear infinite',
        'bounce-fast': 'bounce 0.6s ease-in-out infinite',
        'pulse-scale': 'pulse-scale 1.5s ease-in-out infinite',
      },
      colors: {
        // Foreground/text tokens
        fg: {
          DEFAULT: 'var(--font-color)',
          primary: 'var(--font-color-primary)',
          secondary: 'var(--font-color-secondary)',
        },
        // Background/surface tokens
        surface: {
          DEFAULT: 'var(--background-primary)',
          primary: 'var(--background-primary)',
          secondary: 'var(--background-secondary)',
          tertiary: 'var(--background-tertiary)',
          tocActive: 'var(--background-toc-active)',
          hover: 'var(--background-hover)',
          markYellow: 'var(--background-mark-yellow)',
          information: 'var(--background-information)',
          warning: 'var(--background-warning)',
          critical: 'var(--background-critical)',
          success: 'var(--background-success)',
        },
        // Border/lines tokens
        line: {
          DEFAULT: 'var(--border-color)',
          primary: 'var(--border-primary)',
          secondary: 'var(--border-secondary)',
        },
        // Brand/link token
        brand: {
          link: 'var(--link-color)',
        },
      },
    },
  },
  plugins: [],
};
