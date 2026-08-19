import { config } from '@fohte/eslint-config'
import storybook from 'eslint-plugin-storybook'

export default config(
  {
    typescript: { typeChecked: true },
    errorHandling: {},
    tailwind: { cssConfigPath: 'src/index.css' },
  },
  ...storybook.configs['flat/recommended'],
  {
    // vite.config.ts/vitest.config.ts are loaded through Vite's own
    // esbuild-based config loader, which doesn't resolve the package.json
    // "imports" field, unlike the Rollup pipeline that bundles the app
    // itself.
    files: ['vite.config.ts', 'vitest.config.ts'],
    rules: { 'no-restricted-imports': 'off' },
  },
)
