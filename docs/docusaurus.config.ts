import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";

import lightCodeTheme from "./themes/light";
import darkCodeTheme from "./themes/dark";

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: "Quill",
  tagline: "A fully and strictly typed framework for Luau",
  favicon: "img/quill-favicon.ico",

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: "https://featherfall-org.github.io",
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: "/quill",

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: "featherfall-org", // Usually your GitHub org/user name.
  projectName: "quill", // Usually your repo name.

  onBrokenLinks: "throw",

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      "classic",
      {
        docs: {
          sidebarPath: "./sidebars.ts",
        },
        theme: {
          customCss: "./src/css/custom.css",
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: "img/quill-logo.png",
    colorMode: {
      respectPrefersColorScheme: false, // Default true
    },
    navbar: {
      title: "Quill",
      logo: {
        alt: "Quill Logo",
        src: "img/quill-logo.png",
      },
      items: [
        {
          type: "docSidebar",
          sidebarId: "learnSidebar",
          position: "left",
          label: "Learn",
        },
        {
          href: "https://github.com/featherfall-org/quill",
          position: "right",
          className: "header-github-link",
          "aria-label": "Github repository",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Learn",
          items: [
            {
              label: "Quick Start",
              to: "/docs",
            },
            {
              label: "Installation",
              to: "/docs/quick-start/installation",
            },
          ],
        },
        {
          title: "Community",
          items: [
            {
              label: "Roblox OSS Community",
              href: "https://discord.gg/Bcyh8kmRYe",
            },
          ],
        },
        {
          title: "More",
          items: [
            {
              label: "GitHub",
              href: "https://github.com/featherfall-org/quill",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Featherfall`,
    },
    prism: {
      theme: lightCodeTheme,
      darkTheme: darkCodeTheme,
      additionalLanguages: ["typescript", "lua", "bash", "toml"],
      magicComments: [
        {
          className: "theme-code-block-highlighted-line",
          line: "highlight-next-line",
          block: { start: "highlight-start", end: "highlight-end" },
        },
        {
          className: "code-block-error-line",
          line: "error-next-line",
        },
      ],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
