import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';

import cloudflare from "@astrojs/cloudflare";

// https://astro.build/config
export default defineConfig({
  integrations: [mdx()],

  vite: {
    // Redirect Vite cache to a local drive to bypass network share EPERM locking issues
    cacheDir: 'C:/Users/skept/AppData/Local/Temp/vite_cache'
  },

  adapter: cloudflare()
});