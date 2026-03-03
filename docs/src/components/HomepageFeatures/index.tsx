import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "Own your Codebase",
    description: (
      <>
        Quill is extremely flexible, and divides its functionality between
        optional <b>crates</b>, allowing you to own your codebase.
      </>
    ),
  },
  {
    title: "Script with Power",
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
    description: (
      <>
        Quill is great for enhancing your productivity and changing the ways in
        which you approach bootstrapping your projects.
      </>
    ),
  },
];

function Feature({ title, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4", "margin-bottom--lg")}>
      <div className={styles.featureCard}>
        <div className={styles.icon}>
          <span className={styles.iconDot} />
        </div>

        <div className="text--center padding-horiz--md">
          <Heading as="h3" className={styles.featureTitle}>
            {title}
          </Heading>
          <p className={styles.featureText}>{description}</p>
        </div>
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
