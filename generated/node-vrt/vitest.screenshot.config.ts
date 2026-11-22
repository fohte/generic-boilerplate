import path from 'node:path'
import { fileURLToPath } from 'node:url'

import { createStorybookProject } from '@fohte/storybook-addon/vitest-plugin'
import { defineConfig } from 'vitest/config'

import {
  DESKTOP_VIEWPORT,
  MOBILE_VIEWPORT,
} from './.storybook/screenshot-viewport'

const dirname = path.dirname(fileURLToPath(import.meta.url))

export default defineConfig({
  test: {
    projects: [
      createStorybookProject({
        name: 'storybook-screenshot-node-vrt',
        rootDir: dirname,
        viewport: DESKTOP_VIEWPORT,
        screenshotsSubdir: 'desktop',
        setupFiles: ['./.storybook/vitest.setup.screenshot.ts'],
        excludeTags: ['mobile-only'],
      }),
      createStorybookProject({
        name: 'storybook-screenshot-node-vrt-mobile',
        rootDir: dirname,
        viewport: MOBILE_VIEWPORT,
        screenshotsSubdir: 'mobile',
        setupFiles: ['./.storybook/vitest.setup.screenshot.ts'],
        excludeTags: ['desktop-only'],
      }),
    ],
  },
})
