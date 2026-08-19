import { config } from '@fohte/eslint-config'
import storybook from 'eslint-plugin-storybook'

export default config(
  {
    typescript: { typeChecked: true },
    errorHandling: {},
    tailwind: { cssConfigPath: 'frontend/src/index.css' },
  },
  ...storybook.configs['flat/recommended'],
  {
    // vite.config.ts/vitest.config.ts are loaded through Vite's own
    // esbuild-based config loader, which doesn't resolve the package.json
    // "imports" field, unlike the Rollup pipeline that bundles the app
    // itself. .storybook/**/*.ts doesn't need this exception: Storybook's
    // Node config loader only transpiles TS to ESM and otherwise defers to
    // Node's own module resolution, which resolves "imports" natively.
    files: ['frontend/vite.config.ts', 'frontend/vitest.config.ts'],
    rules: { 'no-restricted-imports': 'off' },
  },
)
