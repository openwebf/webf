import React from 'react';
import clsx from 'clsx';

import './styles.css';

type FeatureItem = {
  title: string;
  bigTitle: string;
  description: string;
  btnLink: string;
  btnText: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Backward Compatible With Web Browsers',
    bigTitle: 'Same API as browsers',
    description: "WebF provides a subset of W3C/WHATWG standard HTML/CSS and ECMAScript 2020 JavaScript support. Apps built for WebF yield the same results and behavior in web browsers.",
    btnLink: '/avaiable_css_web_apis',
    btnText: 'View the available CSS and Web APIs.'
  },
  {
    title: 'True Web Develope Experience',
    bigTitle: 'Web like dev workflow',
    description: 'Utilize your favorite web frameworks, build tools, and Chrome DevTools to develop, debug, and deploy your apps.',
    btnLink: '/web_framework_and_tips',
    btnText: 'View the available web frameworks and others  .'
  },
  {
    title: 'High Performance',
    bigTitle: 'Faster page startup time compared to WebView',
    description: 'Execute bytecode with optimized QuickJS engine, and render HTML/CSS in the same context as Flutter apps, saving 50% load times compared to WebView.',
    btnLink: '/blog/high_performance_webf',
    btnText: 'Explore why webf are faster than WebView.'
  },
  {
    title: 'Smaller Bundle Size',
    bigTitle: '25MB zip bundle for everything',
    description: 'Create cross-platform desktop apps using web technologies, featuring smaller package sizes.',
    btnLink: '/blog/high_performance_webf',
    btnText: 'Have a Try'
  },
  {
    title: 'One Runtime for All Platforms',
    bigTitle: 'Consistency cross mobile and desktop platforms',
    description: 'All HTML/CSS and JavaScript support is self-contained, with no external WebView required, eliminating concerns about browser compatibility.',
    btnLink: '/',
    btnText: 'Learn more'
  },
  {
    title: 'Beyond the Web',
    bigTitle: 'Accomplish what the web can do, and also what it cannot do',
    description: 'Embed anything supported by Flutter in WebF: combine pre-trained AI models with web apps, use hardware-accelerated video players, or integrate Unity game engines with AR/VR apps in your web pages at full speed.',
    btnLink: '/',
    btnText: 'Learn more'
  },
  {
    title: 'Native User experience',
    bigTitle: 'Deep integration with Flutter gestures and navigating',
    description: 'Seamlessly integrate Flutter navigation with the web history API or add pull-to-refresh gestures to your web apps, providing users with a complete native app experiences.',
    btnLink: '/',
    btnText: 'Learn more'
  }
];

function Feature(props: FeatureItem & {idx: number}) {
  return (
    <div className={"feature " + (props.idx % 2 == 0 ? '' : 'reverse')}>
      <div className="text">
        <hgroup>
          <h4 className="title text-blue">{props.title}</h4>
          <h3>{props.bigTitle}</h3>
        </hgroup>
        <p>{props.description}</p>
        <a className="button_item btn_default" href={props.btnLink}>{props.btnText}</a>
      </div>
      <div className="media">
        <div>IMG</div>
        {/* <img alt="Multi-Platform" src="https://storage.googleapis.com/cms-storage-bucket/ed2e069ee37807f5975a.jpg" /> */}
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className="feature_container">
      {FeatureList.map((props, idx) => (
        <Feature key={idx} {...props} idx={idx} />
      ))}
    </section>
  );
}
