// To use a different framework (e.g. @storybook/nextjs, @storybook/sveltekit),
// replace @storybook/react-vite below and update devDependencies accordingly.
import type { StorybookConfig } from '@storybook/react-vite'

const config: StorybookConfig = {
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  framework: '@storybook/react-vite',
  addons: ['@storybook/addon-docs', '@storybook/addon-themes'],
}

export default config
