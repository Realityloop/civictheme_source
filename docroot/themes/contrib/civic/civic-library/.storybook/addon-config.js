exports.default = function () {
  // Lean storybook config.
  let config = [
    '@storybook/addon-knobs',
    {
      name: '@storybook/addon-essentials',
      options: {
        controls: false,
        docs: false,
        actions: false,
      },
    },
    '@storybook/addon-links',
  ];

  // Html and pseudo knobs.
  if (process.env.STORYBOOK_FULL === '1') {
    config = [
      ...config,
      ...[
        '@whitespace/storybook-addon-html',
        'storybook-addon-pseudo-states',
        '@storybook/addon-a11y',
      ],
    ];
  }

  return config;
};
