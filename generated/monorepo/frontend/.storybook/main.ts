import type { StorybookConfig } from 'storybook'

const config: StorybookConfig = {
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  // TODO: Set framework for your project (e.g. '@storybook/react-vite')
  // framework: '@storybook/react-vite',
  addons: ['@storybook/addon-docs', '@storybook/addon-themes'],
}

export default config
