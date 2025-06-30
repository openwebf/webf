import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';
import { createComponent } from '../utils/CreateComponent';
import styles from './EChartsPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

export const EChartsPage: React.FC = () => {
  const pieChartRef = useRef<HTMLDivElement>(null);
  const barChartRef = useRef<HTMLDivElement>(null);
  const lineChartRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let pieChart: any = null;
    let barChart: any = null;
    let lineChart: any = null;

    // Pie chart configuration
    if (pieChartRef.current) {
      pieChart = echarts.init(pieChartRef.current);
      const pieOption = {
        title: {
          text: 'Sales Data Distribution',
          left: 'center'
        },
        tooltip: {
          trigger: 'item'
        },
        legend: {
          orient: 'vertical',
          left: 'left'
        },
        series: [
          {
            name: 'Sales',
            type: 'pie',
            radius: '50%',
            data: [
              { value: 1048, name: 'Product A' },
              { value: 735, name: 'Product B' },
              { value: 580, name: 'Product C' },
              { value: 484, name: 'Product D' },
              { value: 300, name: 'Product E' }
            ],
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      };
      pieChart.setOption(pieOption);
    }

    // Bar chart configuration
    if (barChartRef.current) {
      console.log('🚀 barChartRef.current', barChartRef.current);
      barChart = echarts.init(barChartRef.current);
      const barOption = {
        title: {
          text: 'Monthly Sales Statistics',
          left: 'center'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: [
          {
            type: 'category',
            data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            axisTick: {
              alignWithLabel: true
            }
          }
        ],
        yAxis: [
          {
            type: 'value'
          }
        ],
        series: [
          {
            name: 'Sales',
            type: 'bar',
            barWidth: '60%',
            data: [10, 52, 200, 334, 390, 330],
            itemStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: '#83bff6' },
                { offset: 0.5, color: '#188df0' },
                { offset: 1, color: '#188df0' }
              ])
            }
          }
        ]
      };
      barChart.setOption(barOption);
    }

    // Line chart configuration
    if (lineChartRef.current) {
      console.log('🚀 lineChartRef.current', lineChartRef.current);
      lineChart = echarts.init(lineChartRef.current);
      const lineOption = {
        title: {
          text: 'User Growth Trend',
          left: 'center'
        },
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['New Users', 'Active Users'],
          top: '10%'
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        toolbox: {
          feature: {
            saveAsImage: {}
          }
        },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: 'New Users',
            type: 'line',
            stack: 'Total',
            data: [120, 132, 101, 134, 90, 230, 210],
            smooth: true,
            itemStyle: {
              color: '#5470c6'
            }
          },
          {
            name: 'Active Users',
            type: 'line',
            stack: 'Total',
            data: [220, 182, 191, 234, 290, 330, 310],
            smooth: true,
            itemStyle: {
              color: '#91cc75'
            }
          }
        ]
      };
      lineChart.setOption(lineOption);
    }

    // Cleanup function
    return () => {
      if (pieChart) {
        pieChart.dispose();
      }
      if (barChart) {
        barChart.dispose();
      }
      if (lineChart) {
        lineChart.dispose();
      }
    };
  }, []);

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>ECharts Chart Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Pie Chart */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Pie Chart</div>
              <div className={styles.itemDesc}>Shows the proportion distribution of sales data for each product</div>
              <div className={styles.chartContainer}>
                <div ref={pieChartRef} className={styles.chart}></div>
              </div>
            </div>

            {/* Bar Chart */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Bar Chart</div>
              <div className={styles.itemDesc}>Shows comparison of monthly sales data</div>
              <div className={styles.chartContainer}>
                <div ref={barChartRef} className={styles.chart}></div>
              </div>
            </div>

            {/* Line Chart */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Line Chart</div>
              <div className={styles.itemDesc}>Shows time series changes in user growth trends</div>
              <div className={styles.chartContainer}>
                <div ref={lineChartRef} className={styles.chart}></div>
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};