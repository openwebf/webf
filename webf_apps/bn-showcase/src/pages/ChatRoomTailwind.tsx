import React, { useState, useRef, useMemo } from 'react';
import { WebFListView, WebFListViewElement, useFlutterAttached } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton, FlutterCupertinoInput } from '@openwebf/react-cupertino-ui';

interface Message {
  id: number;
  text: string;
  timestamp: Date;
  isOwn: boolean;
  height?: number;
}

// 生成假数据的函数
const generateFakeMessages = (): Message[] => {
  const messages: Message[] = [];
  const sampleTexts = [
    '你好！',
    '今天天气不错呢',
    '这是一条比较长的消息，用来测试不同长度的消息在虚拟列表中的表现，看看是否能够正确处理不同高度的消息项',
    '👍',
    '哈哈哈哈哈',
    '我正在测试虚拟滚动的性能',
    '这个聊天室看起来不错！',
    '让我们来看看1000条消息的滚动效果如何',
    '虚拟列表确实能够提升性能',
    '短消息',
    '这是一条非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常长的消息，用来测试极端情况下的消息渲染效果',
    '🎉🎉🎉',
    '性能测试中...',
    'React虚拟滚动真的很棒！',
    '滚动起来很流畅',
  ];

  for (let i = 0; i < 1000; i++) {
    const randomText = sampleTexts[Math.floor(Math.random() * sampleTexts.length)];
    const now = new Date();
    messages.push({
      id: i + 1,
      text: `[${i + 1}] ${randomText}`,
      timestamp: new Date(now.getTime() - (1000 - i) * 60000), // 每分钟一条消息
      isOwn: Math.random() > 0.5,
    });
  }
  return messages;
};

const ITEMS_PER_PAGE = 20; // Number of items to load per page

const ChatRoomTailwind: React.FC = () => {
  // 生成1000条假数据
  const [messages] = useState<Message[]>(() => generateFakeMessages());
  const [inputText, setInputText] = useState('');
  const [newMessages, setNewMessages] = useState<Message[]>([]);
  const listviewElement = useRef<WebFListViewElement>(null);
  
  // State for partial rendering
  const [visibleCount, setVisibleCount] = useState(ITEMS_PER_PAGE);
  const [isLoading, setIsLoading] = useState(false);

  const allMessages = useMemo(() => [...messages, ...newMessages], [messages, newMessages]);
  
  // Only show messages up to visibleCount
  const visibleMessages = useMemo(() => 
    allMessages.slice(0, visibleCount), 
    [allMessages, visibleCount]
  );

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSendMessage('');
    }
  };

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('zh-CN', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  // Handle load more when scrolling down
  const handleLoadMore = async () => {
    if (isLoading || visibleCount >= allMessages.length) {
      // No more items to load
      listviewElement.current?.finishLoad('noMore');
      return;
    }

    setIsLoading(true);

    // Load more items
    const newVisibleCount = Math.min(visibleCount + ITEMS_PER_PAGE, allMessages.length);
    setVisibleCount(newVisibleCount);
    setIsLoading(false);

    // Simulate async loading delay
    await new Promise(resolve => setTimeout(resolve, 250));
  

    // Tell WebFListView that loading is complete
    if (newVisibleCount >= allMessages.length) {
      listviewElement.current?.finishLoad('noMore');
    } else {
      listviewElement.current?.finishLoad('success');
    }
  };

  const handleSendMessage = (inputText: string) => {
    console.log('input text: ', inputText)
    if (inputText.trim()) {
      const newMessage: Message = {
        id: Date.now(),
        text: inputText,
        timestamp: new Date(),
        isOwn: true
      };
      setNewMessages(prev => [...prev, newMessage]);
      setInputText('');

      // 模拟自动回复
      setTimeout(() => {
        const autoReply: Message = {
          id: Date.now() + 1,
          text: `收到你的消息："${inputText}"`,
          timestamp: new Date(),
          isOwn: false
        };
        setNewMessages(prev => [...prev, autoReply]);
      }, 1000);
    }
  };

  // 渲染可见的消息项
  const renderVisibleItems = (messages: Message[]) => {
    const items = [];
    for (let i = 0; i < messages.length; i++) {
      const message = messages[i];
      if (!message) continue;

      items.push(
        <div key={message.id} className="w-full">
          <div
            className={`
              max-w-[70%] p-3 px-4 my-1.5 mx-4 rounded-[18px] break-words block z-[100]
              ${message.isOwn
                ? 'bg-blue-500 text-white ml-auto mr-4'
                : 'bg-white text-gray-800 mr-auto ml-4'
              }
              shadow-sm
            `}
            ref={(el) => {
              // itemRefs.current[i] = el;
            }}
          >
            {message.text}
            <div className={`text-xs mt-1 text-right ${message.isOwn ? 'text-white/80' : 'text-gray-500'}`}>
              {formatTime(message.timestamp)}
            </div>
          </div>
        </div>
      );
    }
    return items;
  };

  return (
    <div className="h-full flex flex-col bg-gray-100 border border-blue-500">
      <div className="bg-blue-500 text-white p-4 text-center text-lg font-bold flex justify-between items-center">
        <span>聊天室 - 虚拟滚动测试</span>
        <span className="text-sm opacity-80">
          显示 {visibleMessages.length} / {allMessages.length} 条消息
        </span>
      </div>

      <WebFListView 
        ref={listviewElement} 
        style={{ border: '1px solid #000' }}
        onLoadmore={handleLoadMore}
      >
        {renderVisibleItems(visibleMessages)}
      </WebFListView>

      <div className="flex items-center bg-gray-100 gap-3">
        <FlutterCupertinoInput
          autofocus={false}
          type="text"
          placeholder="输入消息..."
          val={inputText}
          style={{ 
            flex: 1,
            height: 44,
            borderRadius: 22,
            padding: '0 20px',
            fontSize: 16,
            backgroundColor: '#FFFFFF',
            border: '1px solid #E5E5E5'
          }}
          onInput={(e) => {
            console.log(e);
            setInputText((e as unknown as CustomEvent<string>).detail);
          }}
        />
        <FlutterCupertinoButton 
          disabled={inputText.trim().length == 0}
          style={{ 
            color: 'white',
            borderRadius: 20,
            padding: '10px 24px',
            fontSize: 16,
            fontWeight: 'bold',
            minWidth: 80
          }} 
          onClick={(e) => {
            console.log('input text', inputText, e);
            handleSendMessage(inputText);
          }} 
          variant='filled'
        >
          发送 
        </FlutterCupertinoButton>
      </div>
    </div>
  );
};

export default ChatRoomTailwind;