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
    files: ['.storybook/**/*.ts', 'vite.config.ts', 'vitest.config.ts'],
    rules: { 'no-restricted-imports': 'off' },
  },
)
