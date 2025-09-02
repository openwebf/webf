import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

import styles from './TablePage.module.css';
import { 
  WebFTable, 
  WebFTableRow, 
  WebFTableHeader, 
  WebFTableCell 
} from '@openwebf/react-core-ui';

export const TablePage: React.FC = () => {
  // Sample data for demonstrations
  const products = [
    { id: 1, name: 'iPhone 15 Pro', category: 'Electronics', price: 999, stock: 45 },
    { id: 2, name: 'MacBook Air', category: 'Computers', price: 1299, stock: 23 },
    { id: 3, name: 'AirPods Pro', category: 'Audio', price: 249, stock: 156 },
    { id: 4, name: 'iPad Mini', category: 'Tablets', price: 599, stock: 67 },
    { id: 5, name: 'Apple Watch', category: 'Wearables', price: 399, stock: 89 },
  ];

  const employees = [
    { name: 'John Doe', department: 'Engineering', position: 'Senior Developer', salary: '$120,000' },
    { name: 'Jane Smith', department: 'Marketing', position: 'Marketing Manager', salary: '$95,000' },
    { name: 'Bob Johnson', department: 'Sales', position: 'Sales Representative', salary: '$75,000' },
    { name: 'Alice Brown', department: 'HR', position: 'HR Director', salary: '$110,000' },
  ];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.container}>
          <h1 className={styles.title}>Table Components</h1>
          <p className={styles.description}>
            WebF provides flexible table components with support for sticky headers, custom alignment, 
            column width configurations, and various styling options.
          </p>

          {/* Basic Table */}
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Basic Table</h2>
            <p className={styles.sectionDescription}>
              A simple table with default styling and alignment.
            </p>
            <div className={styles.demoContainer}>
              <WebFTable className={styles.basicTable}>
                <WebFTableHeader>
                  <WebFTableCell>Product</WebFTableCell>
                  <WebFTableCell>Category</WebFTableCell>
                  <WebFTableCell>Price</WebFTableCell>
                  <WebFTableCell>Stock</WebFTableCell>
                </WebFTableHeader>
                {products.map(product => (
                  <WebFTableRow key={product.id}>
                    <WebFTableCell>{product.name}</WebFTableCell>
                    <WebFTableCell>{product.category}</WebFTableCell>
                    <WebFTableCell>${product.price}</WebFTableCell>
                    <WebFTableCell>{product.stock}</WebFTableCell>
                  </WebFTableRow>
                ))}
              </WebFTable>
            </div>
          </section>

          {/* Sticky Header Table */}
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Sticky Header Table</h2>
            <p className={styles.sectionDescription}>
              Table with a sticky header that remains visible when scrolling.
            </p>
            <div className={styles.scrollContainer}>
              <WebFTable className={styles.stickyTable}>
                <WebFTableHeader sticky={true}>
                  <WebFTableCell>Product Name</WebFTableCell>
                  <WebFTableCell>Category</WebFTableCell>
                  <WebFTableCell>Price</WebFTableCell>
                  <WebFTableCell>In Stock</WebFTableCell>
                </WebFTableHeader>
                {[...products, ...products, ...products].map((product, index) => (
                  <WebFTableRow key={`${product.id}-${index}`}>
                    <WebFTableCell>{product.name}</WebFTableCell>
                    <WebFTableCell>{product.category}</WebFTableCell>
                    <WebFTableCell>${product.price}</WebFTableCell>
                    <WebFTableCell>{product.stock} units</WebFTableCell>
                  </WebFTableRow>
                ))}
              </WebFTable>
            </div>
          </section>

          {/* Custom Column Widths */}
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Custom Column Widths</h2>
            <p className={styles.sectionDescription}>
              Table with fixed column widths and flexible column configurations.
            </p>
            <div className={styles.demoContainer}>
              <WebFTable 
                className={styles.customWidthTable}
                columnWidths={JSON.stringify({
                  "0": { "type": "fixed", "width": 200 },
                  "1": { "type": "flex", "flex": 2 },
                  "2": { "type": "flex", "flex": 1 },
                  "3": { "type": "fixed", "width": 150 }
                })}
              >
                <WebFTableHeader>
                  <WebFTableCell>Employee Name</WebFTableCell>
                  <WebFTableCell>Department</WebFTableCell>
                  <WebFTableCell>Position</WebFTableCell>
                  <WebFTableCell>Salary</WebFTableCell>
                </WebFTableHeader>
                {employees.map((employee, index) => (
                  <WebFTableRow key={index}>
                    <WebFTableCell>{employee.name}</WebFTableCell>
                    <WebFTableCell>{employee.department}</WebFTableCell>
                    <WebFTableCell>{employee.position}</WebFTableCell>
                    <WebFTableCell>{employee.salary}</WebFTableCell>
                  </WebFTableRow>
                ))}
              </WebFTable>
            </div>
          </section>

          {/* Vertical Alignment */}
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Vertical Alignment</h2>
            <p className={styles.sectionDescription}>
              Demonstrate different vertical alignment options for table cells.
            </p>
            <div className={styles.demoContainer}>
              <WebFTable 
                className={styles.alignmentTable}
                defaultVerticalAlignment="middle"
              >
                <WebFTableHeader>
                  <WebFTableCell>Alignment Type</WebFTableCell>
                  <WebFTableCell>Description</WebFTableCell>
                  <WebFTableCell>Example Content</WebFTableCell>
                </WebFTableHeader>
                <WebFTableRow style={{ height: '80px' }}>
                  <WebFTableCell verticalAlignment="top">Top</WebFTableCell>
                  <WebFTableCell verticalAlignment="top">
                    Content aligned to the top of the cell
                  </WebFTableCell>
                  <WebFTableCell verticalAlignment="top">↑ Top aligned</WebFTableCell>
                </WebFTableRow>
                <WebFTableRow style={{ height: '80px' }}>
                  <WebFTableCell verticalAlignment="middle">Middle</WebFTableCell>
                  <WebFTableCell verticalAlignment="middle">
                    Content centered vertically (default)
                  </WebFTableCell>
                  <WebFTableCell verticalAlignment="middle">→ Middle aligned</WebFTableCell>
                </WebFTableRow>
                <WebFTableRow style={{ height: '80px' }}>
                  <WebFTableCell verticalAlignment="bottom">Bottom</WebFTableCell>
                  <WebFTableCell verticalAlignment="bottom">
                    Content aligned to the bottom of the cell
                  </WebFTableCell>
                  <WebFTableCell verticalAlignment="bottom">↓ Bottom aligned</WebFTableCell>
                </WebFTableRow>
              </WebFTable>
            </div>
          </section>

          {/* Styled Table */}
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Styled Table</h2>
            <p className={styles.sectionDescription}>
              Table with custom styling, borders, and hover effects.
            </p>
            <div className={styles.demoContainer}>
              <WebFTable 
                className={styles.styledTable}
                textDirection="ltr"
                defaultVerticalAlignment="middle"
              >
                <WebFTableHeader>
                  <WebFTableCell className={styles.headerCell}>Feature</WebFTableCell>
                  <WebFTableCell className={styles.headerCell}>Basic Plan</WebFTableCell>
                  <WebFTableCell className={styles.headerCell}>Pro Plan</WebFTableCell>
                  <WebFTableCell className={styles.headerCell}>Enterprise</WebFTableCell>
                </WebFTableHeader>
                <WebFTableRow className={styles.dataRow}>
                  <WebFTableCell className={styles.featureCell}>Storage</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>10 GB</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>100 GB</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>Unlimited</WebFTableCell>
                </WebFTableRow>
                <WebFTableRow className={styles.dataRow}>
                  <WebFTableCell className={styles.featureCell}>Users</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>1</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>5</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>Unlimited</WebFTableCell>
                </WebFTableRow>
                <WebFTableRow className={styles.dataRow}>
                  <WebFTableCell className={styles.featureCell}>Support</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>Email</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>Priority</WebFTableCell>
                  <WebFTableCell className={styles.dataCell}>24/7 Phone</WebFTableCell>
                </WebFTableRow>
                <WebFTableRow className={styles.dataRow}>
                  <WebFTableCell className={styles.featureCell}>Price</WebFTableCell>
                  <WebFTableCell className={styles.priceCell}>$9/mo</WebFTableCell>
                  <WebFTableCell className={styles.priceCell}>$29/mo</WebFTableCell>
                  <WebFTableCell className={styles.priceCell}>Custom</WebFTableCell>
                </WebFTableRow>
              </WebFTable>
            </div>
          </section>

          {/* RTL Support */}
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>RTL (Right-to-Left) Support</h2>
            <p className={styles.sectionDescription}>
              Table with right-to-left text direction for Arabic, Hebrew, and other RTL languages.
            </p>
            <div className={styles.demoContainer}>
              <WebFTable 
                className={styles.rtlTable}
                textDirection="rtl"
              >
                <WebFTableHeader>
                  <WebFTableCell>الاسم</WebFTableCell>
                  <WebFTableCell>القسم</WebFTableCell>
                  <WebFTableCell>المنصب</WebFTableCell>
                  <WebFTableCell>الراتب</WebFTableCell>
                </WebFTableHeader>
                <WebFTableRow>
                  <WebFTableCell>أحمد محمد</WebFTableCell>
                  <WebFTableCell>الهندسة</WebFTableCell>
                  <WebFTableCell>مطور أول</WebFTableCell>
                  <WebFTableCell>120,000 ريال</WebFTableCell>
                </WebFTableRow>
                <WebFTableRow>
                  <WebFTableCell>فاطمة علي</WebFTableCell>
                  <WebFTableCell>التسويق</WebFTableCell>
                  <WebFTableCell>مدير تسويق</WebFTableCell>
                  <WebFTableCell>95,000 ريال</WebFTableCell>
                </WebFTableRow>
              </WebFTable>
            </div>
          </section>
        </div>
      </WebFListView>
    </div>
  );
};