// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'WebF',
  tagline: 'Build Flutter apps with HTML/CSS and JavaScript.',
  url: 'https://openwebf.com',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'openwebf', // Usually your GitHub org/user name.
  projectName: 'webf', // Usually your repo name.

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'WebF',
        logo: {
          alt: 'openWebF',
          src: 'img/openwebf.png',
        },
        items: [
          {
            type: 'doc',
            docId: 'tutorials/getting-started/introduction',
            position: 'left',
            label: 'Docs',
          },
          {
            type: 'doc',
            docId: 'api/intro',
            position: 'left',
            label: 'API'
          },
          {to: '/blog', label: 'Blog', position: 'left'},
          {
            href: 'https://github.com/openwebf/webf',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      algolia: {
        // The application ID provided by Algolia
        appId: 'J0MMWK93AU',

        // Public API key: it is safe to commit it
        apiKey: 'db2383eb268f7088780453660576c63c',

        indexName: 'openwebf',

        contextualSearch: true,
        //... other Algolia params
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Tutorial',
                to: '/docs/tutorials/getting-started/introduction',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Discord',
                href: 'https://discord.gg/jkUsNGndFP',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/HelloAndyCall',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/openwebf/webf',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} OpenWebF authors.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ['dart'],
      },
    }),
};

module.exports = config;
