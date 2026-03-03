import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import Heading from "@theme/Heading";

import styles from "./index.module.css";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <img
          src="img/quill-logo.svg"
          alt="Quill Logo"
          className={styles.heroLogo}
        />

        <div className={styles.badge}>
          Strictly Typed • Roblox-First • Zero Bloat
        </div>

        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>

        <p className="hero__subtitle">{siteConfig.tagline}</p>

        <div className={styles.ctaRow}>
          <Link className={styles.liquidBtns} to="/docs">
            Get Started
          </Link>

          <a
            className={styles.githubBtn}
            href="https://github.com/featherfall-org/quill"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className={styles.githubIcon} aria-hidden="true">
              <svg
                viewBox="0 0 16 16"
                width="18"
                height="18"
                fill="currentColor"
              >
                <path d="M8 0C3.58 0 0 3.73 0 8.34c0 3.69 2.29 6.82 5.47 7.93.4.08.55-.18.55-.39 0-.19-.01-.82-.01-1.49-2.01.38-2.53-.51-2.69-.98-.09-.24-.48-.98-.82-1.18-.28-.16-.68-.56-.01-.57.63-.01 1.08.6 1.23.85.72 1.25 1.87.9 2.33.69.07-.54.28-.9.51-1.11-1.78-.21-3.64-.93-3.64-4.15 0-.92.31-1.67.82-2.26-.08-.21-.36-1.06.08-2.2 0 0 .67-.22 2.2.86.64-.18 1.32-.27 2-.27s1.36.09 2 .27c1.53-1.08 2.2-.86 2.2-.86.44 1.14.16 1.99.08 2.2.51.59.82 1.34.82 2.26 0 3.23-1.87 3.94-3.65 4.15.29.26.54.77.54 1.56 0 1.13-.01 2.04-.01 2.33 0 .21.15.47.55.39C13.71 15.16 16 12.03 16 8.34 16 3.73 12.42 0 8 0Z" />
              </svg>
            </span>
            GitHub
          </a>
        </div>
      </div>
    </header>
  );
}
// ^ button button--secondary button--lg

export default function Home(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`Quill Docs`}
      description="Description will go into a meta tag in <head />"
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
