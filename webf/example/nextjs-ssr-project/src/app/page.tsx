import Image from "next/image";
import styles from "./page.module.css";

export default function Home() {
  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <Image
          className={styles.logo}
          src="/next.svg"
          alt="Next.js logo"
          width={180}
          height={38}
          priority
        />

        <h1 style={{ fontSize: '24px', marginBottom: '20px', textAlign: 'center' }}>
          WebF Next.js Test Suite
        </h1>

        <div style={{
          maxWidth: '600px',
          margin: '0 auto',
          padding: '20px',
          backgroundColor: '#f8f9fa',
          borderRadius: '8px',
          marginBottom: '30px'
        }}>
          <h2 style={{ fontSize: '18px', marginBottom: '15px' }}>Test Features</h2>
          <p style={{ marginBottom: '15px', color: '#666' }}>
            This project tests Next.js features in WebF runtime:
          </p>
          <ul style={{ marginBottom: '0', paddingLeft: '20px' }}>
            <li><strong>Server Components:</strong> Components that render on the server</li>
            <li><strong>Client Components:</strong> Interactive components requiring JavaScript</li>
            <li><strong>React SSR:</strong> Server-side rendering with hydration</li>
            <li><strong>Hybrid Pages:</strong> Mixed server and client components</li>
          </ul>
        </div>

        <div className={styles.ctas} style={{ flexDirection: 'column', gap: '15px' }}>
          <a
            href="/server-component"
            className={styles.primary}
            style={{ textDecoration: 'none', display: 'block', width: '100%', textAlign: 'center' }}
          >
            🖥️ Test Server Components
          </a>

          <a
            href="/client-component"
            className={styles.secondary}
            style={{ textDecoration: 'none', display: 'block', width: '100%', textAlign: 'center' }}
          >
            ⚡ Test Client Components
          </a>

          <a
            href="/hybrid"
            className={styles.primary}
            style={{ textDecoration: 'none', display: 'block', width: '100%', textAlign: 'center' }}
          >
            🔀 Test Hybrid Components
          </a>
        </div>

        <div style={{
          marginTop: '30px',
          padding: '20px',
          backgroundColor: '#fff3cd',
          border: '1px solid #ffeaa7',
          borderRadius: '8px',
          fontSize: '14px'
        }}>
          <h3 style={{ fontSize: '16px', marginBottom: '10px' }}>WebF Testing Notes:</h3>
          <ul style={{ marginBottom: '0', paddingLeft: '20px' }}>
            <li>Server components should render immediately without JavaScript</li>
            <li>Client components require React hydration to be interactive</li>
            <li>SSR content should be visible before JavaScript loads</li>
            <li>Check console for hydration warnings or errors</li>
          </ul>
        </div>
      </main>

      <footer className={styles.footer}>
        <a
          href="https://nextjs.org/docs/app/building-your-application/rendering/server-components"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="/file.svg"
            alt="File icon"
            width={16}
            height={16}
          />
          Server Components Docs
        </a>
        <a
          href="https://nextjs.org/docs/app/building-your-application/rendering/client-components"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="/window.svg"
            alt="Window icon"
            width={16}
            height={16}
          />
          Client Components Docs
        </a>
        <a
          href="https://react.dev/reference/react/Suspense"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="/globe.svg"
            alt="Globe icon"
            width={16}
            height={16}
          />
          React Suspense Docs
        </a>
      </footer>
    </div>
  );
}
