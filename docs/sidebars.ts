import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  learnSidebar: [
    {
      type: "category",
      label: "Quick Start",
      link: {
        type: "doc",
        id: "quick-start/index",
      },
      items: ["quick-start/installation", "quick-start/examples"],
    },
    /*
    {
      type: 'category',
      label: 'Guides',
      link: {
        type: 'doc',
        id: 'guides/index',
      },
      items: [

      ]
    }
    */
  ],
};

export default sidebars;
