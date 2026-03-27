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
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
        'spin-slow': 'spin 2s linear infinite',
        'bounce-fast': 'bounce 0.6s ease-in-out infinite',
        'pulse-scale': 'pulse-scale 1.5s ease-in-out infinite',
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
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
