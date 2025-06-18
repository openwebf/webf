describe("CSS Math Functions", () => {
  // Trigonometric Functions
  describe("Trigonometric Functions", () => {
    it('should work with sin() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(sin(30deg) * 100px)',    // sin(30°) = 0.5, so 50px
            height: '20px',
            background: 'red'
          }
        }, [createText('sin(30deg)')]),
        createElement('div', {
          style: {
            width: 'calc(sin(90deg) * 100px)',    // sin(90°) = 1, so 100px
            height: '20px',
            background: 'blue'
          }
        }, [createText('sin(90deg)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with cos() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(cos(0deg) * 100px)',     // cos(0°) = 1, so 100px
            height: '20px',
            background: 'green'
          }
        }, [createText('cos(0deg)')]),
        createElement('div', {
          style: {
            width: 'calc(cos(60deg) * 100px)',    // cos(60°) = 0.5, so 50px
            height: '20px',
            background: 'purple'
          }
        }, [createText('cos(60deg)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with tan() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(tan(45deg) * 50px)',     // tan(45°) = 1, so 50px
            height: '20px',
            background: 'orange'
          }
        }, [createText('tan(45deg)')]),
        createElement('div', {
          style: {
            width: 'calc(tan(0deg) * 100px)',     // tan(0°) = 0, so 0px
            height: '20px',
            background: 'pink'
          }
        }, [createText('tan(0deg)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with inverse trig functions', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(asin(0.5) * 2)',         // asin(0.5) = 30deg
            height: '20px',
            background: 'red'
          }
        }, [createText('asin(0.5)')]),
        createElement('div', {
          style: {
            width: 'calc(acos(0.5) * 1)',         // acos(0.5) = 60deg
            height: '20px',
            background: 'blue'
          }
        }, [createText('acos(0.5)')]),
        createElement('div', {
          style: {
            width: 'calc(atan(1) * 2)',           // atan(1) = 45deg
            height: '20px',
            background: 'green'
          }
        }, [createText('atan(1)')]),
        createElement('div', {
          style: {
            width: 'calc(atan2(1, 1) * 2)',      // atan2(1, 1) = 45deg
            height: '20px',
            background: 'purple'
          }
        }, [createText('atan2(1, 1)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });
  });

  // Exponential Functions
  describe("Exponential Functions", () => {
    it('should work with pow() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(pow(2, 3) * 10px)',      // 2^3 = 8, so 80px
            height: '20px',
            background: 'red'
          }
        }, [createText('pow(2, 3)')]),
        createElement('div', {
          style: {
            width: 'calc(pow(5, 2) * 4px)',       // 5^2 = 25, so 100px
            height: '20px',
            background: 'blue'
          }
        }, [createText('pow(5, 2)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with sqrt() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(sqrt(4) * 50px)',        // sqrt(4) = 2, so 100px
            height: '20px',
            background: 'green'
          }
        }, [createText('sqrt(4)')]),
        createElement('div', {
          style: {
            width: 'calc(sqrt(9) * 20px)',        // sqrt(9) = 3, so 60px
            height: '20px',
            background: 'purple'
          }
        }, [createText('sqrt(9)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with hypot() function', async () => {
      let box = createElement('div', {
        style: {
          width: 'hypot(30px, 40px)',             // sqrt(30^2 + 40^2) = 50px
          height: 'hypot(60px, 80px)',            // sqrt(60^2 + 80^2) = 100px
          background: 'orange'
        }
      }, [createText('hypot')]);
      document.body.appendChild(box);
      await snapshot();
    });

    it('should work with log() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(log(2.718281828) * 100px)', // log(e) ≈ 1, so ~100px
            height: '20px',
            background: 'red'
          }
        }, [createText('log(e)')]),
        createElement('div', {
          style: {
            width: 'calc(log(8, 2) * 30px)',      // log2(8) = 3, so 90px
            height: '20px',
            background: 'blue'
          }
        }, [createText('log(8, 2)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with exp() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(exp(0) * 100px)',        // e^0 = 1, so 100px
            height: '20px',
            background: 'green'
          }
        }, [createText('exp(0)')]),
        createElement('div', {
          style: {
            width: 'calc(exp(1) * 30px)',         // e^1 = e ≈ 2.718, so ~81.5px
            height: '20px',
            background: 'purple'
          }
        }, [createText('exp(1)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });
  });

  // Sign-related Functions
  describe("Sign-related Functions", () => {
    it('should work with abs() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'abs(-100px)',                 // abs(-100px) = 100px
            height: '20px',
            background: 'red'
          }
        }, [createText('abs(-100px)')]),
        createElement('div', {
          style: {
            width: 'abs(80px)',                   // abs(80px) = 80px
            height: '20px',
            background: 'blue'
          }
        }, [createText('abs(80px)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });

    it('should work with sign() function', async () => {
      let container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '5px'
        }
      }, [
        createElement('div', {
          style: {
            width: 'calc(sign(-100) * 50px + 100px)', // sign(-100) = -1, so 50px
            height: '20px',
            background: 'green'
          }
        }, [createText('sign(-100)')]),
        createElement('div', {
          style: {
            width: 'calc(sign(100) * 50px + 50px)',   // sign(100) = 1, so 100px
            height: '20px',
            background: 'purple'
          }
        }, [createText('sign(100)')]),
        createElement('div', {
          style: {
            width: 'calc(sign(0) * 50px + 75px)',     // sign(0) = 0, so 75px
            height: '20px',
            background: 'orange'
          }
        }, [createText('sign(0)')])
      ]);
      document.body.appendChild(container);
      await snapshot();
    });
  });

  // Complex combinations
  it('should work with nested math functions', async () => {
    let box = createElement('div', {
      style: {
        width: 'calc(abs(sin(30deg) * -200px))',    // abs(0.5 * -200px) = 100px
        height: 'calc(sqrt(pow(3, 2) + pow(4, 2)) * 20px)', // sqrt(9 + 16) * 20px = 100px
        background: 'green'
      }
    }, [createText('nested math')]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should work with math constants', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: '5px'
      }
    }, [
      createElement('div', {
        style: {
          width: 'calc(pi * 30px)',               // π * 30px ≈ 94.25px
          height: '20px',
          background: 'red'
        }
      }, [createText('pi')]),
      createElement('div', {
        style: {
          width: 'calc(e * 35px)',                // e * 35px ≈ 95.14px
          height: '20px',
          background: 'blue'
        }
      }, [createText('e')])
    ]);
    document.body.appendChild(container);
    await snapshot();
  });
});