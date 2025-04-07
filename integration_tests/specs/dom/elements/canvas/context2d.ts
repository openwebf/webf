describe('Canvas context 2d', () => {
  it('can change size by width and height property', async () => {
    var canvas = document.createElement('canvas');
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');
    if (!context) {
      throw new Error('canvas context is null');
    }

    canvas.width = canvas.height = 300;
    // Scaled rectangle
    context.fillStyle = "red";
    context.fillRect(10, 10, 380, 380);

    await snapshot();
    canvas.width = canvas.height = 400;
    // Scaled rectangle
    context.fillStyle = "red";
    context.fillRect(10, 10, 380, 380);
    await snapshot();
  });

  it('should work with font and rect', async () => {
    var div = document.createElement('div');
    div.style.width = div.style.height = '300px';
    div.style.backgroundColor = '#eee';

    var canvas = document.createElement('canvas');
    canvas.style.width = canvas.style.height = '200px';
    div.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }
    context.font = '24px AlibabaSans';
    context.fillStyle = 'green';
    context.fillRect(10, 10, 50, 50);
    context.clearRect(15, 15, 30, 30);
    context.strokeStyle = 'red';
    context.strokeRect(40, 40, 100, 100);
    context.fillStyle = 'blue';
    context.fillText('Hello World', 5.0, 5.0);
    context.strokeText('Hello World', 5.0, 25.0);

    document.body.appendChild(div);

    await snapshot(canvas);
  });

  it('should work with lineWidth', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.lineWidth = 15;

    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineTo(130, 130);
    ctx.rect(40, 40, 70, 70);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with lineJoin', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.lineWidth = 20;
    ctx.lineJoin = 'round';
    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineTo(190, 100);
    ctx.lineTo(280, 20);
    ctx.lineTo(280, 150);
    ctx.stroke();
    await snapshot(canvas);
  });


  it('should work with lineCap', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineWidth = 15;
    ctx.lineCap = 'round';
    ctx.lineTo(100, 100);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with textAlign', async () => {
    const canvas = <canvas widht="350" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    const x = canvas.width / 2;

    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, canvas.height);
    ctx.stroke();

    ctx.font = '30px serif';

    ctx.textAlign = 'left';
    ctx.fillText('left-aligned', x, 40);

    ctx.textAlign = 'center';
    ctx.fillText('center-aligned', x, 85);

    ctx.textAlign = 'right';
    ctx.fillText('right-aligned', x, 130);
    await snapshot(canvas);
  });


  it('should work with miterLimit', async () => {
    const canvas = <canvas width="150" height="150" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    // Draw guides
    ctx.strokeStyle = '#09f';
    ctx.lineWidth = 2;
    ctx.strokeRect(-5, 50, 160, 50);

    // Set line styles
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 10;

    ctx.miterLimit = 10.0;

    // Draw lines
    ctx.beginPath();
    ctx.moveTo(0, 100);
    for (var i = 0; i < 24 ; i++) {
      var dy = i % 2 == 0 ? 25 : -25;
      ctx.lineTo(Math.pow(i, 1.5) * 2, 75 + dy);
    }
    ctx.stroke();

    await snapshot(canvas);
  });

  it('should work with ellipse', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Draw the ellipse
    ctx.beginPath();
    ctx.ellipse(100, 100, 50, 75, Math.PI / 4, 0, 2 * Math.PI);
    ctx.stroke();
    // Draw the ellipse's line of reflection
    ctx.beginPath();
    ctx.moveTo(0, 200);
    ctx.lineTo(200, 0);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with save and restore', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Save the default state
    ctx.save();

    ctx.fillStyle = 'green';
    ctx.fillRect(10, 10, 100, 100);

    // Restore the default state
    ctx.restore();

    ctx.fillRect(150, 40, 100, 100);
    await snapshot(canvas);
  });

  it('should work with moveTO and lineTo', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.beginPath();
    ctx.moveTo(0, 200);
    ctx.lineTo(200, 0);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with rotate and translate', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.fillStyle = 'gray';
    ctx.fillRect(80, 60, 140, 30);

    // Matrix transformation
    ctx.translate(150, 75);
    ctx.rotate(Math.PI / 2);
    ctx.translate(-150, -75);

    // Rotated rectangle
    ctx.fillStyle = 'red';
    ctx.fillRect(80, 60, 140, 30);
    await snapshot(canvas);
  });

  it('should work with roundRect', async (done) => {
    const canvas = <canvas height="400" width="400" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');

    ctx.scale(0.6, 0.6);

    // 半径为零的圆角矩形（指定为数字）
    ctx.strokeStyle = "red";
    ctx.beginPath();
    ctx.roundRect(10, 20, 150, 100, 0);
    ctx.stroke();
    
    // 半径为 40px 的圆角矩形（单元素列表）
    ctx.strokeStyle = "blue";
    ctx.beginPath();
    ctx.roundRect(10, 20, 150, 100, [40]);
    ctx.stroke();
    
    // 具有两个不同半径的圆角矩形
    ctx.strokeStyle = "orange";
    ctx.beginPath();
    ctx.roundRect(10, 150, 150, 100, [10, 40]);
    ctx.stroke();
    
    
    // 具有四个不同半径的圆角矩形
    ctx.strokeStyle = "green";
    ctx.beginPath();
    ctx.roundRect(400, 20, 200, 100, [0, 30, 50, 60]);
    ctx.stroke();
    
    // 向后绘制的相同矩形
    ctx.strokeStyle = "magenta";
    ctx.beginPath();
    ctx.roundRect(400, 150, -200, -100, [0, 30, 50, 60]);
    ctx.stroke();
    
    await snapshot(canvas);
    done();
  });

  it('should work with transform and resetTransform', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Skewed rectangles
    ctx.transform(1, 0, 1.7, 1, 0, 0);
    ctx.fillStyle = 'blue';
    ctx.fillRect(40, 40, 50, 20);
    ctx.fillRect(40, 90, 50, 20);

    // Non-skewed rectangles
    ctx.resetTransform();
    ctx.fillStyle = 'red';
    ctx.fillRect(40, 40, 50, 20);
    ctx.fillRect(40, 90, 50, 20);
    await snapshot(canvas);
  });

  it('should work with strokeText', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font = '50px serif';
    ctx.strokeText('Hello world', 50, 90);
    await snapshot(canvas);
  });

  it('should work with fillText', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font = '50px serif';
    ctx.fillText('Hello world', 50, 90);
    await snapshot(canvas);
  });

  it('should work with rect and fill', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.rect(10, 20, 150, 100);
    ctx.fill();
    await snapshot(canvas);
  });

  it('should work with bezierCurveTo', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Define the points as {x, y}
    let start = { x: 50,    y: 20  };
    let cp1 =   { x: 230,   y: 30  };
    let cp2 =   { x: 150,   y: 80  };
    let end =   { x: 250,   y: 100 };

    // Cubic Bézier curve
    ctx.beginPath();
    ctx.moveTo(start.x, start.y);
    ctx.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, end.x, end.y);
    ctx.stroke();

    // Start and end points
    ctx.fillStyle = 'blue';
    ctx.beginPath();
    ctx.arc(start.x, start.y, 5, 0, 2 * Math.PI);  // Start point
    ctx.arc(end.x, end.y, 5, 0, 2 * Math.PI);      // End point
    ctx.fill();

    // Control points
    ctx.fillStyle = 'red';
    ctx.beginPath();
    ctx.arc(cp1.x, cp1.y, 5, 0, 2 * Math.PI);  // Control point one
    ctx.arc(cp2.x, cp2.y, 5, 0, 2 * Math.PI);  // Control point two
    ctx.fill();
    await snapshot(canvas);
  });

  it('should work with quadraticCurveTo', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Quadratic Bézier curve
    ctx.beginPath();
    ctx.moveTo(50, 20);
    ctx.quadraticCurveTo(230, 30, 50, 100);
    ctx.stroke();

    // Start and end points
    ctx.fillStyle = 'blue';
    ctx.beginPath();
    ctx.arc(50, 20, 5, 0, 2 * Math.PI);   // Start point
    ctx.arc(50, 100, 5, 0, 2 * Math.PI);  // End point
    ctx.fill();

    // Control point
    ctx.fillStyle = 'red';
    ctx.beginPath();
    ctx.arc(230, 30, 5, 0, 2 * Math.PI);
    ctx.fill();
    await snapshot(canvas);
  });

  it('should work with fill and fillRect and clearRect', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Draw yellow background
    ctx.beginPath();
    ctx.fillStyle = '#ff6';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Draw blue triangle
    ctx.beginPath();
    ctx.fillStyle = 'blue';
    ctx.moveTo(20, 20);
    ctx.lineTo(180, 20);
    ctx.lineTo(130, 130);
    ctx.closePath();
    ctx.fill();

    // Clear part of the canvas
    ctx.clearRect(10, 10, 120, 100);
    await snapshot(canvas);
  });

  it('should work with clip', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Create circular clipping region
    ctx.beginPath();
    ctx.arc(100, 75, 50, 0, Math.PI * 2);
    ctx.clip();

    // Draw stuff that gets clipped
    ctx.fillStyle = 'blue';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'orange';
    ctx.fillRect(0, 0, 100, 100);
    await snapshot(canvas);
  });

  it('should work with setTransform', async () => {
    const canvas1 = <canvas />;
    const canvas2 = <canvas />;
    document.body.appendChild(canvas1);
    document.body.appendChild(canvas2);

    const ctx1 = canvas1.getContext('2d');
    const ctx2 = canvas2.getContext('2d');

    ctx1.rotate(45 * Math.PI / 180);
    ctx1.setTransform(1, .2, .8, 1, 0, 0);
    ctx1.fillRect(25, 25, 50, 50);

    ctx2.scale(9, 3);
    ctx2.setTransform(1, .2, .8, 1, 0, 0);
    ctx2.beginPath();
    ctx2.arc(50, 50, 50, 0, 2 * Math.PI);
    ctx2.fill();

    await snapshot();
  });


  it('should work with drawImage', async (done) => {
    const canvas = <canvas height="400" width="400" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    const img = document.createElement('img');
    img.onload = async () => {
      // drawImage(image, dx, dy)
      ctx.drawImage(img, 0, 0);
      // drawImage(image, dx, dy, dWidth, dHeight);
      ctx.drawImage(img, 100, 100, 100, 100);
      // drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
      ctx.drawImage(img, 20, 20, 20, 20, 200, 200, 100, 100);
      await snapshot(canvas);
      done();
    };
    img.src = 'assets/rabbit.png';
  });

  it('should work with reset', async (done) => {
    var canvas = document.createElement('canvas');
    canvas.style.width = canvas.style.height = '200px';
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }
    context.fillStyle = 'yellow';
    context.fillRect(0, 0, 100, 100);
    context.reset();

    context.fillStyle = 'green';
    context.fillRect(10, 10, 50, 50);

    await sleep(0.1);

    await snapshot(canvas);
    done();
  });

  it('should work when draw overflow element', async () => {
    const canvas = document.createElement('canvas')
    canvas.style.width = canvas.style.height = '200px';
    canvas.style.border = '1px solid green';
    canvas.style.padding = '10px';
    canvas.style.margin = '10px';
    canvas.width = canvas.height = 200;

    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!

    ctx.fillStyle = 'green';
    ctx.fillRect(10, 10, 200, 200);

    await snapshot();
  });

  it('should work with createLinearGradient', async (done) => {
    const canvas = <canvas height="300" width="300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }

    const lgd = context.createLinearGradient(20, 0, 220, 0);
		lgd.addColorStop(0, "green");
		lgd.addColorStop(0.5, "cyan");
		lgd.addColorStop(1, "green");

		context.fillStyle = lgd;
		context.fillRect(20, 20, 200, 100);

    await snapshot(canvas);
    done();
  });

  it('should work with createRadialGradient', async (done) => {
    const canvas = <canvas height="300" width="300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }

		const rgd = context.createRadialGradient(110, 90, 30, 100, 100, 70);
		rgd.addColorStop(0, "pink");
		rgd.addColorStop(0.9, "white");
		rgd.addColorStop(1, "green");

		context.fillStyle = rgd;
		context.fillRect(20, 20, 160, 160);
    await snapshot(canvas);
    done();
  });

  it('should work with createPattern from a canvas when repetition is repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "repeat");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from a canvas when repetition is repeat-x', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "repeat-x");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from a canvas when repetition is repeat-y', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "repeat-y");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from a canvas when repetition is no-repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "no-repeat");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from an image when repetition is repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "repeat");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })

  it('should work with createPattern from an image when repetition is repeat-x', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "repeat-x");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })

  it('should work with createPattern from an image when repetition is repeat-y', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "repeat-y");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })

  it('should work with createPattern from an image when repetition is no-repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "no-repeat");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })


  it('should work with create default Path2D', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    path1.rect(10, 10, 100, 100);
    context.stroke(path1)
    await snapshot(canvas);
    done();

  })

  it('should work with create Path2D with another Path2D instance', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    path1.rect(10, 10, 100, 100);

    let path2 = new Path2D(path1);
    path2.moveTo(220, 60);
    path2.arc(170, 60, 50, 0, 2 * Math.PI);
    context.stroke(path2);
    await snapshot(canvas);
    done();

  })

  it('should work with create Path2D with SVG path data', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path = new Path2D("M10 10 h 80 v 80 h -80 Z");
    context.fill(path);
    await snapshot(canvas);
    done();
    
  })

  it('should work with Path2D addPath(path)', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    
   // Create first path and add a rectangle
    let p1 = new Path2D();
    p1.rect(10, 10, 100, 150);

    // Create second path and add a rectangle
    let p2 = new Path2D();
    p2.rect(150, 10, 100, 75);

    // Add second path to the first path
    p1.addPath(p2);

    // Draw the first path
    context.fill(p1);

    await snapshot(canvas);
    done();
    
  })


  it('should work with create Path2D addPath with DOMMatrix', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    
   // Create first path and add a rectangle
    let p1 = new Path2D();
    p1.rect(0, 0, 100, 150);

    // Create second path and add a rectangle
    let p2 = new Path2D();
    p2.rect(0, 0, 100, 75);

    // Create transformation matrix that moves 200 points to the right
    let m = new DOMMatrix();
    m.a = 1;
    m.b = 0;
    m.c = 0;
    m.d = 1;
    m.e = 200;
    m.f = 0;

    // Add second path to the first path
    p1.addPath(p2, m);

    // Draw the first path
    context.fill(p1);

    await snapshot(canvas);
    done();
    
  })

  it('should works with width and scale', async (done) => {
    const canvas = <canvas height="300" width = "300" />;

    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    

    const path2d = new Path2D('M0 0h7v1H0zM9 0h3v1H9zM15 0h2v1H15zM18 0h1v1H18zM20 0h1v1H20zM22 0h4v1H22zM27 0h2v1H27zM30,0 h7v1H30zM0 1h1v1H0zM6 1h1v1H6zM10 1h2v1H10zM13 1h1v1H13zM15 1h1v1H15zM18 1h1v1H18zM22 1h1v1H22zM24 1h5v1H24zM30 1h1v1H30zM36,1 h1v1H36zM0 2h1v1H0zM2 2h3v1H2zM6 2h1v1H6zM8 2h1v1H8zM12 2h1v1H12zM15 2h2v1H15zM19 2h1v1H19zM21 2h2v1H21zM24 2h1v1H24zM27 2h1v1H27zM30 2h1v1H30zM32 2h3v1H32zM36,2 h1v1H36zM0 3h1v1H0zM2 3h3v1H2zM6 3h1v1H6zM8 3h1v1H8zM11 3h1v1H11zM13 3h2v1H13zM17 3h1v1H17zM22 3h5v1H22zM30 3h1v1H30zM32 3h3v1H32zM36,3 h1v1H36zM0 4h1v1H0zM2 4h3v1H2zM6 4h1v1H6zM8 4h1v1H8zM14 4h1v1H14zM16 4h1v1H16zM19 4h3v1H19zM23 4h1v1H23zM30 4h1v1H30zM32 4h3v1H32zM36,4 h1v1H36zM0 5h1v1H0zM6 5h1v1H6zM8 5h2v1H8zM14 5h2v1H14zM21 5h2v1H21zM24 5h2v1H24zM27 5h2v1H27zM30 5h1v1H30zM36,5 h1v1H36zM0 6h7v1H0zM8 6h1v1H8zM10 6h1v1H10zM12 6h1v1H12zM14 6h1v1H14zM16 6h1v1H16zM18 6h1v1H18zM20 6h1v1H20zM22 6h1v1H22zM24 6h1v1H24zM26 6h1v1H26zM28 6h1v1H28zM30,6 h7v1H30zM8 7h1v1H8zM10 7h2v1H10zM13 7h1v1H13zM15 7h2v1H15zM18 7h5v1H18zM26 7h3v1H26zM0 8h1v1H0zM2 8h5v1H2zM10 8h2v1H10zM14 8h6v1H14zM25 8h1v1H25zM27 8h2v1H27zM30 8h5v1H30zM0 9h1v1H0zM7 9h1v1H7zM14 9h2v1H14zM18 9h1v1H18zM20 9h2v1H20zM23 9h2v1H23zM30 9h2v1H30zM35 9h1v1H35zM1 10h1v1H1zM5 10h3v1H5zM10 10h2v1H10zM13 10h1v1H13zM15 10h2v1H15zM20 10h1v1H20zM25 10h1v1H25zM27 10h5v1H27zM35,10 h2v1H35zM11 11h3v1H11zM15 11h1v1H15zM18 11h1v1H18zM20 11h3v1H20zM26 11h6v1H26zM36,11 h1v1H36zM0 12h3v1H0zM6 12h1v1H6zM8 12h2v1H8zM11 12h3v1H11zM15 12h1v1H15zM17 12h1v1H17zM22 12h1v1H22zM24 12h4v1H24zM29 12h5v1H29zM35,12 h2v1H35zM1 13h1v1H1zM3 13h3v1H3zM7 13h2v1H7zM11 13h4v1H11zM16 13h1v1H16zM18 13h6v1H18zM28 13h2v1H28zM31 13h1v1H31zM0 14h1v1H0zM6 14h1v1H6zM8 14h1v1H8zM12 14h1v1H12zM15 14h1v1H15zM20 14h3v1H20zM26 14h2v1H26zM30 14h4v1H30zM36,14 h1v1H36zM1 15h2v1H1zM5 15h1v1H5zM7 15h1v1H7zM9 15h1v1H9zM13 15h4v1H13zM19 15h5v1H19zM26 15h3v1H26zM31 15h2v1H31zM35 15h1v1H35zM0 16h2v1H0zM3 16h4v1H3zM9 16h1v1H9zM11 16h2v1H11zM15 16h1v1H15zM19 16h1v1H19zM23 16h2v1H23zM26 16h2v1H26zM29 16h2v1H29zM32 16h1v1H32zM34 16h1v1H34zM36,16 h1v1H36zM1 17h2v1H1zM5 17h1v1H5zM7 17h2v1H7zM10 17h1v1H10zM12 17h1v1H12zM15 17h5v1H15zM21 17h5v1H21zM30 17h1v1H30zM35 17h1v1H35zM1 18h1v1H1zM3 18h1v1H3zM6 18h1v1H6zM10 18h2v1H10zM13 18h2v1H13zM18 18h1v1H18zM20 18h3v1H20zM25 18h3v1H25zM30 18h1v1H30zM32 18h1v1H32zM35,18 h2v1H35zM0 19h6v1H0zM13 19h2v1H13zM16 19h1v1H16zM19 19h4v1H19zM24 19h1v1H24zM28 19h4v1H28zM33 19h1v1H33zM36,19 h1v1H36zM0 20h2v1H0zM3 20h1v1H3zM6 20h1v1H6zM8 20h4v1H8zM14 20h1v1H14zM16 20h2v1H16zM22 20h4v1H22zM27 20h1v1H27zM29 20h2v1H29zM32 20h1v1H32zM34 20h1v1H34zM2 21h1v1H2zM5 21h1v1H5zM7 21h1v1H7zM11 21h3v1H11zM16 21h1v1H16zM19 21h1v1H19zM23 21h2v1H23zM28 21h2v1H28zM33 21h1v1H33zM0 22h2v1H0zM3 22h5v1H3zM9 22h1v1H9zM14 22h2v1H14zM18 22h1v1H18zM21 22h1v1H21zM27 22h2v1H27zM30 22h4v1H30zM36,22 h1v1H36zM1 23h2v1H1zM7 23h2v1H7zM12 23h1v1H12zM15 23h1v1H15zM20 23h2v1H20zM23 23h2v1H23zM26 23h1v1H26zM28 23h5v1H28zM36,23 h1v1H36zM1 24h1v1H1zM4 24h1v1H4zM6 24h3v1H6zM11 24h4v1H11zM16 24h1v1H16zM20 24h3v1H20zM26 24h1v1H26zM28 24h1v1H28zM30 24h1v1H30zM34 24h2v1H34zM0 25h1v1H0zM4 25h1v1H4zM7 25h3v1H7zM11 25h1v1H11zM14 25h2v1H14zM18 25h2v1H18zM23 25h3v1H23zM31 25h1v1H31zM0 26h1v1H0zM5 26h6v1H5zM12 26h1v1H12zM15 26h3v1H15zM20 26h3v1H20zM25 26h4v1H25zM30 26h2v1H30zM35,26 h2v1H35zM0 27h1v1H0zM3 27h2v1H3zM9 27h2v1H9zM13 27h1v1H13zM15 27h1v1H15zM18 27h1v1H18zM20 27h3v1H20zM26 27h3v1H26zM32 27h2v1H32zM36,27 h1v1H36zM0 28h1v1H0zM2 28h1v1H2zM4 28h3v1H4zM8 28h2v1H8zM11 28h2v1H11zM15 28h1v1H15zM17 28h1v1H17zM20 28h1v1H20zM22 28h1v1H22zM24 28h11v1H24zM36,28 h1v1H36zM8 29h2v1H8zM13 29h2v1H13zM16 29h1v1H16zM18 29h4v1H18zM23 29h1v1H23zM27 29h2v1H27zM32 29h2v1H32zM0 30h7v1H0zM13 30h1v1H13zM15 30h1v1H15zM21 30h2v1H21zM25 30h1v1H25zM28 30h1v1H28zM30 30h1v1H30zM32 30h1v1H32zM34,30 h3v1H34zM0 31h1v1H0zM6 31h1v1H6zM8 31h1v1H8zM11 31h2v1H11zM16 31h1v1H16zM19 31h3v1H19zM23 31h1v1H23zM26 31h1v1H26zM28 31h1v1H28zM32 31h2v1H32zM35,31 h2v1H35zM0 32h1v1H0zM2 32h3v1H2zM6 32h1v1H6zM8 32h2v1H8zM14 32h1v1H14zM18 32h2v1H18zM23 32h3v1H23zM27 32h6v1H27zM34 32h2v1H34zM0 33h1v1H0zM2 33h3v1H2zM6 33h1v1H6zM8 33h5v1H8zM15 33h2v1H15zM18 33h1v1H18zM20 33h2v1H20zM28 33h3v1H28zM32 33h1v1H32zM35,33 h2v1H35zM0 34h1v1H0zM2 34h3v1H2zM6 34h1v1H6zM8 34h2v1H8zM13 34h1v1H13zM20 34h3v1H20zM26 34h2v1H26zM35,34 h2v1H35zM0 35h1v1H0zM6 35h1v1H6zM12 35h3v1H12zM16 35h1v1H16zM20 35h3v1H20zM27 35h1v1H27zM29 35h2v1H29zM32 35h2v1H32zM36,35 h1v1H36zM0 36h7v1H0zM8 36h2v1H8zM11 36h1v1H11zM17 36h2v1H17zM22 36h1v1H22zM24 36h3v1H24zM29 36h2v1H29zM32 36h1v1H32zM34,36 h3v1H34z');

    context.scale(5, 5);
    context.fillStyle = 'red';
    context.fillRect(0, 0, 37, 37);
    context.fillStyle =  '#000000';
    context.fill(path2d);

    await snapshot(canvas);
    done();
  });

});
