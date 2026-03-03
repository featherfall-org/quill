import type { PrismTheme } from "prism-react-renderer";
import { themes } from "prism-react-renderer";

const darkTheme = themes.vsDark;

const theme: PrismTheme = {
  plain: {
    color: "#D4D4D4",
    backgroundColor: "#212124",
  },
  styles: [
    ...darkTheme.styles,
    {
      types: ["comment"],
      style: {
        color: "#6A737D",
      },
    },
    {
      types: ["title"],
      style: {
        color: "#569CD6",
        fontWeight: "bold",
      },
    },
    {
      types: ["property", "parameter"],
      style: {
        color: "#9CDCFE",
      },
    },
    {
      types: ["script"],
      style: {
        color: "#D4D4D4",
      },
    },
    {
      types: ["boolean", "arrow", "atrule", "tag"],
      style: {
        color: "#569CD6",
      },
    },
    {
      types: ["number", "color", "unit"],
      style: {
        color: "#B5CEA8",
      },
    },
    {
      types: ["font-matter"],
      style: {
        color: "#CE9178",
      },
    },
    {
      types: ["keyword", "rule"],
      style: {
        color: "#C586C0",
      },
    },
    {
      types: ["regex"],
      style: {
        color: "#D16969",
      },
    },
    {
      types: ["maybe-class-name"],
      style: {
        color: "#4EC9B0",
      },
    },
    {
      types: ["constant"],
      style: {
        color: "#4FC1FF",
      },
    },
  ],
};

export default theme;
