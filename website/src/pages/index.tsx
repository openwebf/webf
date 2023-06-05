import React, { useEffect } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className="container">
        <h1 className={styles.title}>Build <a href="https://flutter.io/"
                                              className={styles.flutter_text}>Flutter</a> Apps</h1>
        <h1 className={styles.title}>with HTML/CSS and JavaScript</h1>
        <h2>
          Build Flutter apps with web technologies and real-time updates like web applications.
        </h2>
        <div className={styles.buttons}>
          <Link to={'/docs/tutorials/getting-started/introduction'}>
            <div className="button_item btn_default">Getting Started</div>
          </Link>
        </div>
      </div>
    </header>
  );
}

function HomepageFooter() {
  return (
    <div className={clsx(styles.footer_container)}>
      <h1>Web + Flutter = WebF</h1>
      <h2>
        Build cross-platform apps for both desktop and mobile from a single code base
      </h2>
      <div className={clsx(styles.buttons, styles.footer_button)}>
        <div className="button_item btn_default">Getting Started</div>
      </div>
    </div>
  );
}

export default function Home(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();

  useEffect(() => {
    const script = document.createElement('script');
    script.async = true;
    script.src = 'https://www.googletagmanager.com/gtag/js?id=G-5LWS72MK7N';
    document.body.appendChild(script);

    const traceCode = `window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());

    gtag('config', 'G-5LWS72MK7N');`;
    const trace = document.createElement('script');
    trace.innerHTML = traceCode;
    document.body.appendChild(trace);
  }, []);

  return (
    <Layout
      title={`Build flutter apps with HTML/CSS and JavaScript | WebF`}
      description="Build flutter apps with HTML/CSS and JavaScript">
      <HomepageHeader />
      <main className={styles.feature_container}>
        <HomepageFeatures />
      </main>
      <HomepageFooter />
    </Layout>
  );
}
