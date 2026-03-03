import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  // Svg: React.ComponentType<React.ComponentProps<"svg">>;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "Own your Codebase",
    // Svg: require("@site/static/img/undraw_docusaurus_mountain.svg").default,
    description: (
      <>
        Quill is extremely flexible, and divides its functionality between
        optional <b>crates</b>, allowing you to own your codebase.
      </>
    ),
  },
  {
    title: "Script with Power",
    // Svg: require("@site/static/img/undraw_docusaurus_tree.svg").default,
    description: (
      <>
        Quill provides many different approaches to handling bootstrapping,
        error logging, and much more, resulting in a more <b>powerful</b>{" "}
        approach to coding.
      </>
    ),
  },
  {
    title: "Enhance your Productivity",
    // Svg: require("@site/static/img/undraw_docusaurus_react.svg").default,
    description: (
      <>
        Quill is great for enhancing your productivity and changing the ways in
        which you approach bootstrapping your projects.
      </>
    ),
  },
];
// title, svg, description
/*
<div className="text--center">
  <Svg className={styles.featureSvg} role="img" />
</div>
*/
function Feature({ title, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4")}>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
