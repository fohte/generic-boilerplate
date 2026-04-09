import { config } from '@fohte/eslint-config'
import storybook from 'eslint-plugin-storybook'

export default config(
  { typescript: { typeChecked: true } },
  ...storybook.configs['flat/recommended'],
  {
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['./*', '../*'],
              message:
                'Please use absolute imports instead of relative imports.',
            },
          ],
        },
      ],
    },
  },
  // .storybook/ and vitest.config.ts are outside src/ where @ alias is unavailable
  {
    files: ['.storybook/**/*.ts', 'vitest.config.ts'],
    rules: {
      'no-restricted-imports': 'off',
    },
  },
)
