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
    <header className={clsx(styles.heroBanner)}>
      <div className="container">
        <img className={styles.logo} src={"/img/openwebf.png"} alt={"Logo"}/>
        <h1 className={styles.title}> WebF </h1>
        <p className={styles.subtitle}>Build <a href="https://flutter.io/"
                                                 className={styles.flutter_text}>Flutter</a> Apps with HTML/CSS and
          JavaScript</p>
        <div className={styles.buttons}>
          <Link to={'/docs/tutorials/getting-started/introduction'}>
            <div className="button_item btn_default btn_active">Getting Started</div>
          </Link>
        </div>
      </div>
    </header>
  );
}

function HomepageSponsors() {
  return (
    <div className='sponsor' style={{ textAlign: 'center', marginTop: '24px' }}>
      <h2 className='title' style={{ marginBottom: '12px' }}>Sponsors</h2>
      <p style={{ fontSize: '21px', color: 'black' }}>
        Browser testing via{' '}
        <a href="https://www.lambdatest.com/?utm_source=openwebf&utm_medium=sponsor" target="_blank">
          <img
            src="https://www.lambdatest.com/blue-logo.png"
            style={{ verticalAlign: 'middle' }}
            width={250}
            height={45}
          />
        </a>
      </p>
    </div>
  );
}

function HomepageFooter() {
  return (
    <div className={clsx(styles.footer_container)}>
      <h1>Web + Flutter = WebF</h1>
      <p>
        Build cross-platform apps for both desktop and mobile from a single code base
      </p>
      <div className={clsx(styles.buttons, styles.footer_button)}>
        <Link to={'/docs/tutorials/getting-started/introduction'}><div className="button_item btn_default">Getting Started</div></Link>
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
      <HomepageHeader/>
      <main className={styles.feature_container}>
        <HomepageFeatures/>
      </main>
      <HomepageSponsors/>
      <HomepageFooter/>
    </Layout>
  );
}
