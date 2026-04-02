import { config } from '@fohte/eslint-config'

export default config(
  { typescript: { typeChecked: true } },
  {
    files: ['**/*.ts{,x}'],
    languageOptions: {
      parserOptions: {
        projectService: {
          allowDefaultProject: [
            '.storybook/main.ts',
            '.storybook/preview.ts',
            '**/.storybook/main.ts',
            '**/.storybook/preview.ts',
          ],
        },
      },
    },
  },
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
    files: ['.storybook/**/*.ts', '**/.storybook/**/*.ts', 'vitest.config.ts'],
    rules: {
      'no-restricted-imports': 'off',
    },
  },
)
