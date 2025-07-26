describe('flexbox-baseline-cjk', () => {
  it('should align CJK and Latin baselines in flex container with center alignment', async () => {
    // This test specifically covers the reported issue
    let container = createElement('div', {
      style: {
        margin: '20px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
      }
    }, [
      createElement('div', {
        style: {
          fontSize: '14px',
          color: '#666',
          marginBottom: '5px'
        }
      }, [createText('Mixed content in same container:')]),

      createElement('div', {
        style: {
          fontSize: '24px'
        }
      }, [
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
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle baseline alignment with different CJK-Latin ratios', async () => {
    let testCases = [
      '银行卡TEST1111Hello',      // Original case
      '中文EnglishTest',          // Mixed in single span
      '汉字ABC123',               // Short mixed
      'PureEnglishText',          // Pure Latin
      '纯中文测试文字',            // Pure CJK
      '50%中文50%English',        // Balanced mix
    ];

    let container = createElement('div', {
      style: {
        margin: '20px',
        fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", sans-serif',
        fontSize: '20px'
      }
    });

    for (let text of testCases) {
      container.appendChild(
        createElement('div', {
          style: {
            marginBottom: '10px'
          }
        }, [
          createElement('div', {
            style: {
              fontSize: '12px',
              color: '#666',
              marginBottom: '2px'
            }
          }, [createText(`Text: "${text}"`)]),

          createElement('div', {
            style: {
              display: 'inline-flex',
              alignItems: 'center',
              backgroundColor: '#e8e8e8',
              padding: '4px'
            }
          }, [createText(text)])
        ])
      );
    }

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle baseline alignment in nested flex containers', async () => {
    let container = createElement('div', {
      style: {
        margin: '20px',
        fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
        fontSize: '18px'
      }
    }, [
      createElement('div', {
        style: {
          display: 'flex',
          alignItems: 'baseline',
          backgroundColor: '#f0f0f0',
          padding: '10px',
          gap: '10px'
        }
      }, [
        createElement('div', {}, [createText('Label:')]),
        createElement('div', {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            backgroundColor: '#e0e0e0',
            padding: '5px'
          }
        }, [
          createElement('span', {}, [createText('银行卡')]),
          createElement('span', {}, [createText('TEST')])
        ]),
        createElement('div', {}, [createText('Status')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should compare align-items center vs baseline with CJK text', async () => {
    let container = createElement('div', {
      style: {
        margin: '20px',
        fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
        fontSize: '20px'
      }
    }, [
      // align-items: center
      createElement('div', {
        style: {
          marginBottom: '20px'
        }
      }, [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '5px'
          }
        }, [createText('align-items: center')]),

        createElement('div', {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            backgroundColor: '#e0e0e0',
            padding: '5px',
            gap: '5px'
          }
        }, [
          createElement('span', {}, [createText('银行卡')]),
          createElement('span', {}, [createText('Bank Card')]),
          createElement('span', {}, [createText('123')])
        ])
      ]),

      // align-items: baseline
      createElement('div', {}, [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '5px'
          }
        }, [createText('align-items: baseline')]),

        createElement('div', {
          style: {
            display: 'inline-flex',
            alignItems: 'baseline',
            backgroundColor: '#d0d0d0',
            padding: '5px',
            gap: '5px'
          }
        }, [
          createElement('span', {}, [createText('银行卡')]),
          createElement('span', {}, [createText('Bank Card')]),
          createElement('span', {}, [createText('123')])
        ])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle CJK baseline with different line heights', async () => {
    let lineHeights = ['normal', '1.2', '1.5', '2'];

    let container = createElement('div', {
      style: {
        margin: '20px',
        fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
        fontSize: '18px'
      }
    });

    for (let lineHeight of lineHeights) {
      container.appendChild(
        createElement('div', {
          style: {
            marginBottom: '15px'
          }
        }, [
          createElement('div', {
            style: {
              fontSize: '12px',
              color: '#666',
              marginBottom: '2px'
            }
          }, [createText(`line-height: ${lineHeight}`)]),

          createElement('div', {
            style: {
              display: 'inline-flex',
              alignItems: 'center',
              backgroundColor: '#e0e0e0',
              padding: '5px',
              lineHeight: lineHeight
            }
          }, [
            createElement('span', {}, [createText('中文')]),
            createElement('span', {}, [createText('English')]),
            createElement('span', {}, [createText('123')])
          ])
        ])
      );
    }

    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle CJK baseline with text decorations', async () => {
    let container = createElement('div', {
      style: {
        margin: '20px',
        fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
        fontSize: '20px'
      }
    }, [
      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#e0e0e0',
          padding: '5px',
          gap: '10px',
          textDecoration: 'underline'
        }
      }, [
        createElement('span', {}, [createText('银行卡')]),
        createElement('span', {}, [createText('Underlined')]),
        createElement('span', {}, [createText('下划线')])
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });
});
