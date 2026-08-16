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
    files: [
      'frontend/.storybook/**/*.ts',
      'frontend/vite.config.ts',
      'frontend/vitest.config.ts',
    ],
    rules: { 'no-restricted-imports': 'off' },
  },
)
