describe('text-baseline-cjk', () => {
  it('should align CJK and Latin text baselines in inline-flex container', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Mixed CJK-Latin text in inline-flex:')]),

      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#e0e0e0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('span', {}, [createText('银行卡')]),
        createElement('span', {}, [createText('TEST')]),
        createElement('span', {}, [createText('1111')]),
        createElement('span', {}, [createText('Hello')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should align CJK and Latin text baselines with align-items: baseline', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Flex with align-items: baseline:')]),

      createElement('div', {
        style: {
          display: 'flex',
          alignItems: 'baseline',
          backgroundColor: '#d0d0d0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('div', {}, [createText('银行卡')]),
        createElement('div', {}, [createText('TEST')]),
        createElement('div', {}, [createText('1111')]),
        createElement('div', {}, [createText('Hello')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle pure CJK text baseline', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Pure CJK text:')]),

      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#e0e0e0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('span', {}, [createText('中文测试')]),
        createElement('span', {}, [createText('汉字')]),
        createElement('span', {}, [createText('文字基线')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle pure Latin text baseline', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Pure Latin text:')]),

      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#e0e0e0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('span', {}, [createText('English')]),
        createElement('span', {}, [createText('TEST')]),
        createElement('span', {}, [createText('baseline')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle different font sizes with mixed scripts', async () => {
    let container = createElement('div', {
      style: {
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Different font sizes:')]),

      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'baseline',
          backgroundColor: '#d0d0d0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('span', {
          style: { fontSize: '16px' }
        }, [createText('小号中文')]),
        createElement('span', {
          style: { fontSize: '24px' }
        }, [createText('Large English')]),
        createElement('span', {
          style: { fontSize: '32px' }
        }, [createText('大号汉字')]),
        createElement('span', {
          style: { fontSize: '20px' }
        }, [createText('Medium 123')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle Japanese Hiragana and Katakana', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Hiragino Sans", "Yu Gothic", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Japanese mixed scripts:')]),

      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#e0e0e0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('span', {}, [createText('ひらがな')]),
        createElement('span', {}, [createText('カタカナ')]),
        createElement('span', {}, [createText('English')]),
        createElement('span', {}, [createText('123')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle Korean Hangul', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Malgun Gothic", "Apple SD Gothic Neo", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Korean mixed scripts:')]),

      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#e0e0e0',
          padding: '5px',
          margin: '2px'
        }
      }, [
        createElement('span', {}, [createText('한글')]),
        createElement('span', {}, [createText('텍스트')]),
        createElement('span', {}, [createText('English')]),
        createElement('span', {}, [createText('ABC123')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle vertical-align with mixed scripts', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '24px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Inline elements with mixed scripts:')]),

      createElement('div', {
        style: {
          backgroundColor: '#f0f0f0',
          padding: '5px'
        }
      }, [
        createElement('span', {
          style: {
            backgroundColor: '#e0e0e0',
            padding: '2px',
            margin: '2px'
          }
        }, [createText('银行卡')]),
        createElement('span', {
          style: {
            backgroundColor: '#e0e0e0',
            padding: '2px',
            margin: '2px'
          }
        }, [createText('TEST')]),
        createElement('span', {
          style: {
            backgroundColor: '#e0e0e0',
            padding: '2px',
            margin: '2px'
          }
        }, [createText('1111')]),
        createElement('span', {
          style: {
            backgroundColor: '#e0e0e0',
            padding: '2px',
            margin: '2px'
          }
        }, [createText('Hello')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });
});
