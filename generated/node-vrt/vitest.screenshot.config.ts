import path from 'node:path'
import { fileURLToPath } from 'node:url'

import { createStorybookProject } from '@fohte/storybook-addon/vitest-plugin'
import { defineConfig } from 'vitest/config'

import { SCREENSHOT_VIEWPORT } from './.storybook/screenshot-viewport'

const dirname = path.dirname(fileURLToPath(import.meta.url))

export default defineConfig(
  createStorybookProject({
    name: 'storybook-screenshot-node-vrt',
    rootDir: dirname,
    viewport: SCREENSHOT_VIEWPORT,
    screenshotsSubdir: 'desktop',
    setupFiles: ['./.storybook/vitest.setup.screenshot.ts'],
  }),
)
