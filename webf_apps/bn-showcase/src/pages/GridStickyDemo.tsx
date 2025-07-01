import React, { useState } from 'react';
import styled from 'styled-components';
// import DemoNavbar from '../components/DemoNavbar';

const PageContainer = styled.div`
  height: 100%;
  display: flex;
  flex-direction: column;
  background-color: #f8f9fa;
`;

const Content = styled.div`
  flex: 1;
  overflow-y: auto;
  padding: 20px;
`;

const DemoSection = styled.div`
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
  overflow: hidden;
`;

const SectionHeader = styled.div`
  background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  padding: 16px 20px;
  font-size: 18px;
  font-weight: bold;
`;

const SectionContent = styled.div`
  padding: 20px;
`;

const DemoTitle = styled.h3`
  color: #333;
  margin: 0 0 16px 0;
  font-size: 16px;
  border-left: 4px solid #4facfe;
  padding-left: 12px;
`;

const DemoItem = styled.div`
  margin-bottom: 24px;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  overflow: hidden;
`;

const DemoLabel = styled.div`
  background: #6c757d;
  color: white;
  padding: 8px 12px;
  font-size: 14px;
  font-weight: 500;
`;

const DemoContent = styled.div`
  padding: 16px;
`;

// Grid布局样式
const GridContainer = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
`;

const GridItem = styled.div<{ span?: number }>`
  background: linear-gradient(135deg, #ff9a9e, #fecfef);
  padding: 20px;
  border-radius: 8px;
  text-align: center;
  font-weight: bold;
  color: #333;
  grid-column: ${props => props.span ? `span ${props.span}` : 'span 1'};
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-2px);
  }
`;

const StickyContainer = styled.div`
  height: 300px;
  overflow-y: auto;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  position: relative;
`;

const StickyHeader = styled.div`
  background: linear-gradient(90deg, #ff6b6b, #feca57);
  color: white;
  padding: 12px;
  position: sticky;
  top: 0;
  z-index: 10;
  font-weight: bold;
`;

const StickyContent = styled.div`
  padding: 12px;
  background: ${props => props.color || '#f8f9fa'};
  margin-bottom: 8px;
  border-radius: 6px;
`;

const ActionButton = styled.button`
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 12px;
  transition: transform 0.2s ease;
  
  &:hover {
    transform: translateY(-1px);
  }
`;

const GridStickyDemo: React.FC = () => {
  const [stickyCount, setStickyCount] = useState(20);
  const colors = ['#ffeaa7', '#fab1a0', '#a8edea', '#fd79a8', '#fdcb6e', '#6c5ce7', '#74b9ff', '#00b894'];

  return (
    <PageContainer>
      {/* <DemoNavbar 
        title="Grid布局与Sticky定位" 
        subtitle="测试CSS Grid和粘性定位的能力"
      /> */}
      
      <Content>
        <DemoSection>
          <SectionHeader>CSS Grid布局演示</SectionHeader>
          <SectionContent>
            <DemoTitle>2.1 CSS Grid自适应布局</DemoTitle>
            <DemoItem>
              <DemoLabel>grid-template-columns: repeat(auto-fit, minmax(150px, 1fr))</DemoLabel>
              <DemoContent>
                <GridContainer>
                  <GridItem>Item 1</GridItem>
                  <GridItem span={2}>Span 2 Items</GridItem>
                  <GridItem>Item 3</GridItem>
                  <GridItem>Item 4</GridItem>
                  <GridItem>Item 5</GridItem>
                  <GridItem>Item 6</GridItem>
                </GridContainer>
              </DemoContent>
            </DemoItem>
          </SectionContent>
        </DemoSection>

        <DemoSection>
          <SectionHeader>Sticky粘性定位演示</SectionHeader>
          <SectionContent>
            <DemoTitle>2.2 Sticky粘性定位</DemoTitle>
            <DemoItem>
              <DemoLabel>position: sticky + 滚动容器</DemoLabel>
              <DemoContent>
                <StickyContainer>
                  <StickyHeader>我是粘性标题 - 滚动时会保持在顶部</StickyHeader>
                  {Array.from({ length: stickyCount }, (_, i) => (
                    <StickyContent key={i} color={colors[i % colors.length]}>
                      滚动内容项 {i + 1} - 向上滚动观察粘性效果
                    </StickyContent>
                  ))}
                </StickyContainer>
                <div style={{ textAlign: 'center' }}>
                  <ActionButton onClick={() => setStickyCount(prev => prev + 10)}>
                    添加更多内容
                  </ActionButton>
                </div>
              </DemoContent>
            </DemoItem>
          </SectionContent>
        </DemoSection>
      </Content>
    </PageContainer>
  );
};

export default GridStickyDemo; 