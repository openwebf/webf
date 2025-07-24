describe('text-baseline-inline-mixed', () => {
  it('should align CJK text node with Latin span in same line', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Mixed text node and span - should have aligned baseline:')]),

      // First case: text node followed by span (the problematic case)
      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('转账 '),
        createElement('span', {
          style: {
            color: '#007AFF'
          }
        }, [createText('5 RUB')])
      ]),

      // Second case: all text in one span (reference case)
      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          border: '1px solid #ddd'
        }
      }, [
        createElement('span', {}, [createText('转账 5 RUB')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should align multiple mixed text nodes and spans', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Multiple mixed segments:')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('账户 '),
        createElement('span', {
          style: { fontWeight: 'bold' }
        }, [createText('12345')]),
        createText(' 余额 '),
        createElement('span', {
          style: { color: 'red' }
        }, [createText('$1000.00')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle pure CJK text node with pure Latin span', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Pure CJK + Pure Latin:')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('中文汉字'),
        createElement('span', {
          style: { marginLeft: '5px' }
        }, [createText('English')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle nested spans with mixed content', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Nested spans:')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('外层 '),
        createElement('span', {
          style: { color: 'blue' }
        }, [
          createText('内层 '),
          createElement('span', {
            style: { fontWeight: 'bold' }
          }, [createText('ABC123')])
        ])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle different font sizes with inline mixed content', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
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
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('正常大小 '),
        createElement('span', {
          style: { fontSize: '20px' }
        }, [createText('Large 大')]),
        createText(' 继续 '),
        createElement('span', {
          style: { fontSize: '12px' }
        }, [createText('Small 小')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle Japanese mixed with Latin in inline context', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Hiragino Sans", "Yu Gothic", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Japanese mixed inline:')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('こんにちは '),
        createElement('span', {
          style: { color: 'green' }
        }, [createText('Hello')]),
        createText(' さようなら '),
        createElement('span', {
          style: { fontWeight: 'bold' }
        }, [createText('Goodbye')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle Korean mixed with numbers in inline context', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Malgun Gothic", "Apple SD Gothic Neo", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('Korean mixed inline:')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('가격 '),
        createElement('span', {
          style: { color: 'red', fontWeight: 'bold' }
        }, [createText('₩1,000')]),
        createText(' 입니다')
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle mixed content with inline-block elements', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('With inline-block:')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd'
        }
      }, [
        createText('文本 '),
        createElement('span', {
          style: {
            display: 'inline-block',
            backgroundColor: '#e0e0e0',
            padding: '2px 5px',
            borderRadius: '3px'
          }
        }, [createText('TAG')]),
        createText(' 继续')
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle RTL mixed scripts inline', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
        fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '14px'
        }
      }, [createText('RTL mixed (Arabic + Latin):')]),

      createElement('div', {
        style: {
          backgroundColor: 'white',
          padding: '10px',
          marginBottom: '5px',
          border: '1px solid #ddd',
          direction: 'rtl',
          textAlign: 'right'
        }
      }, [
        createText('العربية '),
        createElement('span', {
          style: { color: 'blue' }
        }, [createText('English')]),
        createText(' نص')
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle complex real-world scenario', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '14px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif',
        padding: '20px',
        backgroundColor: '#f0f0f0'
      }
    }, [
      createElement('div', {
        style: {
          marginBottom: '10px',
          color: '#666',
          fontSize: '12px'
        }
      }, [createText('Real-world transaction display:')]),

      // Transaction list
      createElement('div', {
        style: {
          backgroundColor: 'white',
          borderRadius: '8px',
          overflow: 'hidden',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
        }
      }, [
        // Transaction 1
        createElement('div', {
          style: {
            padding: '12px 16px',
            borderBottom: '1px solid #eee',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center'
          }
        }, [
          createElement('div', {}, [
            createText('转账到 '),
            createElement('span', {
              style: { fontWeight: 'bold' }
            }, [createText('张三')])
          ]),
          createElement('span', {
            style: { color: '#FF3B30', fontWeight: 'bold' }
          }, [createText('-¥500.00')])
        ]),

        // Transaction 2
        createElement('div', {
          style: {
            padding: '12px 16px',
            borderBottom: '1px solid #eee',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center'
          }
        }, [
          createElement('div', {}, [
            createText('收款从 '),
            createElement('span', {
              style: { fontWeight: 'bold' }
            }, [createText('ABC Company')])
          ]),
          createElement('span', {
            style: { color: '#34C759', fontWeight: 'bold' }
          }, [createText('+$1,234.56')])
        ]),

        // Transaction 3
        createElement('div', {
          style: {
            padding: '12px 16px',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center'
          }
        }, [
          createElement('div', {}, [
            createText('支付 '),
            createElement('span', {
              style: { color: '#007AFF' }
            }, [createText('订单#12345')])
          ]),
          createElement('span', {
            style: { color: '#FF3B30', fontWeight: 'bold' }
          }, [createText('-¥99.99')])
        ])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });
});
