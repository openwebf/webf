import React, { useState, useEffect, useRef, useCallback } from 'react';
import { WebFTable, WebFTableCell, WebFTableRow, WebFTableHeader, WebFListView, useFlutterAttached, FlutterShimmer, FlutterShimmerText } from '@openwebf/react-core-ui';

interface BitcoinData {
  currentPrice: number;
  change24h: number;
  change24hPercent: number;
  high24h: number;
  low24h: number;
  volume24h: number;
}

interface TradeRecord {
  id: string;
  timestamp: Date;
  type: 'buy' | 'sell';
  price: number;
  amount: number;
  total: number;
}

const BitcoinPriceTailwind: React.FC = () => {
  const [bitcoinData, setBitcoinData] = useState<BitcoinData>({
    currentPrice: 45320.50,
    change24h: 1250.30,
    change24hPercent: 2.84,
    high24h: 46100.00,
    low24h: 43890.20,
    volume24h: 28.5
  });

  const [tableTotalSize, updateTableTotalSize] = useState(0);

  const attachedRef = useFlutterAttached((event) => {
    updateTableTotalSize(window.screen.width);
  }, (event) => {
  });

  const [tradeRecords, setTradeRecords] = useState<TradeRecord[]>([]);
  const tradeListRef = useRef<HTMLDivElement>(null);

  // Generate simulated K-line data
  const generateKLineData = () => {
    const data = [];
    const basePrice = 45000;
    const now = new Date();

    for (let i = 29; i >= 0; i--) {
      const date = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
      const randomChange = (Math.random() - 0.5) * 2000;
      const open = basePrice + randomChange;
      const close = open + (Math.random() - 0.5) * 1000;
      const high = Math.max(open, close) + Math.random() * 500;
      const low = Math.min(open, close) - Math.random() * 500;

      data.push([
        date.toISOString().split('T')[0],
        Math.round(open),
        Math.round(close),
        Math.round(low),
        Math.round(high)
      ]);
    }
    return data;
  };

  const klineData = generateKLineData();

  // Generate simulated trade records
  const generateTradeRecord = useCallback((): TradeRecord => {
    const now = new Date();
    const type = Math.random() > 0.5 ? 'buy' : 'sell';
    const priceVariation = (Math.random() - 0.5) * 100; // Price variation ±50
    const price = bitcoinData.currentPrice + priceVariation;
    const amount = +(Math.random() * 2 + 0.01).toFixed(4); // 0.01 to 2.01 BTC
    const total = price * amount;

    return {
      id: `${now.getTime()}-${Math.random()}`,
      timestamp: now,
      type,
      price: +price.toFixed(2),
      amount,
      total: +total.toFixed(2)
    };
  }, [bitcoinData.currentPrice]);

  // Auto scroll to bottom
  const scrollToBottom = useCallback(() => {
    if (tradeListRef.current) {
      tradeListRef.current.scrollTop = tradeListRef.current.scrollHeight;
    }
  }, []);

  // Simulate price updates
  useEffect(() => {
    const interval = setInterval(() => {
      setBitcoinData(prev => {
        const change = (Math.random() - 0.5) * 100;
        const newPrice = prev.currentPrice + change;
        return {
          ...prev,
          currentPrice: newPrice,
          change24h: prev.change24h + change,
          change24hPercent: ((prev.change24h + change) / newPrice) * 100
        };
      });
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  // Generate initial trade records
  useEffect(() => {
    const initialTrades: TradeRecord[] = [];
    const now = new Date();

    for (let i = 0; i < 20; i++) {
      const timestamp = new Date(now.getTime() - (20 - i) * 30000); // Every 30 seconds
      const type = Math.random() > 0.5 ? 'buy' : 'sell';
      const price = 45000 + (Math.random() - 0.5) * 1000;
      const amount = +(Math.random() * 2 + 0.01).toFixed(4);
      const total = price * amount;

      initialTrades.push({
        id: `initial-${i}`,
        timestamp,
        type,
        price: +price.toFixed(2),
        amount,
        total: +total.toFixed(2)
      });
    }

    setTradeRecords(initialTrades);
  }, []);

  // Periodically add new trade records
  useEffect(() => {
    const interval = setTimeout(() => {
      const newTrade = generateTradeRecord();
      setTradeRecords(prev => {
        const newRecords = [...prev, newTrade];
        // Keep max 100 records
        if (newRecords.length > 100) {
          return newRecords.slice(-100);
        }
        return newRecords;
      });
    }, 2000 + Math.random() * 3000); // 2-5 seconds random interval

    return () => clearInterval(interval);
  }, [generateTradeRecord]);

  // Auto scroll when new trade records are added
  useEffect(() => {
    scrollToBottom();
  }, [tradeRecords, scrollToBottom]);

  const formatPrice = (price: number) => {
    return `$${price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  };

  const formatPercent = (percent: number) => {
    return `${percent >= 0 ? '+' : ''}${percent.toFixed(2)}%`;
  };

  return (
    <WebFListView className='h-full' shrinkWrap={false} ref={attachedRef}>
      {/* Header */}
      <div className="bg-orange-500 text-white py-4 px-4 text-center text-lg font-bold">
        比特币 (BTC)
      </div>

      {/* Price Info */}
      <div>
        <div className="bg-white p-5 m-4 rounded-xl" style={{
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)'
        }}>
          <div className="text-2xl font-bold text-orange-500 text-center mb-4">
            {formatPrice(bitcoinData.currentPrice)}
          </div>

          <div>
            <div className="flex justify-between items-center mb-3">
              <span className="text-gray-600 text-sm">24小时涨跌</span>
              <span className={`font-bold ${bitcoinData.change24h >= 0 ? 'text-green-500' : 'text-red-500'}`}>
                {formatPrice(bitcoinData.change24h)} ({formatPercent(bitcoinData.change24hPercent)})
              </span>
            </div>

            <div className="flex justify-between items-center mb-3">
              <span className="text-gray-600 text-sm">24小时最高</span>
              <span className="font-bold text-gray-800">{formatPrice(bitcoinData.high24h)}</span>
            </div>

            <div className="flex justify-between items-center mb-3">
              <span className="text-gray-600 text-sm">24小时最低</span>
              <span className="font-bold text-gray-800">{formatPrice(bitcoinData.low24h)}</span>
            </div>

            <div className="flex justify-between items-center">
              <span className="text-gray-600 text-sm">24小时成交量</span>
              <span className="font-bold text-gray-800">{bitcoinData.volume24h.toFixed(1)}B</span>
            </div>
          </div>
        </div>
      </div>

      {/* Trade List */}
      <div>
        <div className="m-4 bg-white rounded-xl" style={{
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)'
        }}>
          <div className="py-4 px-4 text-base font-bold text-white" style={{
            background: 'linear-gradient(90deg, #f7931a, #ffa726)'
          }}>
            实时交易记录
          </div>

          <div className="border" ref={tradeListRef} style={{ height: '50vh' }}>
            {tableTotalSize > 0 ? (
              <WebFTable defaultColumnWidth={80} className='h-full'>
              <WebFTableHeader className="bg-gray-100 border-b border-gray-300" sticky={true}>
                <WebFTableCell columnWidth={tableTotalSize * 0.25} className="py-3 px-4 text-sm font-normal text-red-700">
                  时间
                </WebFTableCell>
                <WebFTableCell columnWidth={tableTotalSize * 0.1} className="py-3 px-4 text-sm font-normal text-gray-700">
                  类型
                </WebFTableCell>
                <WebFTableCell columnWidth={tableTotalSize * 0.2} className="py-3 px-4 text-sm font-normal text-gray-700">
                  价格 (USD)
                </WebFTableCell>
                <WebFTableCell columnWidth={tableTotalSize * 0.2} className="py-3 px-4 text-sm font-normal text-gray-700">
                  数量 (BTC)
                </WebFTableCell>
                <WebFTableCell columnWidth={tableTotalSize * 0.3} className="py-3 px-4 text-sm font-normal text-gray-700">
                  金额 (USD)
                </WebFTableCell>
              </WebFTableHeader>
              {tradeRecords.map((trade, index) => (
                <WebFTableRow
                  key={trade.id}
                  className={`border-b border-gray-200 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}`}
                >
                  <WebFTableCell className="py-3 px-4 text-gray-600 text-sm">
                    {trade.timestamp.toLocaleTimeString('zh-CN', {
                      hour: '2-digit',
                      minute: '2-digit',
                      second: '2-digit'
                    })}
                  </WebFTableCell>
                  <WebFTableCell className="py-3 px-4">
                    <span className={`font-bold text-sm ${trade.type === 'buy' ? 'text-green-500' : 'text-red-500'
                      }`}>
                      {trade.type === 'buy' ? 'BUY' : 'SELL'}
                    </span>
                  </WebFTableCell>
                  <WebFTableCell className="py-3 px-4">
                    <span className={`text-sm ${trade.type === 'buy' ? 'text-green-500' : 'text-red-500'
                      }`}>
                      ${trade.price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </span>
                  </WebFTableCell>
                  <WebFTableCell className="py-3 px-4 text-gray-800 text-sm">
                    {trade.amount.toFixed(4)}
                  </WebFTableCell>
                  <WebFTableCell className="py-3 px-4 text-gray-700 text-sm">
                    ${trade.total.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </WebFTableCell>
                </WebFTableRow>
              ))}
            </WebFTable>
            ) : (
              <FlutterShimmer>
                
              </FlutterShimmer>
            )}
          </div>
        </div>
      </div>
    </WebFListView>
  );
};

export default BitcoinPriceTailwind;