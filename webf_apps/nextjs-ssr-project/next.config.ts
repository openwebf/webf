import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Enable React strict mode for better development experience
  reactStrictMode: true,
  
  // Optimize for SSR performance
  experimental: {
    // Enable partial prerendering for better performance
    ppr: false, // Set to true when stable for better SSR performance
  },
  
  // Configure image optimization for WebF compatibility
  images: {
    // Configure image domains if loading external images
    domains: [],
    
    // Disable image optimization for WebF testing (since WebF may not support all optimizations)
    unoptimized: false,
  },
  
  // Enable compression for better performance
  compress: true,
  
  // Configure headers for better caching and security
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
        ],
      },
    ];
  },
  
  // Configure output for static export if needed for WebF testing
  // output: 'export', // Uncomment for static export
  
  // Webpack configuration for better debugging
  webpack: (config, { dev, isServer }) => {
    if (dev) {
      // Enable source maps for debugging
      config.devtool = 'eval-source-map';
    }
    
    return config;
  },
};

export default nextConfig;
